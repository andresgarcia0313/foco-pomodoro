// Application bootstrap that cxx-qt-lib 0.10 does not cover: QApplication (needed by the
// native SystemTrayIcon on Windows and macOS), the Basic style and the QML engine.
#include <QtCore/QTimer>
#include <QtCore/QUrl>
#include <QtGui/QIcon>
#include <QtQml/QQmlApplicationEngine>
#include <QtQuickControls2/QQuickStyle>
#include <QtWidgets/QApplication>

namespace {
int app_argc = 0;
}

extern "C" void foco_app_new(int argc, char **argv) {
    app_argc = argc;
    auto *app = new QApplication(app_argc, argv);
    app->setApplicationName(QStringLiteral("Foco"));
    app->setOrganizationName(QStringLiteral("ingeniumcodex"));
    app->setOrganizationDomain(QStringLiteral("ingeniumcodex.com"));
    app->setDesktopFileName(QStringLiteral("com.ingeniumcodex.foco"));
    // The window may hide to the tray; QML decides when the app really quits.
    app->setQuitOnLastWindowClosed(false);
    QQuickStyle::setStyle(QStringLiteral("Basic"));
}

extern "C" int foco_app_run() {
    QApplication::setWindowIcon(QIcon(QStringLiteral(":/qt/qml/FocoApp/assets/foco.svg")));
    QQmlApplicationEngine engine;
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreationFailed, qApp,
        [] { QCoreApplication::exit(1); }, Qt::QueuedConnection);
    // Smoke tests and CI: quit on their own after the given milliseconds.
    if (qEnvironmentVariableIsSet("FOCO_AUTOQUIT_MS")) {
        QTimer::singleShot(qEnvironmentVariableIntValue("FOCO_AUTOQUIT_MS"), qApp,
                           &QCoreApplication::quit);
    }
    engine.load(QUrl(QStringLiteral("qrc:/qt/qml/FocoApp/qml/Main.qml")));
    return QApplication::exec();
}
