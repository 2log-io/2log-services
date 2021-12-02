import QtQuick 2.0
import QuickHub 1.0

Item
{
    id: docroot
    property int pricePerUnit
    property string readerHook: docroot.device + "/reader"
    property string device
    property string description
    property string currentUser

    Device
    {
        id: device
        uuid:docroot.device+"-PayMod"
        type: "PayModule"
    }


    Timer
    {
        id: checkTimer
        interval: 3000
    }

    Component.onCompleted:
    {
        device.registerProperty("pricePerUnit", function(data)
        {
            device.setProperty("pricePerUnit", data.val)
            docroot.pricePerUnit = data.val
        });

        device.registerProperty("descriptionText", function(data)
        {
            device.setProperty("descriptionText", data.val)
            docroot.description = data.val
        });

        device.registerProperty("readerHook", function(data)
        {
            var val
            if(data.val === undefined)
            {
                val = docroot.device +"/reader"
            }
            else
            {
                val = data.val
            }
            docroot.readerHook = val
            device.setProperty("readerHook", docroot.machineInitTime)
        });

        device.start();
    }

    CardValidator
    {
        id: cardValidator
        readerHook: docroot.readerHook
        needsPermission: false
        onValidCardDetected:
        {
            if(!checkTimer.running)
            {
                docroot.currentUser = data.userID
                chargeUnit()
            }
            checkTimer.start()
        }
    }

    ServiceModel
    {
        id: labService
        service: "lab"
    }

    function chargeUnit(userID)
    {
        if(!checkTimer.running)
            labService.call("chargeUser",{"userID": docroot.currentUser, "value": docroot.pricePerUnit * -1}, docroot.chargeCb)
    }

    function chargeCb(data)
    {
        sendBill()
    }

    function sendBill()
    {
        labService.call("sendBill",
        {
            "resourceID": docroot.device,
            "description": docroot.description,
            "cardID": cardValidator.lastCardID,
            "end": new Date(),
            "start": new Date(),
            "userID": docroot.currentUser,
            "price": docroot.pricePerUnit,
            "units": 1
        }, function(){})

        cardValidator.reader.triggerFunction("showAccept",{})
    }

}
