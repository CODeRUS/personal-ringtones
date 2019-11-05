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
                        iconName: "image://theme/icon-m-contact"
                    }
                    ListElement {
                        pageTitle: qsTr("Choose important contacts")
                        pageName: "ImportantContacts.qml"
                        iconName: "image://theme/icon-m-favorite"
                    }
                    ListElement {
                        pageTitle: qsTr("Set random ringtone")
                        pageName: "RandomRingtone.qml"
                        iconName: "image://theme/icon-m-shuffle"
                    }
                    ListElement {
                        pageTitle: qsTr("About")
                        pageName: "AboutPage.qml"
                        iconName: "image://theme/icon-m-about"
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

            HighlightImage {
                id: icon
                anchors.left: parent.left
                anchors.leftMargin: Theme.horizontalPageMargin
                anchors.verticalCenter: parent.verticalCenter
                source: iconName
            }

            Label {
                anchors.left: icon.right
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin
                anchors.verticalCenter: parent.verticalCenter
                truncationMode: TruncationMode.Fade
                text: pageTitle
            }
            onClicked: pageStack.push(Qt.resolvedUrl(pageName))
        }
    }
}
