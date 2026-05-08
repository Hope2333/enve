// enve - 2D animations software
// Copyright (C) 2016-2020 Maurycy Liebner

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

#include "logger.h"
#include <QTextStream>
#include <QJsonDocument>
#include <QJsonObject>
#include <QSysInfo>
#include <QCoreApplication>
#include <QDir>
#include <iostream>
#include <csignal>
#include <execinfo.h>
#include <cstdlib>
#include <unistd.h>
#include <sys/syscall.h>

static const int BACKTRACE_DEPTH = 64;

QString LogEntry::format() const {
    const char* base = strrchr(file, '/');
    const char* fname = base ? base + 1 : file;

    QString result;
    QTextStream ts(&result);
    ts << "[" << timestamp.toString("yyyy-MM-ddTHH:mm:ss.zzz")
       << "] [pid=" << pid << " tid=" << tid
       << "] [" << logLevelLabel(level)
       << "] [" << fname << ":" << line
       << "] " << func << "()";

    if(exFile) {
        ts << " EX[" << exFile << ":" << exLine << " " << exFunc << "()] " << exMsg;
    } else {
        ts << " -- " << msg;
    }
    return result;
}

QString LogEntry::formatJson() const {
    const char* base = strrchr(file, '/');
    const char* fname = base ? base + 1 : file;

    QJsonObject obj;
    obj["ts"] = timestamp.toString(Qt::ISODateWithMs);
    obj["level"] = logLevelLabel(level);
    obj["pid"] = pid;
    obj["tid"] = tid;
    obj["src"] = QJsonObject{{"file", fname}, {"line", line}, {"func", func}};

    if(exFile) {
        obj["ex"] = QJsonObject{
            {"file", exFile}, {"line", exLine},
            {"func", exFunc}, {"msg", exMsg}};
    } else {
        obj["msg"] = msg;
    }

    return QString::fromUtf8(QJsonDocument(obj).toJson(QJsonDocument::Compact));
}

Logger& Logger::instance() {
    static Logger s;
    return s;
}

Logger::Logger() {}

Logger::~Logger() {
    disableFileLogging();
}

void Logger::enableFileLogging(const QString& path) {
    QMutexLocker lock(&mMutex);
    if(mLogFile) delete mLogFile;
    mLogFile = new QFile(path);
    mLogFile->open(QIODevice::WriteOnly | QIODevice::Append | QIODevice::Text);
}

void Logger::disableFileLogging() {
    QMutexLocker lock(&mMutex);
    if(mLogFile) { mLogFile->close(); delete mLogFile; mLogFile = nullptr; }
}

void Logger::log(const LogEntry& entry) {
    if(!logLevelIsAtLeast(entry.level, mMinLevel)) return;
    const QString line = mJsonMode ? entry.formatJson() : entry.format();
    QMutexLocker lock(&mMutex);
    std::cerr << line.toUtf8().constData() << std::endl;
    if(mLogFile && mLogFile->isOpen()) {
        QTextStream ts(mLogFile); ts << line << "\n"; ts.flush();
    }
    if(entry.level == LogLevel::FATAL) { std::cerr.flush(); std::abort(); }
}

void Logger::log(LogLevel level, const char* file, int line,
                 const char* func, const QString& msg) {
    LogEntry entry;
    entry.level = level;
    entry.timestamp = QDateTime::currentDateTime();
    entry.pid = getpid();
    entry.tid = syscall(SYS_gettid);
    entry.file = file;
    entry.line = line;
    entry.func = func;
    entry.msg = msg;
    entry.exFile = nullptr;
    entry.exLine = 0;
    entry.exFunc = nullptr;
    log(entry);
}

void Logger::logException(LogLevel level, const char* file, int line,
                          const char* func, const char* exFile,
                          int exLine, const char* exFunc, const QString& exMsg) {
    LogEntry entry;
    entry.level = level;
    entry.timestamp = QDateTime::currentDateTime();
    entry.pid = getpid();
    entry.tid = syscall(SYS_gettid);
    entry.file = file;
    entry.line = line;
    entry.func = func;
    entry.msg.clear();
    entry.exFile = exFile;
    entry.exLine = exLine;
    entry.exFunc = exFunc;
    entry.exMsg = exMsg;
    log(entry);
}

void Logger::logEnvironment() {
    const auto ts = QDateTime::currentDateTime();
    const qint64 p = getpid(), t = syscall(SYS_gettid);

    log(LogLevel::INFO, "main.cpp", 0, "main",
        QString("ENVIRONMENT os=%1 kernel=%2 arch=%3 qt=%4 cpu=%5")
            .arg(QSysInfo::prettyProductName(),
                 QSysInfo::kernelVersion(),
                 QSysInfo::currentCpuArchitecture(),
                 qVersion(),
                 QString::number(QThread::idealThreadCount())));

    if(QCoreApplication::instance()) {
        log(LogLevel::INFO, "main.cpp", 0, "main",
            QString("PROCESS argv=[%1] cwd=%2")
                .arg(QCoreApplication::arguments().join("],["),
                     QDir::currentPath()));
    }
}

void Logger::installCrashHandler() {
    signal(SIGSEGV, crashHandler);
    signal(SIGABRT, crashHandler);
    signal(SIGFPE,  crashHandler);
}

void Logger::crashHandler(int sig) {
    const char* name = "UNKNOWN";
    if(sig == SIGSEGV) name = "SIGSEGV";
    else if(sig == SIGABRT) name = "SIGABRT";
    else if(sig == SIGFPE)  name = "SIGFPE";

    std::cerr << "\n========== CRASH ==========\n"
              << "signal: " << sig << " (" << name << ")\n"
              << "pid: " << getpid() << " tid: " << (long)syscall(SYS_gettid) << "\n"
              << "=== BACKTRACE ===\n";

    void* buffer[BACKTRACE_DEPTH];
    int nptrs = backtrace(buffer, BACKTRACE_DEPTH);
    char** symbols = backtrace_symbols(buffer, nptrs);
    if(symbols) {
        for(int i = 0; i < nptrs; ++i)
            std::cerr << "  #" << i << "  " << symbols[i] << "\n";
        free(symbols);
    } else {
        std::cerr << "  (backtrace unavailable)\n";
    }
    std::cerr << "===========================" << std::endl;
    signal(sig, SIG_DFL);
    raise(sig);
}

void EnveLogStream::flush() {
    if(!active) return;
    Logger::instance().log(level, file, line, func,
                           QString::fromStdString(stream.str()));
    active = false;
}
