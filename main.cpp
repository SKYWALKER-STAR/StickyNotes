#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "CommandManager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    CommandManager commandManager;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("commandManager", &commandManager);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("cpaste_quick", "Main");

    return app.exec();
}
