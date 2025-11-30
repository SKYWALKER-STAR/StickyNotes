#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QTimer>
#include <QQmlEngine>
#include "CommandManager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    CommandManager commandManager;

    QQmlApplicationEngine engine;

    // 推荐：注册为 QML 单例
    qmlRegisterSingletonInstance("CommandManager", 1, 0, "CommandManager", &commandManager);

    // 如果仍想保留上下文属性，也可以同时设置（可选）
    engine.rootContext()->setContextProperty("commandManager", &commandManager);

    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { QCoreApplication::exit(-1); }, Qt::QueuedConnection);

    engine.loadFromModule("cpaste_quick", "Main");

    // Initialize data asynchronously after UI is shown
    QTimer::singleShot(0, &commandManager, &CommandManager::initialize);
    return app.exec();
}
