/**
 * Copyright (C) 2018 Willem-Jan de Hoog
 *
 * License: MIT
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

import "../Spotify.js" as Spotify
import "../Util.js" as Util

Dialog {
    id: itemPicker

    property string label: ""
    property var selectedItem

    property int currentIndex: -1

    ListModel { id: items }

    SilicaListView {
        id: view

        anchors.fill: parent
        model: items

        VerticalScrollDecorator { flickable: view }

        header: DialogHeader {
            acceptText: qsTr("OK")
            cancelText: qsTr("Cancel")
        }

        delegate: ListItem {
            id: delegateItem

            width: parent.width - 2*Theme.paddingMedium
            x: Theme.paddingMedium
            contentHeight: Theme.itemSizeLarge

            onClicked: {
                selectedItem = items.get(index)
                currentIndex = index
            }

            SearchResultListItem {
                id: searchResultListItem
                dataModel: model
            }
        }

        section.property: "type"
        section.delegate : Component {
            id: sectionHeading
            Item {
                width: parent.width - 2*Theme.paddingMedium
                x: Theme.paddingMedium
                height: childrenRect.height

                Text {
                    width: parent.width
                    text: label
                    font.bold: true
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.highlightColor
                    horizontalAlignment: Text.AlignRight
                }
            }
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Create Playlist")
                onClicked: app.createPlaylist(function(error, data) {
                    if(data) {
                        refresh()
                    }
                })
            }
            MenuItem {
                text: qsTr("Load Previous Set")
                enabled: cursorHelper.canLoadPrevious
                onClicked: cursorHelper.previous()
            }
        }
        PushUpMenu {
            MenuItem {
                text: qsTr("Load Next Set")
                enabled: cursorHelper.canLoadNext
                onClicked: cursorHelper.next()
            }
        }
    }

    CursorHelper {
        id: cursorHelper

        onLoadNext: refresh()
        onLoadPrevious: refresh()
    }

    onLabelChanged: refresh() // ToDo come up with a better trigger

    function refresh() {
        Spotify.getUserPlaylists({offset: cursorHelper.offset, limit: cursorHelper.limit},function(error, data) {
            if(data) {
                console.log("number of playlists: " + data.items.length)
                items.clear()
                cursorHelper.offset = data.offset
                cursorHelper.total = data.total
                for (var i=0;i<data.items.length;i++) {
                    items.append({type: 2,
                                  stype: 2,
                                  name: data.items[i].name,
                                  playlist: data.items[i]});
                }
            } else
                console.log("No Data for getUserPlaylists")
        })
    }
}

