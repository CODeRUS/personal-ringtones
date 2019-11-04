import QtQuick 2.0
import Sailfish.Silica 1.0

import Nemo.Configuration 1.0

Page {
    id: page
    allowedOrientations: Orientation.All

    SilicaFlickable {
        id: flick
        anchors.fill: parent
        contentHeight: content.height

        Column {
            id: content
            width: parent.width

            PageHeader {
                title: qsTr("Random ringtones")
            }

            TextSwitch {
                id: randomSwitch
                text: qsTr("Use random ringtone")
                automaticCheck: false
                checked: config.random
                onClicked: {
                    config.random = !checked
                }
            }

            Label {
                width: parent.width
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: Theme.horizontalPageMargin
                text: qsTr("Random ringtone will be played for all non-personalized contacts")
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
            }

            ValueButton {
                label: qsTr("Select folder for random ringtone")
                value: config.randomPath
                enabled: randomSwitch.checked
                onClicked: {
                    var picker = pageStack.push("Sailfish.Pickers.FilePickerPage")
                    picker.selectedContentPropertiesChanged.connect(function() {
                        var filePath = picker.selectedContentProperties.filePath
                        var fileName = picker.selectedContentProperties.fileName
                        var path = filePath.slice(0, filePath.length - fileName.length - 1)
                        config.randomPath = path
                    })
                }
            }
        }
    }

    ConfigurationGroup {
        id: config
        path: "/apps/personal-ringtones"
        property bool random: false
        property string randomPath: "/usr/share/sounds/jolla-ringtones/stereo"
    }
}
