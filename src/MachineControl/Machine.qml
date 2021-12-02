import QtQuick 2.0
import QuickHub 1.0

MachineControl
{

    id: docroot

    property string tag
    property string group
    property string displayName
    property string deviceID: docroot.device
    property string suction
    property bool dependsOnSuction: false

    pricePerUnit: device.pricePerUnit
    onCurrentUserChanged: device.setProperty("currentUser", currentUser)
    onUserNameChanged: device.setProperty("currentUserName", userName)
    onStateChanged: device.setProperty("state", state)
    onJobStartedTimestampChanged: device.setProperty("start", jobStartedTimestamp)
    onCurrentUnitsChanged: device.setProperty("currentUnits", currentUnits)
    onHealthyStateChanged:
    {
        device.setProperty("ready", healthyState)
    }
    signal setSuction(string machineID, string suctionID)
    signal removeSuction(string machineID, string suctionID)

    Component.onCompleted:
    {
        device.registerProperty("pricePerUnit", function(data)
        {
            device.setProperty("pricePerUnit", data.val)
            docroot.pricePerUnit = data.val
        });

        device.registerPropertyWithInitValue("unitDuration", function(data)
        {
            docroot.unitDuration = data.val
            device.setProperty("unitDuration", docroot.unitDuration)
        }, 60000);

        device.registerPropertyWithInitValue("suction", function(data)
        {
            var val = data.val
            if(val === "")
            {
                docroot.removeSuction(deviceID, docroot.suction)
                docroot.suction = val
            }
            else
            {
                if(docroot.suction !== "")
                    docroot.removeSuction(deviceID, docroot.suction)

                docroot.suction = val
                docroot.setSuction( deviceID, val);
            }

            device.setProperty("suction", docroot.suction)
        }, "");

        device.registerPropertyWithInitValue("dependsOnSuction", function(data)
        {
            docroot.dependsOnSuction = data.val
            device.setProperty("dependsOnSuction", docroot.dependsOnSuction)
        }, false)

        device.registerPropertyWithInitValue("minimumBalance", function(data)
        {
            docroot.minimumBalance = data.val
            device.setProperty("minimumBalance", docroot.minimumBalance)
        }, 0);

        device.registerPropertyWithInitValue("employeesForFree", function(data)
        {
            docroot.employeesForFree = data.val
            device.setProperty("employeesForFree", docroot.employeesForFree)
        }, false);

        device.registerPropertyWithInitValue("payMode", function(data)
        {
            docroot.payMode = val
            device.setProperty("payMode", docroot.payMode)
        }, 0);

        device.registerPropertyWithInitValue("idleTimeTimeout", function(data)
        {
            docroot.idleTimeTimeout = data.val
            device.setProperty("idleTimeTimeout", docroot.idleTimeTimeout)
        },  60000);

        device.registerPropertyWithInitValue("activityTimeout", function(data)
        {
            docroot.machineActivityTimeout = data.val
            device.setProperty("activityTimeout", docroot.machineActivityTimeout)
        }, 2000);

        device.registerPropertyWithInitValue("activityThreshold", function(data)
        {
            docroot.machineActivityThreshold = data.val
            device.setProperty("activityThreshold", docroot.machineActivityThreshold)
        }, 0.5);

        device.registerPropertyWithInitValue("enabled", function(data)
        {
            docroot.enabled = data.val
            device.setProperty("enabled", data.val)
        }, true);


        device.registerProperty("tag", function(data)
        {
            device.setProperty("tag", data.val)
            docroot.type = data.val
        });

        device.registerPropertyWithInitValue("displayName",
            function(data)
            {
                docroot.displayName = data.val
                device.setProperty("displayName", docroot.displayName)
            },
            docroot.displayName == undefined ? docroot.device : docroot.displayName
        );

        device.registerProperty("group", function(data)
        {
            device.setProperty("group", data.val)
            docroot.group = data.val
        });

        device.registerPropertyWithInitValue("machineInitTime", function(data)
        {
            docroot.machineInitTime = data.val
            device.setProperty("machineInitTime", docroot.machineInitTime)
        },
        1000
        );

        device.registerPropertyWithInitValue("readerHook", function(data)
        {
            docroot.readerHook = data.val
            device.setProperty("readerHook", docroot.readerHook)
        }, docroot.device +"/reader");

        device.registerPropertyWithInitValue("switchHook", function(data)
        {
            docroot.switchHook = data.val
            device.setProperty("switchHook", docroot.switchHook)
        }, docroot.device +"/pow");

        device.setProperty("start", 0)
        device.setProperty("price", 0)
        device.setProperty("currentUnits", 0)
        device.setProperty("ready", docroot.healthyState)
        device.setProperty("currentUser", docroot.currentUser)
        device.setProperty("currentUserName", docroot.userName)
        device.setProperty("state", 0)
        device.setProperty("deviceID", docroot.device)

        device.start()

    }

    Device
    {
        id: device
        uuid:docroot.deviceID
        type: "Controller/AccessControl"
    }
}
