#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>

#include "controller.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    app.setOrganizationName("PhillipHaeusler");
    app.setOrganizationDomain("philliphaeusler.com");
    app.setApplicationName("RelayTimers");

    qmlRegisterType<Controller>("lib", 1, 0, "Controller");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));

    return app.exec();
}
