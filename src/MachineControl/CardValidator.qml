import QtQuick 2.0
import CloudAccess 1.0

Item
{
    id:docroot
    property string     readerHook
    property string     machine
    property bool       deviceOnline: reader.deviceOnline
    property bool       initialized: reader.initialized
    property bool       needsPermission: true
    signal              validCardDetected(var data)
    signal              invalidCardDetected(var data)
    property alias      reader: reader
    property alias      resource: reader.resource
    property string     lastCardID
    property int        minimumBalance

    Timer
    {
        id: avoidDoubleDetectionTimer
        interval: 500
    }

    DeviceModel
    {
        id: reader
        resource: docroot.readerHook
        onDataReceived:
        {
            if(avoidDoubleDetectionTimer.running)
            {
                return
            }

            avoidDoubleDetectionTimer.start()
            docroot.lastCardID = subject
            if(docroot.needsPermission)
            {
                logService.call("hasPermission", {"resourceID": docroot.machine, "cardID": subject}, docroot.cb)
            }
            else
            {
                logService.call("getUserForCard", {"cardID": subject}, docroot.cb2 )
            }
        }
    }


    function cb2(data)
    {
        console.log(JSON.stringify(data))
        if(data.errorCode === 0)
            docroot.validCardDetected(data)
        else
        {
            reader.triggerFunction("showError",{})
            docroot.invalidCardDetected(data)
        }
    }
    function cb(data)
    {
        if(data.errorCode === 0)
        {
            docroot.validCardDetected(data)
        }
        else
        {
            docroot.invalidCardDetected(data)
            reader.triggerFunction("showError",{})
        }
    }

    ServiceModel
    {
        id: logService
        service: "lab"
    }
}
