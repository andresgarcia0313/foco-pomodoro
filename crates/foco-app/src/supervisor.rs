//! Keeps Foco alive. The window runs in a child process; when it crashes or its event loop
//! stops beating it is started again, and `store::init` resumes the saved phase. A quit,
//! or a kill by the user or the session, is respected. The parent only waits: no Qt runs in it.

use std::io::{Read, Write};
use std::process::{Command, Stdio};
use std::sync::{Arc, Mutex};
use std::time::{Duration, Instant};

const CHILD: &str = "FOCO_SUPERVISED";
/// Beats come every 5 s; this long without one means the interface hung.
const HANG: Duration = Duration::from_secs(45);
const MAX_RESTARTS: usize = 5;
const RESTART_WINDOW: Duration = Duration::from_secs(600);

/// In the parent, supervises and returns the exit code; in the child (or with
/// `FOCO_NO_SUPERVISOR`), returns `None` so `main` runs the app itself.
pub fn run() -> Option<i32> {
    if std::env::var_os(CHILD).is_some() || std::env::var_os("FOCO_NO_SUPERVISOR").is_some() {
        return None;
    }
    let exe = std::env::current_exe().ok()?;
    let mut restarts: Vec<Instant> = Vec::new();
    loop {
        let mut cmd = Command::new(&exe);
        cmd.args(std::env::args_os().skip(1))
            .env(CHILD, "1")
            .stdout(Stdio::piped());
        if !restarts.is_empty() {
            cmd.env("FOCO_RESTARTED", "1");
        }
        let Ok(mut child) = cmd.spawn() else {
            return None;
        };
        let last_beat = Arc::new(Mutex::new(Instant::now()));
        if let Some(mut out) = child.stdout.take() {
            let last_beat = Arc::clone(&last_beat);
            std::thread::spawn(move || {
                let mut byte = [0u8; 64];
                while matches!(out.read(&mut byte), Ok(n) if n > 0) {
                    *last_beat.lock().unwrap_or_else(|e| e.into_inner()) = Instant::now();
                }
            });
        }
        let mut seen = Instant::now();
        let status = loop {
            if let Ok(Some(status)) = child.try_wait() {
                break Some(status);
            }
            std::thread::sleep(Duration::from_secs(1));
            let mut beat = last_beat.lock().unwrap_or_else(|e| e.into_inner());
            // We were frozen too (cgroup freeze, suspend): give the child a fresh window.
            if seen.elapsed() > Duration::from_secs(5) {
                *beat = Instant::now();
            }
            seen = Instant::now();
            if beat.elapsed() > HANG {
                eprintln!("foco: la interfaz dejó de responder; se reinicia");
                let _ = child.kill();
                let _ = child.wait();
                break None;
            }
        };
        if let Some(status) = status.filter(|s| !crashed(s)) {
            return Some(status.code().unwrap_or(0));
        }
        restarts.retain(|t| t.elapsed() < RESTART_WINDOW);
        if restarts.len() >= MAX_RESTARTS {
            eprintln!("foco: demasiados reinicios seguidos; se detiene");
            return Some(1);
        }
        restarts.push(Instant::now());
    }
}

/// A crash, not a decision: fatal signals on Unix, a non-zero code everywhere.
fn crashed(status: &std::process::ExitStatus) -> bool {
    #[cfg(unix)]
    {
        use std::os::unix::process::ExitStatusExt;
        // SIGILL, SIGABRT, SIGBUS, SIGFPE, SIGSEGV; SIGTERM and SIGKILL are respected.
        if let Some(signal) = status.signal() {
            return [4, 6, 7, 8, 11].contains(&signal);
        }
    }
    !status.success()
}

/// Called by the interface every few seconds; only a supervised child writes anything.
pub fn beat() {
    if std::env::var_os(CHILD).is_some() {
        let mut out = std::io::stdout();
        let _ = out.write_all(b".").and_then(|()| out.flush());
    }
}

pub fn restarted() -> bool {
    std::env::var_os("FOCO_RESTARTED").is_some()
}
