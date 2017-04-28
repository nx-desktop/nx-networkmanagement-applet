/*
    Copyright 2013-2017 Jan Grulich <jgrulich@redhat.com>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) version 3, or any
    later version accepted by the membership of KDE e.V. (or its
    successor approved by the membership of KDE e.V.), which shall
    act as a proxy defined in Section 6 of version 3 of the license.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.2
import QtQuick.Layouts 1.3
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import org.kde.kquickcontrolsaddons 2.0

FocusScope {
    property var notificationInhibitorLock: undefined

    PlasmaNM.AvailableDevices {
        id: availableDevices
    }

    PlasmaNM.NetworkModel {
        id: connectionModel
    }

    PlasmaNM.AppletProxyModel {
        id: appletProxyModel

        sourceModel: connectionModel
    }

    Toolbar {
        id: toolbar

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
    }

    PlasmaExtras.ScrollArea {
        id: scrollView

        anchors {
            bottom: actions.top
            left: parent.left
            right: parent.right
            top: toolbar.bottom
        }

        ListView {
            id: connectionView

            property bool availableConnectionsVisible: false
            property int currentVisibleButtonIndex: -1

            anchors.fill: parent
            clip: true
            model: appletProxyModel
            currentIndex: -1
            boundsBehavior: Flickable.StopAtBounds
            section.property: showSections ? "Section" : ""
            section.delegate: Header { text: section }
            delegate: ConnectionItem { }
        }
    }

    GridLayout {
        id: actions
        columns: 2
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: 12
        }

        PlasmaComponents.ToolButton {
            Layout.fillWidth: true
            iconSource: "preferences-system-network"
            tooltip: i18n("Configure system proxy...")

            text: i18n("Proxy")
            onClicked: {
                KCMShell.open(["proxy"])
            }
        }
        PlasmaComponents.ToolButton {
            Layout.fillWidth: true
            iconSource: "document-share"
            tooltip: i18n("Configure shared resources...")

            text: i18n("Shared resources")
            onClicked: {
                KCMShell.open(["smb"])
            }
        }

        PlasmaComponents.ToolButton {
            Layout.fillWidth: true
            iconSource: "preferences-web-browser-ssl"
            tooltip: i18n("Configure ssl certificates...")

            text: i18n("SSL Certificates")
            onClicked: {
                KCMShell.open(["kcm_ssl"])
            }
        }
        PlasmaComponents.ToolButton {
            Layout.fillWidth: true
            iconSource: "network-card"
            tooltip: i18n("View network interfaces...")

            text: i18n("Network Interfaces")
            onClicked: {
                KCMShell.open(["nic"])
            }
        }
    }

    Connections {
        target: plasmoid
        onExpandedChanged: {
            connectionView.currentVisibleButtonIndex = -1;
            if (expanded) {
                var service = notificationsEngine.serviceForSource("notifications");
                var operation = service.operationDescription("inhibit");
                operation.hint = "x-kde-appname";
                operation.value = "networkmanagement";
                var job = service.startOperationCall(operation);
                job.finished.connect(function(job) {
                    if (expanded) {
                        notificationInhibitorLock =  job.result;
                    }
                });
            } else {
                notificationInhibitorLock = undefined;
            }
        }
    }

    PlasmaCore.DataSource {
        id: notificationsEngine
        engine: "notifications"
    }
}
