/*
 * CallCover.qml
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
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "loader.js" as JS
import org.nemomobile.contacts 1.0

ListView {
    property variant refresh: null
    property int iconWidth: callIcons.width - 2 * Theme.paddingSmall

    clip: true
    model: callLog
    interactive: false
    visible: count > 0

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
    
    delegate: ListItem {
	property Person contact: (model.number && people.populated)?people.personByPhoneNumber(model.number):null

        id: listItem
        contentHeight: Theme.fontSizeSmall + 2 * Theme.paddingSmall
        width: parent.width
        Rectangle {
            anchors.fill: parent
            color: index % 2 == 0 ? "transparent" : Theme.secondaryHighlightColor
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
            Label {
                anchors.fill: parent
                anchors.leftMargin: Theme.paddingSmall + iconWidth
                /*anchors.rightMargin: Theme.paddingLarge*/
                text: (model.number) ? (contact) ? contact.displayLabel : model.name : "appel masqué"
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeSmall
                anchors.verticalCenter: parent.verticalCenter
                truncationMode: TruncationMode.Fade
            }
            /*Label {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                text: Qt.formatDateTime(new Date(model.datetime * 1000), "hh:mm")
            }*/
        }
    }

    Component.onCompleted: if (session_token.length > 0) {
        JS.requestCallLog(callLog, 3) } else {
        JS.getCachedCalls(callLog, 3) }
}