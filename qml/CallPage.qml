/*
 * CallPage.qml
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
import Sailfish.Contacts 1.0
import org.nemomobile.contacts 1.0
    
Page {
    id: page
    anchors.fill: parent

    property int iconWidth: callIcons.width - 2 * Theme.paddingSmall

    /* These lines are copied from voice-ui-jolla. */
    Person {
        id: temporaryPerson
    }
    Component {
        id: contactCardPageComponent
        TemporaryContactCardPage {}
    }

    function openContactCard(person, remoteUid) {
        if (!person) {
            temporaryPerson.phoneNumbers = [ remoteUid ]
        }
        pageStack.push(contactCardPageComponent, { 'contact': (person ? person : temporaryPerson) })
    }
    /* End of voice-ui-jolla. */

    PeopleModel {
	id: people
	filterType: PeopleModel.FilterAll
	requiredProperty: PeopleModel.PhoneNumberRequired
	searchableProperty: PeopleModel.FetchPhoneNumber
    }

    Image {
        // used to determine the icon width to align everything
        id: callIcons
        visible: false
        source: "image://theme/icon-m-missed-call"
    }

    Formatter {
        id: formatter
    }

    SilicaListView {
        id: call_list
        header: Column {
            width: page.width
            PageHeader {
                width: parent.width
                title: "Liste des appels"
            }
            Label {
                function timestamp() {
                    var ref = new Date(callLog.refresh)
                    var moment = formatter.formatDate(ref, Formatter.TimepointRelative)
                    var elapsed = formatter.formatDate(ref, Formatter.DurationElapsed)
                    return "Liste établie " + elapsed + " (" + moment + ")"
                }
                width: parent.width
                color: Theme.secondaryColor
                text: timestamp()
            }
        }
        PullDownMenu {
            visible: (httpRequest != null) || (session_token.length > 0)
            MenuItem {
                visible: session_token.length > 0
                text: "Rafraîchir la liste"
                onClicked: JS.requestCallLog()
            }
            MenuItem {
                visible: (httpRequest != null)
                text: "Annuler la requète réseau"
                onClicked: if (httpRequest != null) { httpRequest.abort() }
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

        NetworkIndicator {
            visible: (httpRequest != null)
            label: httpLabel
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }

        delegate: ListItem {
	    property Person contact: (model.number && people.populated)?people.personByPhoneNumber(model.number):null
            id: listItem
            contentHeight: Theme.itemSizeSmall
            Row {
                spacing: Theme.paddingSmall
                anchors.fill: parent
                Item {
                    width: iconWidth
                    height: parent.height
                    anchors.leftMargin: Theme.paddingSmall
                    Image {
                        source: JS.call(model.type)
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: Theme.paddingSmall + iconWidth
                    Label {
                        color: (model.number) ? (listItem.highlighted) ? Theme.highlightColor : Theme.primaryColor : (listItem.highlighted) ? Theme.secondaryHighlightColor : Theme.secondaryColor
                        text: (model.number) ? (contact) ? contact.displayLabel : model.name : "appel masqué"
                    }
                    Label {
                        color: listItem.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeSmall
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.paddingLarge
                        text: model.number
                        visible: (model.number.length > 0 && (contact || model.number != model.name))
                    }
                }
            }
            Column {
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                Label {
                    anchors.right: parent.right
                    color: listItem.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                    text: "( " + JS.duration(model.duration) + " )"
                }
                Label {
                    color: listItem.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                    text: Qt.formatDateTime(new Date(model.datetime * 1000), "le dd/MM à hh:mm")
                }
            }
            onClicked: if (model.number) openContactCard(contact, model.number)
        }
	VerticalScrollDecorator { flickable: call_list }
    }

    Component.onCompleted: if (session_token.length > 0) {
        JS.requestCallLog() } else {
        JS.getCachedCalls(callLog, callLog.lastNDays) }
}
