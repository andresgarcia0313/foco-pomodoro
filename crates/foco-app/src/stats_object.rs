//! `StatsStore`: today, streak and the last seven days, plus the CSV export of the history.

use crate::{qvariant as qv, store};
use core::pin::Pin;
use cxx_qt_lib::{QString, QUrl, QVariant};
use foco_core::export::history_csv;

#[cxx_qt::bridge]
pub mod qobject {
    unsafe extern "C++" {
        include!("cxx-qt-lib/qstring.h");
        type QString = cxx_qt_lib::QString;
        include!("cxx-qt-lib/qvariant.h");
        type QVariant = cxx_qt_lib::QVariant;
    }

    extern "RustQt" {
        #[qobject]
        #[qml_element]
        #[qproperty(i32, today_count, cxx_name = "todayCount")]
        #[qproperty(i32, today_minutes, cxx_name = "todayMinutes")]
        #[qproperty(i32, streak)]
        #[qproperty(i32, week_count, cxx_name = "weekCount")]
        #[qproperty(i32, week_minutes, cxx_name = "weekMinutes")]
        #[qproperty(QVariant, week)]
        type StatsStore = super::StatsRust;

        #[qinvokable]
        fn refresh(self: Pin<&mut StatsStore>);
        /// Writes the history to the chosen file URL; false when it could not be written.
        #[qinvokable]
        #[cxx_name = "exportCsv"]
        fn export_csv(self: &StatsStore, file_url: &QString) -> bool;
    }

    impl cxx_qt::Initialize for StatsStore {}
}

#[derive(Default)]
pub struct StatsRust {
    today_count: i32,
    today_minutes: i32,
    streak: i32,
    week_count: i32,
    week_minutes: i32,
    week: QVariant,
}

const INITIALS: [&str; 7] = ["L", "M", "M", "J", "V", "S", "D"];
const NAMES: [&str; 7] = [
    "lunes",
    "martes",
    "miércoles",
    "jueves",
    "viernes",
    "sábado",
    "domingo",
];

impl cxx_qt::Initialize for qobject::StatsStore {
    fn initialize(self: Pin<&mut Self>) {
        self.refresh();
    }
}

impl qobject::StatsStore {
    pub fn refresh(mut self: Pin<&mut Self>) {
        let today = chrono::Local::now().date_naive();
        let (days, streak) =
            store::with(|s| (s.data.history.week(today), s.data.history.streak(today)));
        let total = |f: fn(&foco_core::stats::DayTotal) -> u32| days.iter().map(f).sum::<u32>();
        let (week_count, week_minutes) = (total(|d| d.count), total(|d| d.minutes));
        let week = qv::array(days.iter().map(|d| {
            let day = d.weekday as usize % 7;
            qv::object([
                ("label", qv::text(INITIALS[day])),
                ("name", qv::text(NAMES[day])),
                ("count", qv::int(d.count)),
                ("minutes", qv::int(d.minutes)),
                ("today", qv::flag(d.date == today)),
            ])
        }));
        let last = days.last().copied();
        let int = |v: u32| i32::try_from(v).unwrap_or(i32::MAX);
        self.as_mut()
            .set_today_count(last.map_or(0, |d| int(d.count)));
        self.as_mut()
            .set_today_minutes(last.map_or(0, |d| int(d.minutes)));
        self.as_mut().set_streak(int(streak));
        self.as_mut().set_week_count(int(week_count));
        self.as_mut().set_week_minutes(int(week_minutes));
        self.as_mut().set_week(week);
    }

    pub fn export_csv(&self, file_url: &QString) -> bool {
        let Some(path) = QUrl::from(file_url).to_local_file() else {
            return false;
        };
        let csv = store::with(|s| history_csv(&s.data.history));
        std::fs::write(path.to_string(), csv)
            .map_err(|err| eprintln!("foco: no se pudo exportar: {err}"))
            .is_ok()
    }
}
