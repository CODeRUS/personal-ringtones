import QtQuick 2.1
import Sailfish.Silica 1.0
import org.nemomobile.contacts 1.0
import "../components"

Page {
    id: page
    objectName: "selectPhonebook"

    property string searchPattern
    onSearchPatternChanged: {
        listView.model.search(searchPattern)
    }

    property bool searchEnabled: false

    property string title: qsTr("Select contacts", "Add contacts page title")
    signal selected(string number)

    Loader {
        id: modelLoader
        active: false
        asynchronous: true
        sourceComponent: Component {
            PeopleModel {
                filterType: PeopleModel.FilterAll
                requiredProperty: PeopleModel.PhoneNumberRequired
            }
        }
        onLoaded: {
            listView.model = modelLoader.item
        }
    }

    onStatusChanged: {
        if (status == PageStatus.Active) {
            modelLoader.active = true
        }
    }

    SilicaListView {
        id: listView
        anchors.fill: parent
        header: headerComponent
        delegate: contactsDelegate
        cacheBuffer: page.height * 2
        pressDelay: 0
        spacing: 0
        currentIndex: -1
        clip: true
        section {
            property: "sectionBucket"
            criteria: ViewSection.FirstCharacter
            delegate: sectionDelegate
        }

        Component.onCompleted: {
            if (listView.hasOwnProperty("quickScroll")) {
                listView.quickScroll = false
            }
        }

        PullDownMenu {
            MenuItem {
                text: searchEnabled
                      ? qsTr("Hide search field")
                      : qsTr("Show search field")
                enabled: listView.count > 0
                onClicked: {
                    searchEnabled = !searchEnabled
                }
            }
        }

        ViewPlaceholder {
            enabled: listView.count == 0
            text: searchPattern.length == 0 && modelLoader.status == Loader.Ready && listView.model.populated
                                               ? qsTr("No matching contacts")
                                               : qsTr("Loading phonebook...")
        }

        FastScroll {
            id: fastScroll
            property int offset: page.isPortrait ? Theme.itemSizeLarge : Theme.itemSizeSmall
            __topPageMargin: -offset
            topOffset: offset
        }
    }

    Component {
        id: headerComponent
        Item {
            id: componentItem
            width: parent.width
            height: header.height + searchPlaceholder.height

            PageHeader {
                id: header
                //_backgroundVisible: false
                title: page.title
            }

            Item {
                id: searchPlaceholder
                width: componentItem.width
                height: searchEnabled ? searchField.height : 0
                anchors.top: header.bottom
                Behavior on height {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.InOutQuad
                        property: "height"
                    }
                }
                clip: true
                SearchField {
                    id: searchField
                    anchors.bottom: parent.bottom
                    width: parent.width
                    placeholderText: qsTr("Search contacts", "Contacts page search text")
                    inputMethodHints: Qt.ImhNoPredictiveText
                    enabled: searchEnabled
                    onEnabledChanged: {
                        if (!enabled) {
                            text = ''
                        }
                        else {
                            forceActiveFocus()
                        }
                    }
                    focus: enabled
                    visible: opacity > 0
                    opacity: searchEnabled ? 1 : 0
                    Behavior on opacity {
                        FadeAnimation {
                            duration: 300
                        }
                    }
                    onTextChanged: {
                        searchPattern = searchField.text
                        fastScroll.init()
                    }
                }
            }
        }
    }

    Component {
        id: sectionDelegate
        SectionHeader {
            text: section
        }
    }

    Component {
        id: contactsDelegate

        Column {
            width: parent.width
            spacing: 0
            Repeater {
                id: internal
                width: parent.width
                property var effectiveIndecies: constructIndecies()
                function constructIndecies() {
                    var indecies = []
                    var effectiveNumbers = []
                    var phones = person.phoneDetails
                    for (var i = 0; i < phones.length; i++) {
                        var normalized = phones[i].normalizedNumber
                        if (effectiveNumbers.indexOf(normalized) < 0) {
                            indecies.splice(0, 0, i)
                            effectiveNumbers.splice(0, 0, normalized)
                        }
                    }
                    return indecies
                }

                model: effectiveIndecies.length
                delegate: BackgroundItem {
                    id: innerItem
                    width: parent.width
                    height: Theme.itemSizeMedium
                    highlighted: down
                    property string number: person.phoneDetails[internal.effectiveIndecies[index]].normalizedNumber
                    property string avatar: person.avatarPath == "image://theme/icon-m-telephony-contact-avatar" ? "" : person.avatarPath

                    onClicked: {
                        page.selected(number)
                    }

                    Rectangle {
                        id: avaplaceholder
                        anchors {
                            top: parent.top
                            bottom: parent.bottom
                            margins: Theme.paddingSmall
                            left: parent.left
                            leftMargin: Theme.paddingLarge
                        }

                        width: height
                        color: ava.status == Image.Ready ? "transparent" : "#40FFFFFF"

                        Image {
                            id: ava
                            width: avaplaceholder.width
                            height: avaplaceholder.height
                            source: avatar
                            sourceSize.width: width
                            sourceSize.height: height
                            cache: true
                            asynchronous: true
                        }
                    }

                    Column {
                        id: content
                        anchors {
                            left: avaplaceholder.right
                            right: parent.right
                            margins: Theme.paddingLarge
                            verticalCenter: parent.verticalCenter
                        }
                        spacing: Theme.paddingMedium

                        Label {
                            width: parent.width
                            wrapMode: Text.NoWrap
                            elide: Text.ElideRight
                            text:  Theme.highlightText(person.displayLabel, searchPattern, Theme.highlightColor)
                            color: innerItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                        }

                        Label {
                            width: parent.width
                            wrapMode: Text.NoWrap
                            elide: Text.ElideRight
                            font.pixelSize: Theme.fontSizeSmall
                            text: number
                            color: innerItem.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                        }
                    }
                }
            }
        }
    }
}
