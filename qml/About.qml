/*
 * About.qml
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

Page {
    anchors.fill: parent

    PageHeader {
        title: "À propos"
    }

    Column {
        anchors.centerIn: parent

        spacing: Theme.paddingLarge

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "(Free) Box-o-fish"
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeLarge
        }
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "un compagnon pour le serveur Freebox"
            color: Theme.primaryColor
        }
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
	    horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Theme.fontSizeExtraSmall
            text: "Version 0.1\nCopyright © 2014 Damien Caliste"
            color: Theme.secondaryColor
        }
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
	    horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Theme.fontSizeSmall
            text: "Box-o-fish est un logiciel libre,\n" +
            "publié sous licence\n" +
            "GNU General Public License v.3"
            color: Theme.secondaryColor
        }
    }
    Label {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: Theme.fontSizeExtraSmall
        text: "https://github.com/dcaliste/freebox-o-fish"
        color: Theme.secondaryColor
    }
}