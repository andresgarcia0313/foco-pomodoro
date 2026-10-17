// macOS: break windows join every Space (virtual desktop), including those of full-screen
// apps, so changing Space does not leave the break behind. Qt has no flag for it; the
// Objective-C runtime reaches the NSWindow behind each window when it is first shown.
#include <QtGui/QGuiApplication>
#include <QtGui/QWindow>

#ifdef Q_OS_MACOS
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

// Matched by title, as KWin matches them on Linux (BreakWindow.qml).
class BreakSpaces : public QObject {
  protected:
    bool eventFilter(QObject *watched, QEvent *event) override {
        auto *window = qobject_cast<QWindow *>(watched);
        if (window && event->type() == QEvent::Show &&
            window->title().startsWith(QStringLiteral("Foco: descanso"))) {
            join_all_spaces(window);
        }
        return false;
    }
};
}  // namespace

void foco_join_all_spaces(QGuiApplication *app) { app->installEventFilter(new BreakSpaces); }
#else
void foco_join_all_spaces(QGuiApplication *) {}
#endif
