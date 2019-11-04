import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page
    allowedOrientations: Orientation.All

    function _() {
        QT_TRANSLATE_NOOP("", "Personal Ringtones")
    }

    SilicaFlickable {
        id: flick
        anchors.fill: parent
        contentHeight: content.height

        Column {
            id: content
            width: parent.width

            PageHeader {
                title: qsTr("Personal Ringtones")
            }

            Repeater {
                model: ListModel {
                    ListElement {
                        pageTitle: qsTr("Choose personal ringtones")
                        pageName: "PersonalRingtones.qml"
                    }
                    ListElement {
                        pageTitle: qsTr("Choose important contacts")
                        pageName: "ImportantContacts.qml"
                    }
                    ListElement {
                        pageTitle: qsTr("Set random ringtone")
                        pageName: "RandomRingtone.qml"
                    }
                    ListElement {
                        pageTitle: qsTr("About")
                        pageName: "AboutPage.qml"
                    }
                }
                delegate: menuItem
            }
        }
    }

    Component {
        id: menuItem
        BackgroundItem {
            contentHeight: Theme.itemSizeMedium
            Label {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: Theme.horizontalPageMargin
                anchors.verticalCenter: parent.verticalCenter
                truncationMode: TruncationMode.Fade
                text: pageTitle
            }
            onClicked: pageStack.push(Qt.resolvedUrl(pageName))
        }
    }
}
