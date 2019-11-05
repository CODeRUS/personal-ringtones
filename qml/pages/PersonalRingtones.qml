import QtQuick 2.0
import Sailfish.Silica 1.0

import Sailfish.Media 1.0
import Sailfish.Contacts 1.0
import org.nemomobile.contacts 1.0
import Nemo.Configuration 1.0

Page {
    id: page

    allowedOrientations: Orientation.All

    property bool loading: true
    property bool settingsMode: false

    property string tempTone

    Component.onCompleted: {
        listModel.load()
    }

    SilicaListView {
        id: view
        anchors.fill: parent
        model: listModel

        PullDownMenu {
            MenuItem {
                text: settingsMode ? qsTr("Hide settings") : qsTr("Show settings")
                onClicked: settingsMode = !settingsMode
            }
            MenuItem {
                text: qsTr("Add contact")
                onClicked: {
                    var page = pageStack.push("Sailfish.Contacts.ContactSelectPage", {
                        requiredProperty: PeopleModel.PhoneNumberRequired
                        })
                    page.contactClicked.connect(function(contact, prop, propType) {
                        var number = prop.number
                        var dialog = pageStack.replace("com.jolla.settings.system.SoundDialog", {
                            activeFilename: "",
                            activeSoundTitle: "no sound",
                            activeSoundSubtitle: "Contact ringtone",
                            noSound: false
                            })

                        dialog.accepted.connect(
                            function() {
                                var tone = dialog.selectedFilename || "muted"
                                listModel.addNumber(number, tone)
                            })
                    } )
                }
            }
        }

        header: Loader {
            sourceComponent: settingsMode ? settingsHeader : basicHeader
            width: parent.width
        }

        Component {
            id: basicHeader
            PageHeader {
                title: qsTr("Personal ringtones")
            }
        }

        Component {
            id: settingsHeader
            Slider {
                minimumValue: 0
                maximumValue: 10
                stepSize: 1
                value: matchConfig.value
                label: qsTr("Match numbers by right digits")
                valueText: value > 0 ? qsTr("%1 digits").arg(value) : qsTr("Full match")
                onReleased: matchConfig.value = parseInt(value)
            }
        }

        ConfigurationValue {
            id: matchConfig
            key: "/apps/personal-ringtones/match"
            defaultValue: 0
        }

        delegate: Component {
            ListItem {
                id: listItem
                menu: contextMenu
                contentHeight: Theme.itemSizeMedium // two line delegate
                ListView.onRemove: animateRemoval(listItem)
                property Person person: people.count ? people.personByPhoneNumber(number, false) : null

                Component.onCompleted: {
                    if (tempTone && mediaConfig.value == '') {
                        mediaLabel.media = tempTone
                        tempTone = ''
                    }
                }

                onClicked: {
                    var dialog = pageStack.push("com.jolla.settings.system.SoundDialog", {
                        activeFilename: mediaLabel.isMuted ? '' : mediaLabel.media,
                        activeSoundTitle: mediaLabel.isMuted ? 'no sound' : mediaLabel.text,
                        activeSoundSubtitle: "Contact ringtone",
                        noSound: mediaLabel.isMuted
                        })

                    dialog.accepted.connect(
                        function() {
                            var tone = dialog.selectedFilename || "muted"
                            mediaConfig.value = tone
                        })
                }

                Column {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter

                    Item {
                        width: parent.width
                        height: label.height || labelNumber.height

                        Label {
                            id: label
                            anchors.left: parent.left
                            anchors.right: labelNumber.left
                            anchors.rightMargin: Theme.paddingMedium
                            truncationMode: TruncationMode.Fade
                            text: listItem.person ? listItem.person.displayLabel : number
                            color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                        }

                        Label {
                            id: labelNumber
                            anchors.right: parent.right
                            text: listItem.person ? number : ''
                            color: listItem.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                        }
                    }

                    Label {
                        id: mediaLabel
                        property alias media: mediaConfig.value
                        property bool isMuted: media == 'muted'
                        width: parent.width
                        truncationMode: TruncationMode.Fade
                        text: (isMuted || media == '') ? media : metadataReader.getTitle(media)
                        font.pixelSize: Theme.fontSizeSmall
                        color: listItem.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    }
                }

                function remove(number) {
                    remorseAction(qsTr("Deleting %1 (%2)".arg(label.text).arg(labelNumber.text)), function() {
                        mediaConfig.value = ''
                        listModel.removeNumber(number)
                    })
                }

                Component {
                    id: contextMenu
                    ContextMenu {
                        MenuItem {
                            text: qsTr("Remove")
                            onClicked: {
                                remove(number)
                            }
                        }
                    }
                }

                ConfigurationValue {
                    id: mediaConfig
                    key: "/apps/personal-ringtones/" + number
                    defaultValue: ""
                }
            }
        }

        ViewPlaceholder {
            enabled: view.count == 0 && !loading
            text: qsTr("No contacts yet")
            hintText: qsTr("Pull down to add contacts")
        }
    }

    BusyIndicator {
        anchors.centerIn: view
        size: BusyIndicatorSize.Large
        visible: loading
        running: visible
    }

    ListModel {
        id: listModel
        property var contacts: []
        function load() {
            contacts = numbers.read()
            contacts.forEach(function(number) {
                append({number: number})
            })
            loading = false
        }
        function addNumber(number, tone) {
            if (contacts.indexOf(number) >= 0) {
                return false
            }
            tempTone = tone
            contacts.push(number)
            contactsChanged()
            numbers.save(contacts)
            append({number: number})
            return true
        }
        function removeNumber(number) {
            var myIndex = contacts.indexOf(number)
            if (myIndex < 0) {
                return false
            }
            contacts.splice(myIndex, 1)
            numbers.save(contacts)
            contactsChanged()
            remove(myIndex)
            return true
        }
    }

    ConfigurationValue {
        id: numbers

        key: "/apps/personal-ringtones/numbers"
        defaultValue: ""

        function read() {
            var text = numbers.value
            if (text.length == 0) {
                return []
            }
            return numbers.value.split(';')
        }

        function save(list) {
            numbers.value = list.join(';')
        }
    }

    MetadataReader {
        id: metadataReader
    }

    PeopleModel {
        id: people
        filterType: PeopleModel.FilterAll
        requiredProperty: PeopleModel.PhoneNumberRequired
    }
}
