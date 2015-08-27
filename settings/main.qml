import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.configuration 1.0

Page {
    id: page

    ConfigurationGroup {
        id: mazeLockSettings
        path: "/desktop/nemo/devicelock/mazelock"
        property int size: 4
        property bool colored: true
        property bool maskImmediately: true
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: content.height
        interactive: contentHeight > height

        Column {
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: "MazeLock settings"
            }

            TextSwitch {
                width: parent.width
                text: "Mask input character immediately"
                checked: mazeLockSettings.maskImmediately
                onClicked: mazeLockSettings.maskImmediately = checked
            }

            TextSwitch {
                width: parent.width
                text: "Draw colored lines between nodes"
                checked: mazeLockSettings.colored
                onClicked: mazeLockSettings.colored = checked
            }

            Slider {
                width: parent.width
                label: "MazeLock size"
                maximumValue: 6
                minimumValue: 3
                stepSize: 1
                value: mazeLockSettings.size
                valueText: value

                onValueChanged: mazeLockSettings.size = Math.round(value)
                onPressAndHold: cancel()
            }
        }
    }
}
