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

#ifndef COMMANDREGISTRY_H
#define COMMANDREGISTRY_H

#include "core_global.h"
#include <QHash>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>
#include <QString>
#include <QMutex>
#include <memory>
#include <functional>

class CommandHandler;

class CORE_EXPORT CommandRegistry {
public:
    static CommandRegistry& instance();

    using HandlerPtr = std::shared_ptr<CommandHandler>;
    using DispatchFn = std::function<QJsonObject(const QJsonObject&)>;

    // Simple handler (no class needed) — for built-in commands
    void registerCommand(const QString& name, DispatchFn fn);

    // Handler class — for complex commands needing state
    void registerHandler(const QString& name, HandlerPtr handler);

    // Process a command: {cmd: "name", args: {...}} or {cmd:"name", args:[...]}
    QJsonObject process(const QJsonObject& entry);

    // Process raw JSON string → JSON result string
    QString processLine(const QByteArray& line);

    QJsonObject processLineJson(const QByteArray& line);

    void setEnabled(bool enabled) { mEnabled = enabled; }
    bool isEnabled() const { return mEnabled; }

private:
    CommandRegistry() {}
    QHash<QString, DispatchFn> mCommands;
    QHash<QString, HandlerPtr> mHandlers;
    QMutex mMutex;
    bool mEnabled = false;
};

// Abstract handler — implement to add a command
class CORE_EXPORT CommandHandler {
public:
    virtual ~CommandHandler() = default;
    virtual QString name() const = 0;
    virtual QJsonObject execute(const QJsonObject& args) = 0;

    // Optional: return help description for 'help' command
    virtual QString help() const { return QString(); }
};

CORE_EXPORT QJsonObject cmdEcho(const QJsonObject& args);
CORE_EXPORT QJsonObject cmdHelp(const QJsonObject& args);

#endif // COMMANDREGISTRY_H