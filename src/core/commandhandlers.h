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

#ifndef COMMANDHANDLERS_H
#define COMMANDHANDLERS_H

#include "commandregistry.h"
#include <QWidget>
#include <QPixmap>

class InjectEventHandler : public CommandHandler {
public:
    QString name() const override { return "inject_event"; }
    QJsonObject execute(const QJsonObject& args) override;
    QString help() const override {
        return "Inject Qt event. args:{target:\"widgetName\",type:\"mouse_press|mouse_move|mouse_release|key_press|key_release\",x,y,button,key,modifiers}";
    }
};

class ScreenshotHandler : public CommandHandler {
public:
    QString name() const override { return "screenshot"; }
    QJsonObject execute(const QJsonObject& args) override;
    QString help() const override {
        return "Capture widget to base64 PNG. args:{target:\"widgetName\"}";
    }
};

class StateHandler : public CommandHandler {
public:
    QString name() const override { return "state"; }
    QJsonObject execute(const QJsonObject& args) override;
    QString help() const override {
        return "Dump widget tree. args:{target:\"widgetName\"|empty for root}";
    }
};

class CanvasHandler : public CommandHandler {
public:
    QString name() const override { return "canvas"; }
    QJsonObject execute(const QJsonObject& args) override;
    QString help() const override {
        return "Canvas ops. args:{action:'create'|'list'|'set_active'|'export',width,height,fps,canvas_id,path}";
    }
};

class MenuHandler : public CommandHandler {
public:
    QString name() const override { return "menu"; }
    QJsonObject execute(const QJsonObject& args) override;
    QString help() const override {
        return "Trigger menu action. args:{action:'delete'|'copy'|'paste'|'cut'|'duplicate'|'group'|'ungroup'|'undo'|'redo'|...}";
    }
};

class KeyframeHandler : public CommandHandler {
public:
    QString name() const override { return "keyframe"; }
    QJsonObject execute(const QJsonObject& args) override;
    QString help() const override {
        return "Keyframe ops. args:{action:\"add\",box_path,property,frame,value}";
    }
};

class BoxHandler : public CommandHandler {
public:
    QString name() const override { return "box"; }
    QJsonObject execute(const QJsonObject& args) override;
    QString help() const override {
        return "Box/layer ops. args:{action:\"add\"|\"list\",type:\"rectangle\"|\"circle\"|\"text\"|\"image\"|\"paint\",parent_path}";
    }
};

#endif // COMMANDHANDLERS_H