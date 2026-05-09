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

#include "commandhandlers.h"

#include <QApplication>
#include <QWidget>
#include <QMouseEvent>
#include <QKeyEvent>
#include <QBuffer>
#include <QImage>
#include "canvas.h"
#include "actions.h"
#include "Private/document.h"
#include "Animators/animator.h"
#include "Animators/qrealanimator.h"
#include "Boxes/containerbox.h"
#include "Boxes/rectangle.h"
#include "Boxes/circle.h"
#include "Boxes/textbox.h"
#include "Boxes/paintbox.h"
#include "Boxes/imagebox.h"
#include "svgexporter.h"
#include "logger.h"

static QWidget* findWidget(const QString& name) {
    if(name.isEmpty()) return nullptr;
    for(QWidget* w : QApplication::topLevelWidgets()) {
        if(w->objectName() == name) return w;
    }
    for(QWidget* w : QApplication::allWidgets()) {
        if(w->objectName() == name) return w;
    }
    return nullptr;
}

static Qt::MouseButton parseButton(const QString& s) {
    if(s == "right") return Qt::RightButton;
    if(s == "middle") return Qt::MiddleButton;
    if(s == "left" || s.isEmpty()) return Qt::LeftButton;
    return Qt::LeftButton;
}

static Qt::KeyboardModifiers parseModifiers(const QString& s) {
    Qt::KeyboardModifiers mod = Qt::NoModifier;
    if(s.isEmpty()) return mod;
    const QStringList parts = s.split(',');
    for(const QString& p : parts) {
        const QString t = p.trimmed();
        if(t == "shift") mod |= Qt::ShiftModifier;
        else if(t == "ctrl") mod |= Qt::ControlModifier;
        else if(t == "alt") mod |= Qt::AltModifier;
        else if(t == "meta") mod |= Qt::MetaModifier;
    }
    return mod;
}

static int parseKey(const QString& s) {
    if(s.isEmpty()) return 0;
    if(s.length() == 1) return s[0].toUpper().unicode();
    QMetaEnum keyEnum = QMetaEnum::fromType<Qt::Key>();
    return keyEnum.keyToValue(s.toUtf8().constData());
}

static QWidget* findRootWidget(QWidget* w) {
    if(!w) return nullptr;
    while(w->parentWidget()) w = w->parentWidget();
    return w;
}

QJsonObject InjectEventHandler::execute(const QJsonObject& args) {
    const QString target = args.value("target").toString();
    const QString type = args.value("type").toString();
    QWidget* w = findWidget(target);

    if(!w) {
        return {{"ok", false}, {"error", QString("widget not found: %1").arg(target)}};
    }

    if(type == "mouse_press" || type == "mouse_move" || type == "mouse_release") {
        const int x = args.value("x").toInt();
        const int y = args.value("y").toInt();
        const auto button = parseButton(args.value("button").toString());
        const auto mods = parseModifiers(args.value("modifiers").toString());

        QEvent::Type evType;
        if(type == "mouse_press") evType = QEvent::MouseButtonPress;
        else if(type == "mouse_release") evType = QEvent::MouseButtonRelease;
        else evType = QEvent::MouseMove;

        QMouseEvent* ev = new QMouseEvent(
            evType, QPointF(x, y), QPointF(x, y),
            button, button, mods);
        QCoreApplication::postEvent(w, ev);
        return {{"ok", true}};
    }

    if(type == "key_press" || type == "key_release") {
        const int key = parseKey(args.value("key").toString());
        const auto mods = parseModifiers(args.value("modifiers").toString());
        QEvent::Type evType = (type == "key_press") ? QEvent::KeyPress : QEvent::KeyRelease;

        QKeyEvent* ev = new QKeyEvent(evType, key, mods);
        QCoreApplication::postEvent(w, ev);
        return {{"ok", true}};
    }

    return {{"ok", false}, {"error", QString("unknown event type: %1").arg(type)}};
}

QJsonObject ScreenshotHandler::execute(const QJsonObject& args) {
    const QString target = args.value("target").toString();
    QWidget* w = findWidget(target);
    if(!w) {
        return {{"ok", false}, {"error", QString("widget not found: %1").arg(target)}};
    }

    QPixmap pix = w->grab();
    QImage img = pix.toImage();
    QByteArray bytes;
    QBuffer buf(&bytes);
    buf.open(QIODevice::WriteOnly);
    img.save(&buf, "PNG");

    return {
        {"ok", true},
        {"format", "png"},
        {"width", img.width()},
        {"height", img.height()},
        {"data", QString::fromUtf8(bytes.toBase64())}
    };
}

static QJsonObject dumpWidgetTree(QWidget* w) {
    if(!w) return {};
    QJsonObject obj;
    obj["class"] = QString::fromUtf8(w->metaObject()->className());
    obj["name"] = w->objectName();
    obj["visible"] = w->isVisible();
    obj["geometry"] = QJsonObject{
        {"x", w->x()}, {"y", w->y()},
        {"w", w->width()}, {"h", w->height()}};
    if(w->isWindow()) obj["window_title"] = w->windowTitle();
    QJsonArray children;
    for(QObject* child : w->children()) {
        auto* cw = qobject_cast<QWidget*>(child);
        if(cw) children.append(dumpWidgetTree(cw));
    }
    if(!children.isEmpty()) obj["children"] = children;
    return obj;
}

QJsonObject StateHandler::execute(const QJsonObject& args) {
    const QString target = args.value("target").toString();
    QWidget* w = target.isEmpty() ? nullptr : findWidget(target);
    if(!w && !target.isEmpty()) {
        return {{"ok", false}, {"error", QString("widget not found: %1").arg(target)}};
    }

    QJsonObject result;
    result["ok"] = true;

    if(!w) {
        QJsonArray roots;
        for(QWidget* tw : QApplication::topLevelWidgets())
            roots.append(dumpWidgetTree(tw));
        result["top_level_widgets"] = roots;
    } else {
        result["widget"] = dumpWidgetTree(w);
    }

    if(Document::sInstance && Document::sInstance->fActiveScene) {
        Canvas* scene = Document::sInstance->fActiveScene.get();
        QJsonObject si;
        si["name"] = scene->prp_getName();
        si["width"] = scene->getCanvasWidth();
        si["height"] = scene->getCanvasHeight();
        si["fps"] = scene->getFps();
        si["frame_count"] = scene->getFrameCount();
        si["current_frame"] = Document::sInstance->getActiveSceneFrame();
        result["active_scene"] = si;
    }

    return result;
}

QJsonObject CanvasHandler::execute(const QJsonObject& args) {
    if(!Document::sInstance) {
        return {{"ok", false}, {"error", "no document"}};
    }

    const QString action = args.value("action").toString();

    if(action == "create") {
        const int width = args.value("width").toInt(1920);
        const int height = args.value("height").toInt(1080);
        const int fps = args.value("fps").toInt(30);
        Canvas* scene = Document::sInstance->createNewScene();
        scene->prp_setNameAction(QString("Scene %1x%2@%3").arg(width).arg(height).arg(fps));
        Document::sInstance->setActiveScene(scene);
        Document::sInstance->actionFinished();
        return {
            {"ok", true},
            {"scene", QJsonObject{
                {"ptr", QString("0x%1").arg(reinterpret_cast<quintptr>(scene), 0, 16)},
                {"width", width}, {"height", height}, {"fps", fps}}}
        };
    }

    if(action == "list") {
        QJsonArray scenes;
        for(const auto& s : Document::sInstance->fScenes) {
            QJsonObject si;
            si["name"] = s->prp_getName();
            si["ptr"] = QString("0x%1").arg(reinterpret_cast<quintptr>(s.get()), 0, 16);
            si["width"] = s->getCanvasWidth();
            si["height"] = s->getCanvasHeight();
            si["fps"] = s->getFps();
            scenes.append(si);
        }
        return {{"ok", true}, {"scenes", scenes}};
    }

    if(action == "set_active") {
        const QString ptrStr = args.value("canvas_id").toString();
        if(ptrStr.isEmpty()) {
            return {{"ok", false}, {"error", "missing canvas_id"}};
        }
        bool ok = false;
        quintptr ptr = ptrStr.toULongLong(&ok, 0);
        if(!ok) return {{"ok", false}, {"error", "invalid canvas_id (use ptr from list)"}};
        for(const auto& s : Document::sInstance->fScenes) {
            if(reinterpret_cast<quintptr>(s.get()) == ptr) {
                Document::sInstance->setActiveScene(s.get());
                return {{"ok", true}, {"name", s->prp_getName()}};
            }
        }
        return {{"ok", false}, {"error", "canvas not found"}};
    }

    if(action == "export") {
        const QString path = args.value("path").toString();
        if(path.isEmpty()) return {{"ok", false}, {"error", "missing path"}};
        if(!Document::sInstance->fActiveScene) {
            return {{"ok", false}, {"error", "no active scene"}};
        }
        Canvas* scene = Document::sInstance->fActiveScene.get();
        QFile file(path);
        if(!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
            return {{"ok", false}, {"error", "cannot open: " + path}};
        }
        QTextStream stream(&file);
        SvgExporter::exportToSvg(stream, scene);
        return {{"ok", true}};
    }

    return {{"ok", false}, {"error", QString("unknown action: %1").arg(action)}};
}

static QJsonObject triggerAction(const QString& name) {
    Actions* a = Actions::sInstance;
    if(!a) return {{"ok", false}, {"error", "no Actions instance"}};

    struct ActionEntry {
        const char* name;
        Action* Actions::*ptr;
    };

    static const ActionEntry actionTable[] = {
        {"delete", &Actions::deleteAction},
        {"copy", &Actions::copyAction},
        {"paste", &Actions::pasteAction},
        {"cut", &Actions::cutAction},
        {"duplicate", &Actions::duplicateAction},
        {"group", &Actions::groupAction},
        {"ungroup", &Actions::ungroupAction},
        {"undo", &Actions::undoAction},
        {"redo", &Actions::redoAction},
        {"raise", &Actions::raiseAction},
        {"lower", &Actions::lowerAction},
        {"raise_to_top", &Actions::raiseToTopAction},
        {"lower_to_bottom", &Actions::lowerToBottomAction},
        {"rotate_cw", &Actions::rotate90CWAction},
        {"rotate_ccw", &Actions::rotate90CCWAction},
        {"flip_h", &Actions::flipHorizontalAction},
        {"flip_v", &Actions::flipVerticalAction},
        {"objects_to_path", &Actions::objectsToPathAction},
        {"stroke_to_path", &Actions::strokeToPathAction},
        {"union", &Actions::pathsUnionAction},
        {"difference", &Actions::pathsDifferenceAction},
        {"intersection", &Actions::pathsIntersectionAction},
        {"division", &Actions::pathsDivisionAction},
        {"exclusion", &Actions::pathsExclusionAction},
        {"combine", &Actions::pathsCombineAction},
        {"break_apart", &Actions::pathsBreakApartAction},
    };

    for(const auto& entry : actionTable) {
        if(name == entry.name) {
            Action* action = a->*entry.ptr;
            if(action && action->canExecute()) {
                action->execute();
                return {{"ok", true}};
            }
            return {{"ok", false}, {"error", "action not executable"}};
        }
    }
    return {{"ok", false}, {"error", QString("unknown action: %1").arg(name)}};
}

QJsonObject MenuHandler::execute(const QJsonObject& args) {
    return triggerAction(args.value("action").toString());
}

QJsonObject KeyframeHandler::execute(const QJsonObject& args) {
    Q_UNUSED(args)
    return {{"ok", false}, {
        "error", "keyframe: full implementation depends on animator path resolution. "
                 "Use 'menu' + 'inject_event' for keyframe creation via UI for now."}};
}

QJsonObject BoxHandler::execute(const QJsonObject& args) {
    if(!Document::sInstance || !Document::sInstance->fActiveScene) {
        return {{"ok", false}, {"error", "no active scene"}};
    }

    const QString action = args.value("action").toString();
    Canvas* scene = Document::sInstance->fActiveScene.get();

    if(action == "list") {
        QJsonArray boxes;
        for(int i = 0; i < scene->ca_getNumberOfChildren(); i++) {
            BoundingBox* box = scene->ca_getChild(i);
            if(!box) continue;
            QJsonObject bi;
            bi["name"] = box->prp_getName();
            bi["ptr"] = QString("0x%1").arg(reinterpret_cast<quintptr>(box), 0, 16);
            bi["type"] = QString::fromUtf8(box->metaObject()->className());
            bi["index"] = i;
            boxes.append(bi);
        }
        return {{"ok", true}, {"boxes", boxes}};
    }

    if(action == "add") {
        const QString type = args.value("type").toString();
        const int currentFrame = Document::sInstance->getActiveSceneFrame();

        BoundingBox* box = nullptr;
        if(type == "rectangle") {
            box = scene->createNewBox<RectangleBox>(currentFrame);
        } else if(type == "circle") {
            box = scene->createNewBox<CircleBox>(currentFrame);
        } else if(type == "text") {
            box = scene->createNewBox<TextBox>(currentFrame);
        } else {
            return {{"ok", false}, {"error", QString("unknown box type: %1").arg(type)}};
        }

        if(!box) {
            return {{"ok", false}, {"error", "failed to create box"}};
        }

        box->prp_setNameAction(type);
        Document::sInstance->actionFinished();
        return {
            {"ok", true},
            {"box", QJsonObject{
                {"ptr", QString("0x%1").arg(reinterpret_cast<quintptr>(box), 0, 16)},
                {"type", type}}}
        };
    }

    return {{"ok", false}, {"error", QString("unknown action: %1").arg(action)}};
}