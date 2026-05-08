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

#ifndef LOGGER_H
#define LOGGER_H

#include "core_global.h"
#include <QDebug>
#include <QString>
#include <QDateTime>
#include <QFile>
#include <QMutex>
#include <QThread>
#include <QProcess>
#include <chrono>
#include <sstream>

enum class LogLevel {
    TRACE = 0,
    DEBUG = 1,
    INFO  = 2,
    WARN  = 3,
    ERROR = 4,
    FATAL = 5
};

inline const char* logLevelLabel(LogLevel lv) {
    switch(lv) {
        case LogLevel::TRACE: return "TRACE";
        case LogLevel::DEBUG: return "DEBUG";
        case LogLevel::INFO:  return "INFO ";
        case LogLevel::WARN:  return "WARN ";
        case LogLevel::ERROR: return "ERROR";
        case LogLevel::FATAL: return "FATAL";
    }
    return "?????";
}

inline bool logLevelIsAtLeast(LogLevel current, LogLevel minimum) {
    return static_cast<int>(current) >= static_cast<int>(minimum);
}

struct CORE_EXPORT LogEntry {
    LogLevel        level;
    QDateTime       timestamp;
    qint64          pid;
    qint64          tid;
    const char*     file;
    int             line;
    const char*     func;
    QString         msg;
    const char*     exFile;
    int             exLine;
    const char*     exFunc;
    QString         exMsg;

    LogEntry()
        : level(LogLevel::INFO), pid(0), tid(0),
          file("?"), line(0), func("?"),
          exFile(nullptr), exLine(0), exFunc(nullptr) {}

    QString format() const;
    QString formatJson() const;
};

class CORE_EXPORT Logger {
public:
    static Logger& instance();

    void setMinimumLevel(LogLevel lv) { mMinLevel = lv; }
    LogLevel minimumLevel() const { return mMinLevel; }

    void enableFileLogging(const QString& path);
    void disableFileLogging();

    void setJsonMode(bool enabled) { mJsonMode = enabled; }
    bool jsonMode() const { return mJsonMode; }

    void log(const LogEntry& entry);

    void log(LogLevel level, const char* file, int line,
             const char* func, const QString& msg);

    void logException(LogLevel level, const char* file, int line,
                      const char* func, const char* exFile,
                      int exLine, const char* exFunc, const QString& exMsg);

    void logEnvironment();

    void installCrashHandler();

    static void crashHandler(int sig);

private:
    Logger();
    ~Logger();
    LogLevel mMinLevel = LogLevel::TRACE;
    bool mJsonMode = false;
    QFile* mLogFile = nullptr;
    QMutex mMutex;
};

// Log Macros
#define ENVE_LOG_TRACE(msg) \
    do { Logger::instance().log(LogLevel::TRACE, __FILE__, __LINE__, __func__, msg); } while(0)

#define ENVE_LOG_DEBUG(msg) \
    do { Logger::instance().log(LogLevel::DEBUG, __FILE__, __LINE__, __func__, msg); } while(0)

#define ENVE_LOG_INFO(msg) \
    do { Logger::instance().log(LogLevel::INFO, __FILE__, __LINE__, __func__, msg); } while(0)

#define ENVE_LOG_WARN(msg) \
    do { Logger::instance().log(LogLevel::WARN, __FILE__, __LINE__, __func__, msg); } while(0)

#define ENVE_LOG_ERROR(msg) \
    do { Logger::instance().log(LogLevel::ERROR, __FILE__, __LINE__, __func__, msg); } while(0)

#define ENVE_LOG_FATAL(msg) \
    do { Logger::instance().log(LogLevel::FATAL, __FILE__, __LINE__, __func__, msg); } while(0)

#define ENVE_LOG(LEVEL) \
    for(::EnveLogStream _ls__(LEVEL, __FILE__, __LINE__, __func__); \
        _ls__; _ls__.flush()) \
    _ls__.stream

struct CORE_EXPORT EnveLogStream {
    LogLevel level;
    const char* file;
    int line;
    const char* func;
    std::ostringstream stream;
    bool active;

    EnveLogStream(LogLevel lv, const char* f, int l, const char* fn)
        : level(lv), file(f), line(l), func(fn),
          active(logLevelIsAtLeast(lv, Logger::instance().minimumLevel())) {}

    ~EnveLogStream() { if(active) flush(); }

    template<typename T>
    EnveLogStream& operator<<(const T& val) {
        if(active) stream << val;
        return *this;
    }

    void flush();

    operator bool() const { return active; }
};

#endif // LOGGER_H
