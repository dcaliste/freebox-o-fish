/*
 * freebox-o-fish.qml
 * Copyright (C) Damien Caliste 2014 <dcaliste@free.fr>
 *
 * freebox-o-fish is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License
 * as published by the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import QtQuick.LocalStorage 2.0
import "loader.js" as JS
import Sailfish.Silica 1.0

ApplicationWindow {
    initialPage: page
    cover: cover

    property string freebox_id: ""
    property alias url: urlInput.text

    /* Can be:
       - unknown
       - fetching
       - error
       - denied_from_external_ip
       - timeout
       - denied
       - pending
       - granted
       */
    property string app_token_status: "unknown"

    property string app_token: ""
    property int track_id: 0
    property string session_token: ""

    Page {
        id: page
        anchors.fill: parent

        Timer {
            interval: 1000
            running: app_token_status == "pending"
            repeat: true
            onTriggered: JS.requestAppTokenStatus()
        }

        Column {
            id: header
            spacing: Theme.paddingMedium

            width: parent.width
            PageHeader {
                width: page.width
                title: "(Free) Box-o-fish"
            }
            Row {
                id: urlLine
                width: parent.width
                TextField {
                    id: urlInput
                    width: parent.width - favButton.width
                    label: "Adresse de la Freebox"
	            text: "mafreebox.freebox.fr"
		    anchors.verticalCenter: parent.verticalCenter
                    inputMethodHints: Qt.ImhUrlCharactersOnly | Qt.ImhNoPrediction
                    enabled: (app_token_status == "unknown" || JS.appTokenIsError())
                }
	        IconButton {
		    id: favButton
		    icon.source: (down)?"image://theme/icon-m-favorite-selected":"image://theme/icon-m-favorite"
		    anchors.verticalCenter: parent.verticalCenter
                    onClicked: favList.show(grid)
	        }
            }
            ContextMenu {
                id: favList
                Repeater {
                    model: JS.getFavoriteURL()

                    MenuItem {
                        text: modelData
                        onClicked: url = text
                    }
                }
            }
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "se connecter"
                enabled: (app_token_status == "unknown" || JS.appTokenIsError())
                visible: (session_token.length == 0)
                onClicked: JS.appTokenConnect()
            }
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "se déconnecter"
                enabled: (app_token_status == "granted")
                visible: (session_token.length > 0)
                onClicked: JS.logout()
            }
            Label {
                visible: JS.appTokenIsError()
                width: parent.width - Theme.paddingMedium * 2
                text: JS.appTokenErrorMessage()
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignJustify
	        anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        Component {
            id: callPage
            CallPage { }
        }
        ListModel {
            id: actions
            ListElement {
                label: "Appels"
                iconSource: "image://theme/icon-l-answer"
                page: "callPage"
                implemented: true
            }
            ListElement {
                label: "Contacts"
                iconSource: "image://theme/icon-l-people"
                page: "contactPage"
                implemented: false
            }
        }

        Component {
            id: aboutPage
            About { }
        }

        SilicaGridView {
            id: grid
            model: actions
            anchors.fill: parent

            header: Item {
                id: headerPlace
                width: header.width
                height: header.height
                Component.onCompleted: header.parent = headerPlace
            }

            cellWidth: parent.width / 3
            cellHeight: cellWidth

	    PullDownMenu {
	        MenuItem {
		    text: "À propos"
		    onClicked: pageStack.push(aboutPage)
	        }
	    }

	    BusyIndicator {
	   	id: busy
                visible: ((session_token.length == 0 &&
                           (app_token_status == "pending" ||
                            app_token_status == "granted")) ||
                          app_token_status == "fetching")
                running: visible
                size: BusyIndicatorSize.Large
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            delegate: BackgroundItem {
                width: grid.cellWidth
                height: grid.cellHeight
                enabled: (session_token.length > 0 && implemented)
                opacity: (enabled)?1:0.33
                Image {
                    source: iconSource
	            anchors.centerIn: parent
                }
                Label {
                    text: label
	            anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    font.pixelSize: Theme.fontSizeSmall
                }
                onClicked:  pageStack.push(eval(model.page))
            }
        }
    }

    CoverBackground {
        id: cover
        Column {
            spacing: Theme.paddingSmall
            width: parent.width - 2*Theme.paddingLarge
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: Theme.paddingLarge
            Item {
                width: parent.width
                height: title.height
                
                Column {
                    id: title
                    width: parent.width
                    Label {
                        width: parent.width
                        color: Theme.highlightColor
                        font.pixelSize: Theme.fontSizeSmall
                        truncationMode: TruncationMode.Fade
                        text: "Freebox"
                    }
                    Label {
                        width: parent.width
                        font.pixelSize: Theme.fontSizeExtraSmall
                        truncationMode: TruncationMode.Fade
                        color: Theme.secondaryHighlightColor
                        text: url
                    }
                }
                Image {
                    anchors.right: parent.right
                    anchors.rightMargin: -Theme.paddingSmall
                    anchors.verticalCenter: parent.verticalCenter
                    source: "image://theme/icon-m-link"
                    opacity: (session_token.length > 0)?1.:0.3
                }
            }
        }
    }

    onApp_token_statusChanged: if (app_token_status == "granted") {
        JS.setFavoriteURL()
        JS.login()
    }
}
