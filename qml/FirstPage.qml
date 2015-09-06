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

    property var muted: []
    property var normal: []

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
            typedCall("getMutedList",
                      [],
                      function(output) {
                          muted = output
                      }
                     )
            typedCall("getNormalList",
                      [],
                      function(output) {
                          normal = output
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
            typedCall("removeRingtone",
                      [
                          {
                              'type': 's',
                              'value': number
                          }

                      ]
                     )
        }

        function setMutedList(list) {
            typedCall("setMutedList",
                      [
                          {
                              'type': 's',
                              'value': list.length > 0 ? list.join(";") : ""
                          }

                      ]
                     )
        }

        function setNormalList(list) {
            typedCall("setNormalList",
                      [
                          {
                              'type': 's',
                              'value': list.length > 0 ? list.join(";") : ""
                          }

                      ]
                     )
        }
    }

    SilicaFlickable {
        id: view
        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu {
            MenuItem {
                text: "About"
                onClicked: pageStack.push(Qt.resolvedUrl("SecondPage.qml"))
            }
        }

        Column {
            id: column
            width: parent.width
            spacing: 0

            PageHeader { title: "Personal Ringtones" }

            SectionHeader { text: "Custom ringtones" }

            Repeater {
                model: numbers
                delegate: ListItem {
                    id: item
                    menu: contextMenu
                    preventStealing: true
                    contentHeight: itemContent.height
                    property Person person: people.count ? people.personByPhoneNumber(modelData, false) : null
                    ListView.onRemove: animateRemoval(item)
                    function remove() {
                        settings.removeRingtone(modelData)
                        var temp = values
                        delete temp[modelData]
                        values = temp
                    }
                    ValueButton {
                        id: itemContent
                        highlighted: false
                        label: modelData === "default" ? "Default ringtone" : (item.person ? item.person.displayLabel : modelData)
                        value: metadataReader.getTitle(values[modelData])
                        description: modelData

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
            }

            BackgroundItem {
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
                    var page = pageStack.push(contactSelector)
                    page.numberSelected.connect(function(selectedNumber) {
                        var number = selectedNumber
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

            SectionHeader { text: "Always silenced numbers" }

            Repeater {
                model: muted
                delegate: ListItem {
                    id: mutedItem
                    menu: contextMenu
                    contentHeight: mutedItemContent.height
                    preventStealing: true
                    ListView.onRemove: animateRemoval(mutedItem)
                    function remove() {
                        var temp = muted
                        var mindex = temp.indexOf(modelData)
                        temp.splice(mindex, 1)
                        settings.setMutedList(temp)
                        muted = temp
                    }
                    ValueButton {
                        id: mutedItemContent
                        highlighted: false
                        property Person person: people.count ? people.personByPhoneNumber(modelData, false) : null
                        label: person ? person.displayLabel : modelData
                        description: person ? modelData : ""

                        onPressAndHold: {
                            mutedItem.showMenu()
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
            }

            BackgroundItem {
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
                    var page = pageStack.push(contactSelector)
                    page.numberSelected.connect(function(selectedNumber) {
                        var number = selectedNumber
                        var temp = muted
                        var mindex = temp.indexOf(number)
                        if (mindex == -1) {
                            temp.push(number)
                            muted = temp
                            settings.setMutedList(muted)
                        }
                        pageStack.pop()
                    } )
                }
            }

            SectionHeader { text: "Always with sound numbers" }

            Repeater {
                model: normal
                delegate: ListItem {
                    id: normalItem
                    menu: contextMenu
                    contentHeight: normalItemContent.height
                    preventStealing: true
                    ListView.onRemove: animateRemoval(normalItem)
                    function remove() {
                        var temp = normal
                        var nindex = temp.indexOf(modelData)
                        temp.splice(nindex, 1)
                        settings.setNormalList(temp)
                        normal = temp
                    }

                    ValueButton {
                        id: normalItemContent
                        highlighted: false
                        property Person person: people.count ? people.personByPhoneNumber(modelData, false) : null
                        label: person ? person.displayLabel : modelData
                        description: person ? modelData : ""

                        onPressAndHold: {
                            normalItem.showMenu()
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
            }

            BackgroundItem {
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
                    var page = pageStack.push(contactSelector)
                    page.numberSelected.connect(function(selectedNumber) {
                        var number = selectedNumber
                        var temp = normal
                        var nindex = temp.indexOf(number)
                        if (nindex == -1) {
                            temp.push(number)
                            normal = temp
                            settings.setNormalList(normal)
                        }
                        pageStack.pop()
                    } )
                }
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


