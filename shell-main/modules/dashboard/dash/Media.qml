pragma ComponentBehavior: Bound

import QtQuick
import Caelestia.Components
import Caelestia.Config
import Caelestia.I18n
import Caelestia.Services
import qs.components
import qs.components.controls
import qs.components.widgets
import qs.services
import qs.utils

Item {
    id: root

    property real playerProgress: {
        const active = Players.active;
        return active?.length ? (active.position % active.length) / active.length : 0;
    }

    readonly property real arcCoverGap: Tokens.spacing.extraSmall

    anchors.top: parent.top
    anchors.bottom: parent.bottom
    implicitWidth: Tokens.sizes.dashboard.mediaWidth

    Behavior on playerProgress {
        Anim {
            type: Anim.StandardLarge
        }
    }

    Timer {
        running: Players.active?.isPlaying ?? false
        interval: GlobalConfig.dashboard.mediaUpdateInterval
        triggeredOnStart: true
        repeat: true
        onTriggered: Players.active?.positionChanged()
    }

    ServiceRef {
        service: Audio.beatTracker
    }

    ServiceRef {
        service: Audio.cava
    }

    CircularProgress {
        id: prog

        anchors.centerIn: cover
        implicitSize: cover.width + root.arcCoverGap + thickness * 2

        fgColour: Colours.palette.m3primary
        strokeWidth: Tokens.sizes.dashboard.mediaProgressThickness
        startAngle: -90 - sweepAngle / 2
        sweepAngle: Tokens.sizes.dashboard.mediaProgressSweep
        value: root.playerProgress

        wavy: true
        waveFrequency: 8
        waveDuration: 2000
        wavePaused: !Players.active?.isPlaying
    }

    CoverArt {
        id: cover

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Tokens.padding.medium + root.arcCoverGap + prog.thickness
        implicitHeight: width
    }

    StyledText {
        id: title

        anchors.top: cover.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: Tokens.spacing.medium

        animate: true
        horizontalAlignment: Text.AlignHCenter
        text: (Players.active?.trackTitle ?? Tr.tr("No media")) || Tr.tr("Unknown title")
        color: Colours.palette.m3primary
        font: Tokens.font.title.small

        width: parent.implicitWidth - Tokens.padding.extraLargeIncreased
        elide: Text.ElideRight
    }

    StyledText {
        id: album

        anchors.top: title.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: Tokens.spacing.small

        animate: true
        horizontalAlignment: Text.AlignHCenter
        text: (Players.active?.trackAlbum ?? Tr.tr("No media")) || Tr.tr("Unknown album")
        color: Colours.palette.m3outline
        font: Tokens.font.body.small

        width: parent.implicitWidth - Tokens.padding.extraLargeIncreased
        elide: Text.ElideRight
    }

    StyledText {
        id: artist

        anchors.top: album.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: Tokens.spacing.small

        animate: true
        horizontalAlignment: Text.AlignHCenter
        text: (Players.active?.trackArtist ?? Tr.tr("No media")) || Tr.tr("Unknown artist")
        color: Colours.palette.m3secondary

        width: parent.implicitWidth - Tokens.padding.extraLargeIncreased
        elide: Text.ElideRight
    }

    ButtonRow {
        id: controls

        anchors.top: artist.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: Tokens.spacing.medium
        anchors.margins: Tokens.padding.large

        spacing: Tokens.spacing.extraSmall

        IconButton {
            type: IconButton.Tonal
            icon: "skip_previous"
            isRound: true
            shapeMorph: true
            disabled: !Players.active?.canGoPrevious
            onClicked: Players.active?.previous()
        }

        IconButton {
            fillWidth: true
            icon: Players.active?.isPlaying ? "pause" : "play_arrow"
            isRound: true
            shapeMorph: true
            checked: Players.active?.isPlaying ?? false
            disabled: !Players.active?.canTogglePlaying
            onClicked: Players.active?.togglePlaying()
        }

        IconButton {
            type: IconButton.Tonal
            icon: "skip_next"
            isRound: true
            shapeMorph: true
            disabled: !Players.active?.canGoNext
            onClicked: Players.active?.next()
        }
    }

    // Technical CAVA Frequency Bar Visualizer
    Item {
        id: visualiser

        anchors.top: controls.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: Tokens.spacing.medium
        anchors.bottomMargin: Tokens.padding.large
        anchors.margins: Tokens.padding.extraLargeIncreased

        visible: Players.active?.isPlaying ?? false

        property int barCount: GlobalConfig.services.visualiserBars
        property real barWidth: (width - (barCount - 1) * Tokens.spacing.small) / barCount
        property real maxHeight: height

        Repeater {
            model: root.barCount

            delegate: Rectangle {
                id: bar

                width: root.barWidth
                height: Math.max(2, Audio.cava.values[index] * root.maxHeight)
                x: index * (root.barWidth + Tokens.spacing.small)
                y: root.maxHeight - height
                anchors.bottom: parent.bottom

                radius: Tokens.rounding.small
                color: Colours.palette.m3primary

                Behavior on height {
                    SpringAnimation {
                        spring: 2.0
                        damping: 0.8
                    }
                }

                Behavior on color {
                    CAnim {}
                }

                // Gradient overlay for technical aesthetic
                Layer.enabled: true
                Layer.samplerName: "barGradient"
                layer.effect: ShaderEffect {
                    property var source: bar
                    property real time: 0
                    fragmentShader: "
                        uniform sampler2D source;
                        uniform lowp float qt_Opacity;
                        varying highp vec2 qt_TexCoord0;
                        void main() {
                            lowp vec4 color = texture2D(source, qt_TexCoord0);
                            highp float gradient = mix(0.7, 1.0, qt_TexCoord0.y);
                            gl_FragColor = vec4(color.rgb * gradient, color.a) * qt_Opacity;
                        }
                    "
                }
            }
        }

        // Fallback flat media control symbol when no audio data
        MaterialIcon {
            id: fallbackIcon

            anchors.centerIn: parent
            text: "equalizer"
            fontStyle: Tokens.font.icon.builders.large.scale(3).build()
            color: Colours.palette.m3outline
            opacity: (Players.active?.isPlaying ?? false) && Audio.cava.values[0] === 0 ? 0.5 : 0
        }
    }
}
