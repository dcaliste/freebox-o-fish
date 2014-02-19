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

    property variant refresh: Date()
    property int lastNDays: 0
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

    SilicaListView {
        id: call_list
        header: Column {
            width: page.width
            PageHeader {
                width: parent.width
                title: "Liste des appels"
            }
            Label {
                width: parent.width
                color: Theme.secondaryColor
                text: "Liste établie " + Qt.formatDateTime(new Date(refresh),
                                                           "le dd/MM à hh:mm") 
            }
        }
        PullDownMenu {
            visible: session_token.length > 0
            MenuItem {
                text: "Rafraîchir la liste"
                onClicked: JS.getCachedCalls(callLog, lastNDays)
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

	BusyIndicator {
	    id: busy
            visible: (callLog.count == 0)
            running: visible
            size: BusyIndicatorSize.Large
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
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: model.number
                        visible: (model.number.length > 0 && (contact || model.number != model.name))
                    }
                }
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    color: listItem.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                    text: "( " + JS.duration(model.duration) + " )"
                }
            }
            Label {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                color: listItem.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                text: Qt.formatDateTime(new Date(model.datetime * 1000), "le dd/MM à hh:mm")
            }
            onClicked: if (model.number) openContactCard(contact, model.number)
        }
	VerticalScrollDecorator { flickable: call_list }
    }

    Component.onCompleted: if (session_token.length > 0) {
        JS.requestCallLog(callLog, lastNDays) } else {
        JS.getCachedCalls(callLog, lastNDays) }
}
