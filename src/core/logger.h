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
#include <chrono>
#include <sstream>

// ============================================================
// Log Levels (matching syslog conventions)
// ============================================================
enum class LogLevel {
    TRACE = 0,   // Verbose internal state transitions
    DEBUG = 1,   // Debugging details
    INFO  = 2,   // Normal operational messages
    WARN  = 3,   // Warning conditions
    ERROR = 4,   // Recoverable errors
    FATAL = 5    // Unrecoverable errors (will abort)
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

// ============================================================
// Structured Log Entry
// ============================================================
struct CORE_EXPORT LogEntry {
    LogLevel        level;
    QDateTime       timestamp;
    const char*     file;       // source filename (basename)
    int             line;       // source line number
    const char*     func;       // function name
    QString         message;

    // Returns the structured text format:
    //   [2026-05-07T12:34:56.789] [ERROR] [gputaskexecutor.cpp:061] initCtx() — msg
    QString format() const;

    // Returns JSON format for AI consumption:
    //   {"ts":"...","level":"ERROR","file":"gputaskexecutor.cpp","line":61,"func":"initCtx","msg":"..."}
    QString formatJson() const;
};

// ============================================================
// Logger singleton
// ============================================================
class CORE_EXPORT Logger {
public:
    static Logger& instance();

    void setMinimumLevel(LogLevel lv) { mMinLevel = lv; }
    LogLevel minimumLevel() const { return mMinLevel; }

    // Enable file-based logging in addition to stderr
    void enableFileLogging(const QString& path);
    void disableFileLogging();

    // Enable JSON structured output (for AI consumption)
    void setJsonMode(bool enabled) { mJsonMode = enabled; }
    bool jsonMode() const { return mJsonMode; }

    // Main log dispatch
    void log(const LogEntry& entry);

    // Convenience: with stream-style message building
    void log(LogLevel level, const char* file, int line,
             const char* func, const QString& msg);

private:
    Logger();
    ~Logger();
    LogLevel mMinLevel = LogLevel::DEBUG;
    bool mJsonMode = false;
    QFile* mLogFile = nullptr;
    QMutex mMutex;
};

// ============================================================
// Log Macros (drop-in for existing code)
// ============================================================

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

// Stream-style: ENVE_LOG(LogLevel::INFO) << "value=" << x;
#define ENVE_LOG(LEVEL) \
    for(::EnveLogStream _ls__(LEVEL, __FILE__, __LINE__, __func__); \
        _ls__; _ls__.flush()) \
    _ls__.stream

// Internal helper class for stream-style logging
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
