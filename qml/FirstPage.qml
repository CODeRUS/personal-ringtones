import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Media 1.0
import Sailfish.Contacts 1.0
import com.jolla.settings.system 1.0
import org.nemomobile.systemsettings 1.0
import org.nemomobile.contacts 1.0
import org.nemomobile.dbus 2.0

Page {
    id: page

    property var numbers: Object.keys(values)
    property var values: ({})

    Component.onCompleted: {
        settings.getItems()
    }

    DBusInterface {
        id: settings
        bus: DBus.SessionBus
        iface: "org.coderus.personalringtones"
        path: "/"
        service: "org.coderus.personalringtones"

        function getItems() {
            typedCall("getItems",
                      [],
                      function(output) {
                          values = output
                      }
                     )
        }

        function setRingtone(number, path) {
            typedCall("setRingtone",
                      [
                          {
                              'type': 's',
                              'value': number
                          },
                          {
                              'type': 's',
                              'value': path
                          }

                      ]
                     )
        }

        function removeRingtone(number) {
            typedCall("setRingtone",
                      [
                          {
                              'type': 's',
                              'value': number
                          }

                      ]
                     )
        }
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
            property Person person: people.count ? people.personByPhoneNumber(modelData, false) : null
            ListView.onRemove: animateRemoval(listItem)
            function remove() {
                remorseAction("Deleting", function() {
                    settings.removeRingtone(modelData)
                    var temp = values
                    delete temp[modelData]
                    values = temp
                })
            }
            ValueButton {
                id: itemContent

                label: modelData === "default" ? "Default ringtone" : (item.person ? item.person.displayLabel : modelData)
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
                            settings.setRingtone(modelData, dialog.selectedFilename)
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
                font.bold: true
            }

            onClicked: {
                var page = pageStack.push(contactSelector)
                page.numberSelected.connect(function(selectedNumber) {
                    var number = Person.normalizePhoneNumber(selectedNumber)
                    var dialog = pageStack.replace(dialogComponent, {
                        activeFilename: "",
                        activeSoundTitle: "no sound",
                        activeSoundSubtitle: "Contact ringtone",
                        noSound: false
                        })

                    dialog.accepted.connect(
                        function() {
                            settings.setRingtone(number, dialog.selectedFilename)
                            var temp = values
                            temp[number] = dialog.selectedFilename
                            values = temp
                        })
                } )
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

    Component {
        id: contactSelector

        ContactSelectPage {
            signal numberSelected(string number)

            requiredProperty: PeopleModel.PhoneNumberRequired

            onContactClicked: numberSelected(property.number)
        }
    }

    PeopleModel {
        id: people
        filterType: PeopleModel.FilterAll
        requiredProperty: PeopleModel.PhoneNumberRequired
    }
}


