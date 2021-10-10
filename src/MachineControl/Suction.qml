import QtQuick 2.0
import CloudAccess 1.0
import AddOns 1.0
Item
{

    id: docroot

    property string tag
    property string group
    property string displayName
    property string switchHook
    property string deviceID
    property double machineActivityThreshold
    property bool   running: deviceModel.getProperty("curr").value > machineActivityThreshold
    onRunningChanged: device.setProperty("state", running ? 2 : 0)
    property var    monitoredDevices: []


    function addMachine(machineID)
    {
        return watcher.addObject(machineID)
    }


    function removeMachine(machineID)
    {
        watcher.remove(machineID)
        return true
    }

    //property int current: deviceModel.getProperty("curr").value

    DeviceModel
    {
        id: deviceModel
        resource: docroot.switchHook
    }

    PropertyWatcher
    {
        id: watcher
        onIsLoggedInChanged:  deviceModel.on = isLoggedIn
        onMonitoredDeviceIDsChanged: device.setProperty("monitoredDevices", JSON.stringify(monitoredDeviceIDs))
    }


    Component.onCompleted:
    {
        device.registerProperty("activityThreshold", function(data)
        {
            var val
            if(data.val === undefined)
            {
                val = 0.5
            }
            else
            {
                val = data.val
            }

            docroot.machineActivityThreshold = val
            device.setProperty("activityThreshold", docroot.machineActivityThreshold)
        });

        device.registerProperty("monitoredDevices", function(data)
        {
            var val
            console.log("INPUT"+ data)
            if(data.val === undefined)
            {
                val = []
                docroot.monitoredDevices = val;
            }
            else
            {
                val = data.val
                docroot.monitoredDevices = JSON.parse(val)
                docroot.monitoredDevices.forEach(watcher.addObject)
                device.setProperty("monitoredDevices", JSON.stringify(watcher.monitoredDeviceIDs))
            }
        });

        device.registerProperty("enabled", function(data)
        {
            var val
            if(data.val === undefined)
            {
                val = true
            }
            else
            {
                val = data.val
            }
            docroot.enabled = val
            device.setProperty("enabled", val)
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
                if(docroot.displayName == undefined)
                    val = docroot.deviceID
                else
                    val = docroot.displayName
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

        device.registerProperty("switchHook", function(data)
        {
            var val
            if(data.val === undefined)
            {
                val = docroot.deviceID +"/switch"
            }
            else
            {
                val = data.val
            }

            docroot.switchHook = val
            device.setProperty("switchHook", docroot.switchHook)
        });

        device.start()
        device.setProperty("activityThreshold", docroot.machineActivityThreshold)
        device.setProperty("displayName", docroot.displayName)
        device.setProperty("enabled", docroot.enabled)
        device.setProperty("state", 0)
        device.setProperty("deviceID", docroot.deviceID)
        device.setProperty("switchHook", docroot.switchHook )
        device.setProperty("monitoredDevices", JSON.stringify(watcher.monitoredDeviceIDs))
        device.setProperty("group", docroot.group)

    }

    Device
    {
        id: device
        uuid:docroot.deviceID
        type: "Suction"
    }
}
