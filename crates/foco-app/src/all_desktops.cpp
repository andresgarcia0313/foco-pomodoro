// Break windows on every virtual desktop where the window manager leaves it to the app (KDE
// pins them through KWin, see kwin.rs). Windows are matched by title, as KWin matches them.
// - macOS: each window joins every Space, also those of full-screen apps. Qt has no flag for
//   it; the Objective-C runtime reaches the NSWindow behind the window when it is shown.
// - Windows: every second, IVirtualDesktopManager (the documented interface) tells whether a
//   window was left on another desktop; it is then created again on the one in use.
#include <QtCore/QTimer>
#include <QtGui/QGuiApplication>
#include <QtGui/QWindow>

namespace {
bool is_break(const QWindow *window) {
    return window->title().startsWith(QStringLiteral("Foco: descanso"));
}
}  // namespace

#if defined(Q_OS_MACOS)
#include <objc/message.h>
#include <objc/runtime.h>

namespace {
// NSWindowCollectionBehavior: CanJoinAllSpaces | Stationary | FullScreenAuxiliary.
constexpr unsigned long ALL_SPACES = (1UL << 0) | (1UL << 4) | (1UL << 8);

void join_all_spaces(QWindow *window) {
    auto *view = reinterpret_cast<id>(window->winId());
    auto get = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend);
    id ns_window = get(view, sel_registerName("window"));
    if (!ns_window) return;
    auto set = reinterpret_cast<void (*)(id, SEL, unsigned long)>(objc_msgSend);
    set(ns_window, sel_registerName("setCollectionBehavior:"), ALL_SPACES);
}

class BreakSpaces : public QObject {
  protected:
    bool eventFilter(QObject *watched, QEvent *event) override {
        auto *window = qobject_cast<QWindow *>(watched);
        if (window && event->type() == QEvent::Show && is_break(window)) join_all_spaces(window);
        return false;
    }
};
}  // namespace

void foco_all_desktops(QGuiApplication *app) { app->installEventFilter(new BreakSpaces); }

#elif defined(Q_OS_WIN)
#include <shobjidl.h>
#include <windows.h>
#pragma comment(lib, "ole32.lib")

namespace {
IVirtualDesktopManager *desktops() {
    static IVirtualDesktopManager *manager = [] {
        IVirtualDesktopManager *created = nullptr;
        CoCreateInstance(CLSID_VirtualDesktopManager, nullptr, CLSCTX_ALL,
                         IID_PPV_ARGS(&created));
        return created;
    }();
    return manager;
}

bool on_current_desktop(QWindow *window) {
    BOOL current = TRUE;
    auto *manager = desktops();
    if (!manager) return true;
    auto hwnd = reinterpret_cast<HWND>(window->winId());
    return FAILED(manager->IsWindowOnCurrentVirtualDesktop(hwnd, &current)) || current;
}

void follow_desktop() {
    for (QWindow *window : QGuiApplication::topLevelWindows()) {
        if (!window->isVisible() || !is_break(window) || on_current_desktop(window)) continue;
        // Windows remembers the desktop of a window, also hidden: a new native window opens on
        // the desktop in use, so the old one is destroyed and cover() creates it again.
        window->destroy();
        QMetaObject::invokeMethod(window, "cover");  // BreakWindow.qml, back on its screen
    }
}
}  // namespace

void foco_all_desktops(QGuiApplication *app) {
    auto *timer = new QTimer(app);
    QObject::connect(timer, &QTimer::timeout, app, follow_desktop);
    timer->start(1000);
}

#else
void foco_all_desktops(QGuiApplication *) {}
#endif
