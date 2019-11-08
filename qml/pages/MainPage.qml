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
                height: Theme.itemSizeMedium
                width: parent.width
                model: ListModel {
                    ListElement {
                        pageTitle: qsTr("Choose personal ringtones")
                        pageName: "PersonalRingtones.qml"
                        iconName: "image://theme/icon-m-media-artists"
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
            id: delegate

            HighlightImage {
                id: icon
                anchors.left: parent.left
                anchors.leftMargin: Theme.horizontalPageMargin
                anchors.verticalCenter: parent.verticalCenter
                source: iconName
                highlighted: delegate.highlighted
            }

            Label {
                anchors.left: icon.right
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin
                anchors.verticalCenter: parent.verticalCenter
                truncationMode: TruncationMode.Fade
                text: pageTitle
                color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
            }
            onClicked: pageStack.push(Qt.resolvedUrl(pageName))
        }
    }
}
