import QtQuick 2.0
import Sailfish.Silica 1.0

import Sailfish.Contacts 1.0
import org.nemomobile.contacts 1.0
import Nemo.Configuration 1.0

Page {
    id: page

    allowedOrientations: Orientation.All

    property bool loading: true

    Component.onCompleted: {
        listModel.load()
    }

    SilicaListView {
        id: view
        anchors.fill: parent
        model: listModel

        PullDownMenu {
            MenuItem {
                text: qsTr("Add contact")
                onClicked: {
                    var page = pageStack.push("Sailfish.Contacts.ContactSelectPage", {
                        requiredProperty: PeopleModel.PhoneNumberRequired
                        })
                    page.contactClicked.connect(function(contact, prop, propType) {
                        var number = prop.number
                        listModel.addNumber(number)
                        pageStack.pop()
                    })
                }
            }
        }

        header: PageHeader {
            title: qsTr("Important contacts")
        }

        delegate: Component {
            ListItem {
                id: listItem
                menu: contextMenu
                contentHeight: Theme.itemSizeSmall
                ListView.onRemove: animateRemoval(listItem)
                property Person person: people.count ? people.personByPhoneNumber(number, false) : null

                Item {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter
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

                function remove(number) {
                    remorseAction(qsTr("Deleting %1 (%2)".arg(label.text).arg(labelNumber.text)), function() {
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
            }
        }

        ViewPlaceholder {
            enabled: view.count == 0 && !loading
            text: qsTr("No contacts yet")
            hintText: qsTr("Pull down to add important contacts, which will ring always")
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
            contacts = important.read()
            contacts.forEach(function(number) {
                append({number: number})
            })
            loading = false
        }
        function addNumber(number) {
            if (contacts.indexOf(number) >= 0) {
                return false
            }
            contacts.push(number)
            contactsChanged()
            important.save(contacts)
            append({number: number})
            return true
        }
        function removeNumber(number) {
            var myIndex = contacts.indexOf(number)
            if (myIndex < 0) {
                return false
            }
            contacts.splice(myIndex, 1)
            important.save(contacts)
            contactsChanged()
            remove(myIndex)
            return true
        }
    }

    ConfigurationValue {
        id: important

        key: "/apps/personal-ringtones/important"
        defaultValue: ""

        function read() {
            var text = important.value
            if (text.length == 0) {
                return []
            }
            return important.value.split(';')
        }

        function save(list) {
            important.value = list.join(';')
        }
    }

    PeopleModel {
        id: people
        filterType: PeopleModel.FilterAll
        requiredProperty: PeopleModel.PhoneNumberRequired
    }
}
