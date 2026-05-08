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
#include <iostream>

QString LogEntry::format() const {
    const char* base = strrchr(file, '/');
    const char* fname = base ? base + 1 : file;

    char buf[256];
    snprintf(buf, sizeof(buf), "[%s.%03d] [%s] [%s:%03d] %s() — %s",
             timestamp.toString("yyyy-MM-ddTHH:mm:ss").toUtf8().constData(),
             int(timestamp.time().msec()),
             logLevelLabel(level),
             fname, line,
             func,
             message.toUtf8().constData());
    return QString::fromUtf8(buf);
}

QString LogEntry::formatJson() const {
    const char* base = strrchr(file, '/');
    const char* fname = base ? base + 1 : file;

    QJsonObject obj;
    obj["ts"] = timestamp.toString(Qt::ISODateWithMs);
    obj["level"] = logLevelLabel(level);
    obj["file"] = fname;
    obj["line"] = line;
    obj["func"] = func;
    obj["msg"] = message;

    return QString::fromUtf8(
        QJsonDocument(obj).toJson(QJsonDocument::Compact));
}

Logger& Logger::instance() {
    static Logger s;
    return s;
}

Logger::Logger() {
}

Logger::~Logger() {
    disableFileLogging();
}

void Logger::enableFileLogging(const QString& path) {
    QMutexLocker lock(&mMutex);
    if(mLogFile) delete mLogFile;
    mLogFile = new QFile(path);
    if(mLogFile->open(QIODevice::WriteOnly | QIODevice::Append | QIODevice::Text)) {
        ENVE_LOG_INFO() << "=== enve log started ===";
    }
}

void Logger::disableFileLogging() {
    QMutexLocker lock(&mMutex);
    if(mLogFile) {
        mLogFile->close();
        delete mLogFile;
        mLogFile = nullptr;
    }
}

void Logger::log(const LogEntry& entry) {
    if(!logLevelIsAtLeast(entry.level, mMinLevel)) return;

    const QString line = mJsonMode ? entry.formatJson() : entry.format();

    QMutexLocker lock(&mMutex);

    // Always write to stderr
    std::cerr << line.toUtf8().constData() << std::endl;

    // Optionally write to file
    if(mLogFile && mLogFile->isOpen()) {
        QTextStream ts(mLogFile);
        ts << line << "\n";
        ts.flush();
    }
}

void Logger::log(LogLevel level, const char* file, int line,
                 const char* func, const QString& msg) {
    LogEntry entry;
    entry.level = level;
    entry.timestamp = QDateTime::currentDateTime();
    entry.file = file;
    entry.line = line;
    entry.func = func;
    entry.message = msg;
    log(entry);
}

void EnveLogStream::flush() {
    if(!active) return;
    const QString msg = QString::fromStdString(stream.str());
    Logger::instance().log(level, file, line, func, msg);
    active = false;
}
