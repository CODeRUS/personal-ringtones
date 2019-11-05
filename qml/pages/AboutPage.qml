import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    allowedOrientations: Orientation.All

    PageHeader {
        id: header
        title: qsTr("About")
    }

    Item {
        anchors.top: header.bottom
        width: parent.width
        height: aboutArea.rotationHeight
        Behavior on height {
            NumberAnimation {
                duration: 800
                easing.type: Easing.OutExpo
            }
        }

        clip: true

        Column {
            width: parent.width

            Image {
                source: "personal-magic.svg"
                sourceSize.width: width
                sourceSize.height: width
                width: Theme.itemSizeHuge
                height: width
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    MouseArea {
        id: aboutArea
        y: header.height
        width: parent.width
        height: textLabel.paintedHeight

        property var transforms: []
        property real rotationHeight: 0

        Label {
            id: textLabel
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            text: "by coderus\nin 2019"
        }

        onClicked: {
            var tf = transforms
            rotationHeight += height
            var i = rotationDown.createObject(aboutArea,
                                              {rotationHeight: rotationHeight})
            tf.push(i)
            transform = tf

        }
    }

    Component {
        id: rotationDown
        Rotation {
            id: rotation
            origin.x: aboutArea.width / 2
            origin.y: rotationHeight
            axis.x: 1
            axis.y: 0
            axis.z: 0
            angle: 0

            property real rotationHeight
            property NumberAnimation rotationAnim: NumberAnimation {
                target: rotation
                property: "angle"
                from: 0
                to: 180
                duration: 2000
                easing.type: Easing.OutElastic
                running: true
            }
        }
    }
}
