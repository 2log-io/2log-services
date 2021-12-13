import QtQuick 2.9
import QuickHub 1.0
import "MachineControl"
import QtQml 2.0
import LogicController 1.0

Item {
    id: docroot

    SynchronizedListModel {
        id: suctionsModel
        resource: "2log/controller/suctions"
    }

    Instantiator {
        id: suctions
        model: suctionsModel
        Suction {
            id: suction
            deviceID: model.deviceID
            displayName: name

            Component.onCompleted: {
                deviceLookup.addObject(suction, deviceID)
            }
        }
    }

    SynchronizedListModel {
        id: controllerModel
        resource: "2log/controller/machines"
    }

    Instantiator {
        id: machines
        model: controllerModel

        Machine {
            id: machine
            device: model.deviceID
            displayName: name

            Component.onCompleted: {
                deviceLookup.addObject(machine, device)
            }

            onSuctionChanged: console.log(suction)
            onSetSuction: {
                var suction = deviceLookup.getObject(suctionID)
                if (suction === null) {
                    return
                }

                if (true) {
                    machine.intercept = Qt.binding(function () {
                        return dependsOnSuction && !deviceLookup.getObject(
                                    suctionID).running
                    })
                }

                suction.addMachine(machineID)
            }
            onRemoveSuction: {
                machine.intercept = false
                var suction = deviceLookup.getObject(suctionID)
                if (suction === null) {
                    return
                }

                suction.removeMachine(machineID)
            }
        }
    }

    SynchronizedListModel {
        id: monitoringModel
        resource: "2log/controller/monitoring"
    }

    Instantiator {
        id: monitoring
        model: monitoringModel

        SwitchMonitoringController {
            deviceID: model.deviceID
            displayName: name
            deviceType: "Controller/Monitoring"
        }
    }

    // SETUP ##################################################
    Component.onCompleted: {
        Connection.serverUrl = qh_url
    }

    Timer {
        id: reconnectTimer
        interval: 1000
        onTriggered: Connection.reconnectServer()
    }

    Connections {
        target: Connection
        onStateChanged: {
            if (Connection.state == Connection.STATE_Connected) {
                UserLogin.login(qh_user, qh_password)
                reconnectTimer.running = false
            }

            if (Connection.state == Connection.STATE_Disconnected) {
                reconnectTimer.start()
            }
        }
    }
}
