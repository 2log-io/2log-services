import QtQuick 2.0
import MachineControl 1.0
import QuickHub 1.0

Item
{
    id: docroot

    property string         boxName
    property int            pricePerUnit
    property int            unitDuration
    property int            payMode
    property string         tag
    property string         displayName
    property string         group
    property string         boxHook
    property string         currentUser
    property string         userName
    readonly property int   currentUnits: 0
    property int            state: 0
    property date           startTimestamp
    property alias box:     cardValidator.reader

    pricePerUnit: device.pricePerUnit
    onCurrentUserChanged: device.setProperty("currentUser", currentUser)
    onUserNameChanged: device.setProperty("currentUserName", userName)
    onStateChanged: device.setProperty("state", state)
    onStartTimestampChanged: device.setProperty("start", startTimestamp)
    onCurrentUnitsChanged: device.setProperty("currentUnits", currentUnits)
    property bool doorOpen: docroot.box.getProperty("doorOpen").value

    CardValidator
    {
        id: cardValidator
        readerHook: docroot.boxHook
        machine: docroot.boxName
        needsPermission: false
        onValidCardDetected:
        {
            docroot.userName = data.userName
            console.log(JSON.stringify(data.userID))
            cardDetected(data.userID)
        }

        onInvalidCardDetected:
        {
            console.log("INVALID ")
            docroot.box.triggerFunction("showError", {})
        }
    }




    Timer
    {
        // this timer charges the user wallet each minute
        id: payTimer
        running: docroot.state == 1
        repeat: true
        interval: docroot.unitDuration
        onRunningChanged:
        if(running)
        {
            // Job starts
            if(docroot.payMode == 0 || docroot.payMode == 1)
            {
                console.log("Start payment timer")
                console.log("B")
                chargeUnit()
            }
        }
        else
        {
            console.log("Stop payment timer")
        }

        onTriggered:
        {
            if(docroot.payMode == 0)
            {
                console.log("CHARGE!"+ docroot.currentUser)
                console.log("C")
                chargeUnit()
            }
        }
    }

    function chargeUnit()
    {
        console.log("CHARGE")
        labService.call("chargeUser",{"userID":docroot.currentUser, "value": docroot.pricePerUnit * -1}, docroot.chargeCb)
        p.currentUnits ++
        p.jobUnits ++
    }

    function chargeCb(data)
    {
    }


    onDoorOpenChanged:
    {
        if(doorOpen == true)
            return

        if(state == 1)
        {
            console.log("state -1")
            docroot.box.state = -1
        }

        if(state == 0 )
        {
            console.log("state -1")
            docroot.box.state = 0
        }
    }


    function cardDetected(userID)
    {
        docroot.box.triggerFunction("showAccept", {})
        if(docroot.state == 0)
        {
            if(!docroot.doorOpen)
            {
                docroot.box.triggerFunction("openDoor", {})
                docroot.currentUser = userID
                docroot.state = 1
                docroot.box.state = 1
                docroot.startTimestamp = new Date()
            }

        }
        else if(docroot.state == 1)
        {
            if(userID !== docroot.currentUser)
            {
                docroot.box.triggerFunction("showError", {})
                return
            }

            docroot.box.triggerFunction("showAccept", {})
            docroot.box.triggerFunction("openDoor", {})
            docroot.state = 0
            docroot.box.state = 1
        }
    }




    Device
    {
        id: device
        uuid:docroot.boxName+"-BoxController"
        type: "BoxController"
    }


    Component.onCompleted:
    {

        device.registerProperty("pricePerUnit", function(data)
        {
            device.setProperty("pricePerUnit", data.val)
            docroot.pricePerUnit = data.val
        });

        device.registerProperty("unitDuration", function(data)
        {
            var val
            if(data.val === undefined)
            {
                val = 60000
            }
            else
            {
                val = data.val
            }

            docroot.unitDuration = val
            device.setProperty("unitDuration", docroot.unitDuration)
        });


        device.registerProperty("payMode", function(data)
        {
            var val
            if(data.val === undefined)
            {
                val = 0
            }
            else
            {
                val = data.val
            }

            docroot.payMode = val
            device.setProperty("payMode", docroot.payMode)
        });

        device.registerProperty("tag", function(data)
        {
            device.setProperty("tag", data.val)
            docroot.type = data.val
        });

        device.registerProperty("displayName", function(data)
        {
            var val
            if(data.val === undefined)
            {
                val = docroot.device
            }
            else
            {
                val = data.val
            }

            docroot.displayName = val
            device.setProperty("displayName", docroot.displayName)
        });

        device.registerProperty("group", function(data)
        {
            device.setProperty("group", data.val)
            docroot.group = data.val
        });

        device.registerProperty("boxHook", function(data)
        {
            var val
            if(data.val === undefined)
            {
                val = docroot.boxName +"/box"
            }
            else
            {
                val = data.val
            }
            docroot.boxHook = val
            device.setProperty("boxHook", docroot.boxHook)
        });


        device.start()

        device.setProperty("displayName", docroot.displayName)
        device.setProperty("unitDuration", docroot.unitDuration)
        device.setProperty("start", 0)
        device.setProperty("price", 0)
        device.setProperty("currentUnits", 0)
        device.setProperty("currentUser", docroot.currentUser)
        device.setProperty("currentUserName", docroot.userName)
        device.setProperty("state", 0)
        device.setProperty("deviceID", docroot.boxName)
        device.setProperty("boxHook", docroot.switchHook )
    }
}
