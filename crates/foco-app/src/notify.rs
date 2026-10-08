//! Native notification at the end of a phase (RF-04), with the copy from `textos.md`.
//! On Linux it carries an action that starts the next phase.

use foco_core::{
    settings::Settings,
    timer::{Phase, PhaseEnd},
};

pub struct Message {
    title: String,
    body: String,
    action: Option<&'static str>,
}

pub fn message(end: &PhaseEnd, s: &Settings, cycle_done: u32) -> Message {
    let (title, body, action) = match end.finished {
        Phase::Focus => {
            let rest = end.next.duration(s).as_secs() / 60;
            let body = format!("Llevas {cycle_done} de {}. Toca descansar {rest} min.", s.long_break_every);
            ("Enfoque terminado", body, "Iniciar descanso")
        }
        Phase::ShortBreak => {
            let body = format!("Listo para otro enfoque de {} min.", s.focus_minutes);
            ("Descanso terminado", body, "Iniciar enfoque")
        }
        Phase::LongBreak => {
            let body = "Buen trabajo. Empieza un ciclo nuevo cuando quieras.".to_owned();
            ("Ciclo completo", body, "Iniciar enfoque")
        }
    };
    Message {
        title: title.to_owned(),
        body,
        action: (!end.auto_started).then_some(action),
    }
}

/// Shows the notification off the Qt thread; `start_next` runs if the action is chosen.
pub fn show(message: Message, start_next: impl FnOnce() + Send + 'static) {
    std::thread::spawn(move || {
        let mut n = notify_rust::Notification::new();
        n.appname("Foco").summary(&message.title).body(&message.body);
        #[cfg(all(unix, not(target_os = "macos")))]
        {
            // The app plays its own chime when sound is on.
            n.hint(notify_rust::Hint::SuppressSound(true));
            if let Some(label) = message.action {
                n.action("start", label);
            }
            match n.show() {
                Ok(handle) if message.action.is_some() => handle.wait_for_action(|id| {
                    if id == "start" {
                        start_next();
                    }
                }),
                Ok(_) => {}
                Err(err) => eprintln!("foco: notificación no mostrada: {err}"),
            }
        }
        #[cfg(not(all(unix, not(target_os = "macos"))))]
        {
            let _ = start_next;
            if let Err(err) = n.show() {
                eprintln!("foco: notificación no mostrada: {err}");
            }
        }
    });
}
