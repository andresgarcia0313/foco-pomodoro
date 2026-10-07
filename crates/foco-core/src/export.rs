//! History export to CSV (comma-separated values), RFC 4180 quoting.

use crate::stats::History;

pub fn history_csv(history: &History) -> String {
    let mut out = String::from("ended_at,minutes,task\n");
    for s in history.sessions() {
        let task = s.task.as_deref().unwrap_or("");
        out.push_str(&format!(
            "{},{},{}\n",
            s.ended_at.format("%Y-%m-%d %H:%M:%S"),
            s.minutes,
            quote(task)
        ));
    }
    out
}

fn quote(field: &str) -> String {
    if field.contains([',', '"', '\n', '\r']) {
        format!("\"{}\"", field.replace('"', "\"\""))
    } else {
        field.to_owned()
    }
}
