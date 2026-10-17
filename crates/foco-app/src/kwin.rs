//! Keep-above and screen placement on KDE Plasma Wayland. xdg-shell does not let a window raise
//! or place itself, so a tiny KWin script acts on our own windows, matched by process id and
//! title. Other platforms honour Qt's hints and screen, so this does nothing there.

#[cfg(target_os = "linux")]
pub fn keep_above(title: String, on: bool) {
    let pid = std::process::id();
    run(format!(
        "for (const w of workspace.windowList()) \
         if (w.pid === {pid} && w.caption === {title:?}) w.keepAbove = {on};"
    ));
}

/// Break screen: our window titled `title` goes full screen, above all, on output `screen`;
/// `focus` also activates it, so Esc and Enter reach it.
#[cfg(target_os = "linux")]
pub fn cover(title: String, screen: String, focus: bool) {
    let pid = std::process::id();
    let activate = if focus {
        "workspace.activeWindow = w;"
    } else {
        ""
    };
    run(format!(
        "const out = workspace.screens.find(o => o.name === {screen:?}); \
         for (const w of workspace.windowList()) \
         if (w.pid === {pid} && w.caption === {title:?}) {{ \
         if (out) workspace.sendClientToScreen(w, out); \
         w.keepAbove = true; w.fullScreen = true; {activate} }}"
    ));
}

#[cfg(target_os = "linux")]
fn run(script: String) {
    let kde = std::env::var("XDG_CURRENT_DESKTOP").is_ok_and(|d| d.contains("KDE"));
    if !kde || std::env::var_os("WAYLAND_DISPLAY").is_none() {
        return;
    }
    // D-Bus round trips stay off the Qt thread; a failure only means the hint is not applied.
    std::thread::spawn(move || {
        if let Err(err) = run_script(&script) {
            eprintln!("foco: KWin no aplicó el guion: {err}");
        }
    });
}

#[cfg(target_os = "linux")]
fn run_script(script: &str) -> Result<(), Box<dyn std::error::Error>> {
    const KWIN: Option<&str> = Some("org.kde.KWin");
    const SCRIPTING: Option<&str> = Some("org.kde.kwin.Scripting");
    // Each run gets its own name: KWin refuses a second script loaded under a name in use.
    static RUNS: std::sync::atomic::AtomicU32 = std::sync::atomic::AtomicU32::new(0);
    let run = RUNS.fetch_add(1, std::sync::atomic::Ordering::Relaxed);
    let name = format!("foco-{}-{run}", std::process::id());
    // Private per-user folder (0700): a shared /tmp would let another user plant the script.
    let path = dirs::runtime_dir()
        .ok_or("sin XDG_RUNTIME_DIR")?
        .join(format!("{name}.js"));
    std::fs::write(&path, script)?;
    let bus = zbus::blocking::Connection::session()?;
    let script = path.to_string_lossy().into_owned();
    let reply = bus.call_method(
        KWIN,
        "/Scripting",
        SCRIPTING,
        "loadScript",
        &(script, &name),
    )?;
    let id: i32 = reply.body().deserialize()?;
    let object = format!("/Scripting/Script{id}");
    bus.call_method(
        KWIN,
        object.as_str(),
        Some("org.kde.kwin.Script"),
        "run",
        &(),
    )?;
    bus.call_method(KWIN, "/Scripting", SCRIPTING, "unloadScript", &(&name,))?;
    let _ = std::fs::remove_file(path);
    Ok(())
}

#[cfg(not(target_os = "linux"))]
pub fn keep_above(_title: String, _on: bool) {}

#[cfg(not(target_os = "linux"))]
pub fn cover(_title: String, _screen: String, _focus: bool) {}
