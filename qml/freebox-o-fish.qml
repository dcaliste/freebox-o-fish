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
import org.nemomobile.contacts 1.0

ApplicationWindow {
    initialPage: page
    cover: cover

    property string freebox_id: "Vinéa"
    property string url: "http://mafreebox.freebox.fr"
    property string app_token_status: ""
    property string app_token: ""
    property int track_id: 0
    property string session_token: ""

    PeopleModel {
	id: people
	filterType: PeopleModel.FilterAll
	requiredProperty: PeopleModel.PhoneNumberRequired
	searchableProperty: PeopleModel.FetchPhoneNumber
    }
    
    Page {
        id: page
        anchors.fill: parent

        Timer {
            interval: 1000
            running: app_token_status == "pending"
            repeat: true
            onTriggered: JS.getAppTokenStatus()
        }

        ListModel {
            id: callLog
	    /*ListElement {
		number: "0233666597"
                type: "outgoing"
	    }
	    ListElement {
		number: "0476124578"
		name: "MAXIME"
	        type: "missed"
	    }
	    ListElement {
		number: "+84123456789"
		type: "incoming"
	    }*/
        }

        SilicaListView {
            id: call_list
            header: Column {
                PageHeader {
                    width: page.width
                    title: "(Free) Box-o-fish"
                    }
                Label {
                    text: "Liste des appels"
                }
            }

            model: callLog
            anchors.fill: parent
            anchors.rightMargin: Theme.paddingSmall
            anchors.leftMargin: Theme.paddingSmall

            section {
                property: 'section'

                delegate: SectionHeader {
                    text: section
                    height: Theme.itemSizeExtraSmall
                }
            }

            delegate: ListItem {
		property Person contact: (model.number && people.populated)?people.personByPhoneNumber(model.number):null
                contentHeight: Theme.itemSizeSmall
                Row {
                    spacing: Theme.paddingSmall
                    anchors.fill: parent
                    Image {
                        source: JS.call(model.type)
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        Label {
                            color: (model.number) ? Theme.primaryColor : Theme.secondaryColor
                            text: (model.number) ? (contact) ? contact.displayLabel : model.name : "appel masqué"
                        }
                        Label {
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: model.number
                            visible: (model.number.length > 0 && (contact || model.number != model.name))
                        }
                    }
                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        color: Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeExtraSmall
                        text: "( " + JS.duration(model.duration) + " )"
                    }
                }
                Label {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                    text: Qt.formatDateTime(new Date(model.datetime * 1000), "le dd/MM à hh:mm")
                }
            }
	    VerticalScrollDecorator { flickable: call_list }
        }

        Button {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Authorize"
            visible: (app_token_status == "unknown" || app_token_status == "timeout")
            MouseArea {
                anchors.fill: parent
                onClicked: JS.authorizeAppToken()
            }
        }

        Button {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Logout"
            visible: (session_token.length > 0)
            MouseArea {
                anchors.fill: parent
                onClicked: JS.logout()
            }
        }

        Button {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Login"
            visible: (session_token.length == 0 && app_token_status == "granted")
            MouseArea {
                anchors.fill: parent
                onClicked: JS.getSessionToken()
            }
        }

	Component.onCompleted: JS.getAppTokenStatus()
    }

    CoverBackground {
        id: cover
    }

    onApp_token_statusChanged: if (app_token_status == "granted") JS.getSessionToken()
    onSession_tokenChanged: if (session_token.length > 0) JS.getCallLog(callLog)
}
