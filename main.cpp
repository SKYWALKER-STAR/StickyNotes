#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QTimer>
#include <QQmlEngine>
#include <QDebug> // 引入 qDebug
#include "CommandManager.h"

int main(int argc, char *argv[])
{
    qDebug() << "Starting application..."; // 添加调试日志

    QGuiApplication app(argc, argv);

    qDebug() << "QGuiApplication initialized.";

    CommandManager commandManager;
    qDebug() << "CommandManager instance created.";

    QQmlApplicationEngine engine;

    // 注册为 QML 单例
    if (qmlRegisterSingletonInstance("CommandManager", 1, 0, "CommandManager", &commandManager)) {
        qDebug() << "CommandManager registered as QML singleton successfully.";
    } else {
        qCritical() << "Failed to register CommandManager as QML singleton!";
    }

    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { 
            qCritical() << "QML object creation failed!";
            QCoreApplication::exit(-1); 
        }, Qt::QueuedConnection);

    qDebug() << "Loading Main.qml...";
    
    //const QUrl url(QStringLiteral(u"qrc:/qt/qml/cpaste_quick/qml/Main.qml"));
    engine.loadFromModule("cpaste_quick", "Main");
    //engine.loadFromModule("cpaste_quick", "qml/Main");
    //engine.load(url);
    if (engine.rootObjects().isEmpty()) {
        qCritical() << "Failed to load Main.qml!";
        return -1;
    } else {
        qDebug() << "Main.qml loaded successfully.";
    }

    // Initialize data asynchronously after UI is shown
    qDebug() << "Initializing CommandManager...";
    QTimer::singleShot(0, &commandManager, &CommandManager::initialize);

    qDebug() << "Starting event loop...";
    return app.exec();
}
