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

    PeopleModel {
	id: people
	filterType: PeopleModel.FilterAll
	requiredProperty: PeopleModel.PhoneNumberRequired
	searchableProperty: PeopleModel.FetchPhoneNumber
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
        header: PageHeader {
                width: page.width
                title: "Liste des appels"
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
            onClicked: if (model.number) openContactCard(contact, model.number)
        }
	VerticalScrollDecorator { flickable: call_list }
    }

    Component.onCompleted: if (session_token.length > 0) JS.getCallLog(callLog)
}
