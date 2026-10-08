import QtMultimedia

// Loaded only when sound is on, so Qt Multimedia (FFmpeg, video drivers) costs no memory
// while the app is muted or the chime is disabled.
SoundEffect {
    source: "qrc:/qt/qml/FocoApp/assets/chime.wav"
}
