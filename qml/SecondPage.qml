import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.dbus 2.0

Page {
    id: page

    property string version

    Component.onCompleted: {
        settings.getVersion()
    }

    DBusInterface {
        id: storeIf
        bus: DBus.SessionBus
        iface: "com.jolla.jollastore"
        path: "/StoreClient"
        service: "com.jolla.jollastore"

        function uninstall () {
            typedCall("removePackage",
                      [
                          {
                              'type': 's',
                              'value': 'personalringtones'
                          },
                          {
                              'type': 'b',
                              'value': true
                          }

                      ])
        }
    }

    DBusInterface {
        id: settings
        bus: DBus.SessionBus
        iface: "org.coderus.personalringtones"
        path: "/"
        service: "org.coderus.personalringtones"

        function getVersion() {
            typedCall("getVersion",
                      [],
                      function(output) {
                          version = output
                      }
                     )
        }
    }

    SilicaFlickable {
        id: view
        anchors.fill: parent
        contentHeight: header.height + content.height

        PullDownMenu {
            MenuItem {
                text: "Uninstall application"
                onClicked: {
                    remorse.execute("Uninstall application",
                                    function() {
                                        storeIf.uninstall()
                                        pageStack.pop(0, PageStackAction.Immediate)
                                        pageStack.navigateBack(PageStackAction.Immediate)
                                    }
                                   )
                }
            }
        }

        PageHeader {
            id: header
            title: qsTr("About")
        }

        Column {
            id: content
            anchors.top: header.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Theme.paddingLarge
            anchors.rightMargin: Theme.paddingLarge
            spacing: Theme.paddingLarge

            Label {
                text: "v" + version
                font.pixelSize: Theme.fontSizeMedium
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            Label {
                text: "Simple proof-of-concept hacky-tricky application for customizing ringtones per contact"
                font.pixelSize: Theme.fontSizeMedium
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            Label {
                text: "Application replaces system ringtones settings functions, after installation you can only manage ringtones in this application"
                font.pixelSize: Theme.fontSizeMedium
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            Label {
                text: "written by coderus in 0x7DF\nis dedicated to my beloved"
                font.pixelSize: Theme.fontSizeMedium
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            Label {
                text: "We accept donations via"
                font.pixelSize: Theme.fontSizeMedium
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            Button {
                id: btn
                text: "PayPal"
                width: 300
                z: 1000
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    Qt.openUrlExternally("https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=ovi.coderus%40gmail%2ecom&lg=en&lc=US&item_name=Donation%20for%20coderus%20powermenu%20EUR&no_note=0&currency_code=EUR&bn=PP%2dDonationsBF%3abtn_donate_LG%2egif%3aNonHostedGuest")
                }
                onPressed: {
                    timer.stop()
                    btn.color = Theme.primaryColor
                    btn.rotation = 0
                    timer.interval = 180000
                    timer.repeat = false
                    timer.start()
                }
                Timer {
                    id: timer
                    repeat: false
                    interval: 180000
                    running: true
                    onTriggered: {
                        if (interval == 1) {
                            if (btn.rotation == 360) {
                                btn.rotation = 1
                            }
                            else {
                                btn.rotation += 1
                            }
                        }
                        else {
                            interval = 1
                            repeat = true
                            start()
                        }
                    }
                }
                Timer {
                    id: colorTimer
                    running: timer.interval == 1
                    interval: 50
                    repeat: true

                    property real cr: 1.0
                    property real cg: 0.0
                    property real cb: 0.0
                    property real ca: 0.5

                    property bool cru: true
                    property bool cgu: true
                    property bool cbu: true
                    property bool cau: true

                    onTriggered: {
                        if (cru) {
                            cr += 0.11
                        }
                        else {
                            cr -= 0.11
                        }
                        if (cr >= 1) {
                            cru = false
                        }
                        else if (cr <= 0) {
                            cru = true
                        }

                        if (cgu) {
                            cg += 0.12
                        }
                        else {
                            cg -= 0.12
                        }
                        if (cg >= 1) {
                            cgu = false
                        }
                        else if (cg <= 0) {
                            cgu = true
                        }

                        if (cbu) {
                            cb += 0.13
                        }
                        else {
                            cb -= 0.13
                        }
                        if (cb >= 1) {
                            cbu = false
                        }
                        else if (cb <= 0) {
                            cbu = true
                        }

                        if (cau) {
                            ca += 0.05
                        }
                        else {
                            ca -= 0.05
                        }
                        if (ca >= 1) {
                            cau = false
                        }
                        else if (ca <= 0.1) {
                            cau = true
                        }
                        btn.color = Qt.rgba(colorTimer.cr, colorTimer.cg, colorTimer.cb, colorTimer.ca)
                    }
                }
            }

            Label {
                text: "Me and my beloved would be grateful for every cent.\nYour donations makes application better and i can spend more time for development."
                font.pixelSize: Theme.fontSizeMedium
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            Label {
                text: "Big thanks Ove Kåven for ScumStopper source code."
                font.pixelSize: Theme.fontSizeMedium
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            Item { width: 1; height: Theme.paddingLarge }
        }

        VerticalScrollDecorator {}
    }

    RemorsePopup {
        id: remorse
    }
}
