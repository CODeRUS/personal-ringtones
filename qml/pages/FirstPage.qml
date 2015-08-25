import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.personal.ringtones 1.0
import Sailfish.Media 1.0
import com.jolla.settings.system 1.0
import org.nemomobile.systemsettings 1.0
import org.nemomobile.contacts 1.0

Page {
    id: page

    property var numbers: Object.keys(values)
    property var values: {
        RingtoneSettings.getItems()
    }

    SilicaListView {
        id: view
        anchors.fill: parent
        model: numbers

        PullDownMenu {
            MenuItem {
                text: "About"
                onClicked: pageStack.push(Qt.resolvedUrl("SecondPage.qml"))
            }
        }

        header: PageHeader { title: "Personal Ringtones" }

        delegate: ListItem {
            id: item
            contentHeight: itemContent.height
            menu: contextMenu
            preventStealing: true
            property Person person: people.personByPhoneNumber(modelData, false)
            ListView.onRemove: animateRemoval(listItem)
            function remove() {
                remorseAction("Deleting", function() {
                    RingtoneSettings.removeRingtone(modelData)
                    var temp = values
                    delete temp[modelData]
                    values = temp
                })
            }
            ValueButton {
                id: itemContent

                label: modelData === "default" ? "Default ringtone" : (person ? person.displayLabel : modelData)
                value: metadataReader.getTitle(values[modelData])

                onClicked: {
                    var dialog = pageStack.push(dialogComponent, {
                        activeFilename: values[modelData],
                        activeSoundTitle: value,
                        activeSoundSubtitle: "Contact ringtone",
                        noSound: false
                        })

                    dialog.accepted.connect(
                        function() {
                            RingtoneSettings.setRingtone(modelData, dialog.selectedFilename)
                            var temp = values
                            temp[modelData] = dialog.selectedFilename
                            values = temp
                        })
                }

                onPressAndHold: {
                    if (modelData !== "default") {
                        item.showMenu()
                    }
                }
            }
            Component {
                id: contextMenu
                ContextMenu {
                    MenuItem {
                        text: "Remove"
                        onClicked: remove()
                    }
                }
            }
        }

        footer: BackgroundItem {
            Label {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                    verticalCenter: parent.verticalCenter
                }

                text: "Add contact"
            }

            onClicked: {
                var contacts = pageStack.push(Qt.resolvedUrl("SelectPhonebook.qml"))
                contacts.selected.connect(function(contactId) {
                    var number = contactId
                    if (number[0] == "+") {
                        var dialog = pageStack.replace(dialogComponent, {
                            activeFilename: "",
                            activeSoundTitle: "no sound",
                            activeSoundSubtitle: "Contact ringtone",
                            noSound: false
                            })

                        dialog.accepted.connect(
                            function() {
                                RingtoneSettings.setRingtone(number, dialog.selectedFilename)
                                var temp = values
                                temp[number] = dialog.selectedFilename
                                values = temp
                            })
                    }
                    else {
                        popup.notify("Number should start with \"+\" or application can't find ringtone for this contact!")
                    }
                })
            }
        }
    }

    AlarmToneModel {
        id: alarmToneModel
    }

    MetadataReader {
        id: metadataReader
    }

    Component {
        id: dialogComponent

        SoundDialog {
            alarmModel: alarmToneModel
        }
    }

    PeopleModel {
        id: people
        filterType: PeopleModel.FilterAll
        requiredProperty: PeopleModel.PhoneNumberRequired
    }
}


