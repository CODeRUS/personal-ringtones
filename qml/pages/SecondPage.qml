import QtQuick 2.0
import Sailfish.Silica 1.0


Page {
    id: page
    SilicaFlickable {
        id: view
        anchors.fill: parent
        contentHeight: content.height

        Column {
            id: content
            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader {
                title: qsTr("About")
            }

            Label {
                text: "v" + Qt.application.version
                font.pixelSize: Theme.fontSizeMedium
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            Label {
                text: "Simple proof-of-concept hacky-tricky application for customizing ringtones per contact\nwritten by coderus in 0x7DF\nis dedicated to my beloved"
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
                text: "PayPal"
                width: 300
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    Qt.openUrlExternally("https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=ovi.coderus%40gmail%2ecom&lg=en&lc=US&item_name=Donation%20for%20coderus%20powermenu%20EUR&no_note=0&currency_code=EUR&bn=PP%2dDonationsBF%3abtn_donate_LG%2egif%3aNonHostedGuest")
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
        }

        VerticalScrollDecorator {}
    }
}





