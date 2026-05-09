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

#include "commandregistry.h"
#include "logger.h"

// --- Singleton ---

CommandRegistry& CommandRegistry::instance() {
    static CommandRegistry reg;
    return reg;
}

// --- Registration ---

void CommandRegistry::registerCommand(const QString& name, DispatchFn fn) {
    QMutexLocker lock(&mMutex);
    mCommands[name] = std::move(fn);
}

void CommandRegistry::registerHandler(const QString& name, HandlerPtr handler) {
    QMutexLocker lock(&mMutex);
    mHandlers[name] = std::move(handler);
}

// --- Processing ---

QJsonObject CommandRegistry::process(const QJsonObject& entry) {
    if(!mEnabled) {
        return {{"ok", false}, {"error", "AI commands disabled (ENVE_AI not set)"}};
    }

    const QString cmd = entry.value("cmd").toString();
    const QJsonObject args = entry.value("args").toObject();

    if(cmd.isEmpty()) {
        return {{"ok", false}, {"error", "missing 'cmd' field"}};
    }

    // Check handler classes first
    {
        QMutexLocker lock(&mMutex);
        auto it = mHandlers.find(cmd);
        if(it != mHandlers.end()) {
            lock.unlock();
            ENVE_LOG(LogLevel::DEBUG) << "AI cmd:" << cmd;
            return it.value()->execute(args);
        }
    }

    // Check simple command functions
    {
        QMutexLocker lock(&mMutex);
        auto it = mCommands.find(cmd);
        if(it != mCommands.end()) {
            lock.unlock();
            ENVE_LOG(LogLevel::DEBUG) << "AI cmd:" << cmd;
            return it.value()(args);
        }
    }

    ENVE_LOG(LogLevel::WARN) << "AI unknown cmd:" << cmd;
    return {{"ok", false}, {"error", QString("unknown command: %1").arg(cmd)}};
}

QJsonObject CommandRegistry::processLineJson(const QByteArray& line) {
    QJsonParseError err;
    const QJsonDocument doc = QJsonDocument::fromJson(line, &err);
    if(err.error != QJsonParseError::NoError) {
        return {{"ok", false}, {"error", "parse: " + err.errorString()}};
    }
    if(!doc.isObject()) {
        return {{"ok", false}, {"error", "parse: not a JSON object"}};
    }
    const QJsonObject result = process(doc.object());
    return result;
}

QString CommandRegistry::processLine(const QByteArray& line) {
    return QString::fromUtf8(
        QJsonDocument(processLineJson(line)).toJson(QJsonDocument::Compact));
}

// --- Built-in Commands ---

QJsonObject cmdEcho(const QJsonObject& args) {
    QJsonObject result;
    result["ok"] = true;
    result["echo"] = args;
    return result;
}

QJsonObject cmdHelp(const QJsonObject& args) {
    Q_UNUSED(args)
    QJsonArray cmds;
    {
        QMutexLocker lock(&CommandRegistry::instance().mMutex);
        for(auto it = CommandRegistry::instance().mHandlers.begin();
            it != CommandRegistry::instance().mHandlers.end(); ++it) {
            QJsonObject info;
            info["name"] = it.key();
            const QString h = it.value()->help();
            if(!h.isEmpty()) info["help"] = h;
            info["type"] = "handler";
            cmds.append(info);
        }
        for(auto it = CommandRegistry::instance().mCommands.begin();
            it != CommandRegistry::instance().mCommands.end(); ++it) {
            QJsonObject info;
            info["name"] = it.key();
            info["type"] = "function";
            cmds.append(info);
        }
    }
    return {{"ok", true}, {"commands", cmds}};
}