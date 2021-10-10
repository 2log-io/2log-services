import QtQuick 2.0
import CloudAccess 1.0

Item
{
    id: docroot
    property string tag
    property string displayName
    property string group
    property string device
    property string currentUser
    property string userName
    property int state: 0
    property string lastCardID

    onCurrentUserChanged: device.setProperty("currentUser", currentUser)
    onUserNameChanged: device.setProperty("currentUserName", userName)
    onStateChanged: device.setProperty("state", state)
    onEnabledChanged:
    {
        smle.getProperty("state").value = enabled ? 0 : -2
    }


    Device
    {
        id: device
        uuid:docroot.device+"-Controller"
        type: "HandController"
    }

    Component.onCompleted:
    {
        device.setProperty("currentUser", docroot.currentUser)
        device.setProperty("currentUserName", docroot.userName)
        device.setProperty("state", 0)
        device.setProperty("deviceID", docroot.device)
        device.registerProperty("tag", function(data)
        {
            device.setProperty("tag", data.val)
            docroot.type = data.val
        });

        device.registerProperty("displayName", function(data)
        {
            device.setProperty("displayName", data.val)
            docroot.type = data.val
        });

        device.registerProperty("group", function(data)
        {
            device.setProperty("group", data.val)
            docroot.group = data.val
        });

        device.registerProperty("enabled", function(data)
        {
            device.setProperty("enabled", data.val)
            docroot.enabled = data.val
        });
        device.start()
    }

    DeviceModel
    {
        id: smle

        resource: docroot.device+"/smle"
        onDeviceOnlineChanged:
        {
            if(!smle.deviceOnline)
            {
                docroot.state = 0
            }
            else
            {
               smle.getProperty("state").value = enabled ? 0 : -2
            }
        }
        onDataReceived:
        {
            console.log(subject)
            logService.call("hasPermission", {"resourceID": docroot.device, "cardID": subject}, docroot.cb)
        }
    }


    function cb(data)
    {
        console.log(JSON.stringify(data))
        if(data.errorCode === 0)
        {

            if(state == 0 && docroot.enabled)
            {
                docroot.state = 1;
                smle.getProperty("on").value = true
                smle.getProperty("state").value = 1
                smle.getProperty("state").value = 1
                smle.triggerFunction("showAccept",{})
                docroot.currentUser = data.userID
            }
            else
            {
                if(docroot.currentUser == data.userID)
                {
                    docroot.state = 0;
                    smle.getProperty("on").value = false
                    smle.getProperty("state").value = 0
                    docroot.currentUser = ""
                }
                else
                {
                    smle.triggerFunction("showError",{});
                }
            }
        }
        else
        {
            docroot.invalidCardDetected(data)
            smle.triggerFunction("showError",{})
        }
    }

    ServiceModel
    {
        id: logService
        service: "lab"
    }
}
