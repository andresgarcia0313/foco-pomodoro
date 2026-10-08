//! Keep-above on KDE Plasma Wayland. xdg-shell does not let a window raise itself, so a tiny
//! KWin script sets `keepAbove` on our own windows, matched by process id and title. Other
//! platforms honour Qt's `WindowStaysOnTopHint`, so this does nothing there.

#[cfg(target_os = "linux")]
pub fn keep_above(title: String, on: bool) {
    let kde = std::env::var("XDG_CURRENT_DESKTOP").is_ok_and(|d| d.contains("KDE"));
    if !kde || std::env::var_os("WAYLAND_DISPLAY").is_none() {
        return;
    }
    // D-Bus round trips stay off the Qt thread; a failure only means the hint is not applied.
    std::thread::spawn(move || {
        if let Err(err) = run_script(&title, on) {
            eprintln!("foco: KWin no aplicó siempre visible: {err}");
        }
    });
}

#[cfg(target_os = "linux")]
fn run_script(title: &str, on: bool) -> Result<(), Box<dyn std::error::Error>> {
    const KWIN: Option<&str> = Some("org.kde.KWin");
    const SCRIPTING: Option<&str> = Some("org.kde.kwin.Scripting");
    let pid = std::process::id();
    let name = format!("foco-above-{pid}");
    // Private per-user folder (0700): a shared /tmp would let another user plant the script.
    let path = dirs::runtime_dir()
        .ok_or("sin XDG_RUNTIME_DIR")?
        .join(format!("{name}.js"));
    std::fs::write(
        &path,
        format!(
            "for (const w of workspace.windowList()) \
             if (w.pid === {pid} && w.caption === {title:?}) w.keepAbove = {on};"
        ),
    )?;
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
