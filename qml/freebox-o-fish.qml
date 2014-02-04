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

    property string freebox_id: "Vinéa"
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
                width: parent.width
                TextField {
                    id: urlInput
                    width: parent.width - fav.width
                    label: "Adresse de la Freebox"
	            text: "mafreebox.freebox.fr" /*"88.167.68.163"*/ /*"mafreebox.freebox.fr"*/
		    anchors.verticalCenter: parent.verticalCenter
                    /*onTextChanged: { app_token = ""
                      track_id = 0
                      app_token_status = "unknown" }*/
                }
	        IconButton {
		    id: fav
		    icon.source: (down)?"image://theme/icon-m-favorite-selected":"image://theme/icon-m-favorite"
		    anchors.verticalCenter: parent.verticalCenter
	        }
            }
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "se connecter"
                enabled: (app_token_status == "unknown" || JS.appTokenIsError())
                visible: (session_token.length == 0)
                onClicked: JS.getAppTokenStatus()
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
            }
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

	    BusyIndicator {
	   	id: busy
                visible: (session_token.length == 0 &&
                          (app_token_status == "fetching" ||
                           app_token_status == "pending" ||
                           app_token_status == "granted"))
                running: visible
                size: BusyIndicatorSize.Large
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            delegate: BackgroundItem {
                width: grid.cellWidth
                height: grid.cellHeight
                enabled: (session_token.length > 0)
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
                onClicked:  pageStack.push((model.page == "callPage")?callPage:null)
            }
        }
    }

    CoverBackground {
        id: cover
    }

    onApp_token_statusChanged: if (app_token_status == "granted") JS.getSessionToken()
}
