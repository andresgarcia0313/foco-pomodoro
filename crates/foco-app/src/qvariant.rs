//! Builders for the JavaScript-shaped values QML reads: arrays of plain objects.

use cxx_qt_lib::{QList, QMap, QMapPair_QString_QVariant, QString, QVariant};

/// A JavaScript object (`QVariantMap`) from field names and values.
pub fn object<const N: usize>(fields: [(&str, QVariant); N]) -> QVariant {
    let mut map = QMap::<QMapPair_QString_QVariant>::default();
    for (key, value) in fields {
        map.insert(QString::from(key), value);
    }
    QVariant::from(&map)
}

/// A JavaScript array (`QVariantList`).
pub fn array(items: impl IntoIterator<Item = QVariant>) -> QVariant {
    let mut list = QList::<QVariant>::default();
    for item in items {
        list.append(item);
    }
    QVariant::from(&list)
}

pub fn int(value: impl TryInto<i32>) -> QVariant {
    QVariant::from(&value.try_into().unwrap_or(i32::MAX))
}

pub fn text(value: &str) -> QVariant {
    QVariant::from(&QString::from(value))
}

pub fn flag(value: bool) -> QVariant {
    QVariant::from(&value)
}
