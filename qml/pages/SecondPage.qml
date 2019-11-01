import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    allowedOrientations: Orientation.All

    PageHeader {
        title: qsTr("About")
    }

    Label {
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
        text: "by coderus\nin 2019"
    }
}
