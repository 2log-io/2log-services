import QtQuick 2.0
import CloudAccess 1.0



MachineControlStateMachine
{
    id: docroot

    property string         device
    property string         userName
    property string         detectedUser
    property double         pricePerUnit
    property int            unitDuration
    property date           jobStartedTimestamp
    property date           loginStartedTimestamp
    property string         switchHook: docroot.device + "/pow"
    property string         readerHook: docroot.device + "/reader"
    readonly property int   currentUnits: p.currentUnits
    property int            payMode: 0
    property bool           employeesForFree: false
    property string         currentUserRole
    property int            minimumBalance
    property bool           deviceOn: pow.getProperty("on").value !== undefined ? pow.getProperty("on").value : false
    onDeviceOnChanged:      if(!deviceOn && state > 0) docroot.forceLogout()

    property int            healthyState:
    {
        if(!cardValidator.reader.available || !pow.available)
        {
            return -1
        }

        if(!cardValidator.reader.deviceOnline  || !pow.deviceOnline)
        {

            return -2
        }

        return 0
    }

    onLogin:
    {
        sendLogin(user, true)
        docroot.loginStartedTimestamp = new Date()
        if(payMode == 2) // Pauschale Abrechnung pro Login
        {
            chargeUnit()
        }
    }
    onLogout:
    {
        sendLogin(user, false)
        sendBill();
    }

    QtObject
    {
        id: p
        property int currentUnits: 0
        property int jobUnits: 0
        property bool charge: false
    }

    machineCurrent:
    {
        var curr = pow.getProperty("curr").value
        curr === undefined ? 0.0 : curr
    }

    onStateChanged:
    {
        if(state == -3) // maintainance
        {
            cardValidator.reader.getProperty("state").value = -2
            pow.getProperty("on").value = false;
            docroot.userName = ""
        }

        if(state == -2) // Error while running
        {
             cardValidator.reader.getProperty("state").value = -2
             //pow.getProperty("on").value = false;  //turn machine off on error?
        }

        if(state == -1) // intercepted
        {
             cardValidator.reader.getProperty("state").value = -1
             pow.getProperty("on").value = false;
        }

        if(state == 0)
        {
            cardValidator.reader.getProperty("state").value = 0
            pow.getProperty("on").value = false;
            docroot.userName = ""
        }

        if(state == 1) //logged in
        {
            cardValidator.reader.triggerFunction("showAccept",{})
            pow.getProperty("on").value = true;
            docroot.userName = docroot.detectedUser
            if(payMode == 3)
                cardValidator.reader.getProperty("state").value = 2
            else
                cardValidator.reader.getProperty("state").value = 1
        }

        if(state == 2)
        {
             cardValidator.reader.getProperty("state").value = 2
             docroot.jobStartedTimestamp = new Date()
        }
    }

    onEnabledChanged:
    {
        if(docroot.state !== 0)
            return;

        if(!enabled)
        {
            cardValidator.reader.getProperty("state").value = -2
        }
        else
        {
            cardValidator.reader.getProperty("state").value = 0
        }
    }

    onMachineDisabled: cardValidator.reader.triggerFunction("showError",{})
    onWrongUser:  cardValidator.reader.triggerFunction("showError",{})
    onJobFinished:
    {
        labService.call("sendJob",
        {
            "resourceID": docroot.device,
            "cardID": cardValidator.lastCardID,
            "end": new Date(),
            "start": docroot.jobStartedTimestamp,
            "userID": docroot.currentUser,
            "price": p.jobUnits * docroot.pricePerUnit,
            "units": p.jobUnits
        },chargeCb)
        p.jobUnits = 0
        p.charge = false
    }

    function chargeCb(data)
    {
    }

    Timer
    {
        interval: docroot.machineActivityTimeout
        running: docroot.state == 2
        onTriggered: p.charge = true
    }

    Timer
    {
        // this timer charges the user wallet each minute
        id: payTimer
        running: ((docroot.state == 2 || docroot.state == -2) && p.charge) || (docroot.state >= 1 && docroot.payMode == 3)
        repeat: true
        interval: docroot.unitDuration
        onRunningChanged:
        if(running)
        {
            // Job starts
            if(docroot.payMode == 0 || docroot.payMode == 1 || docroot.payMode == 3)
            {
                console.log("Start payment timer")
                chargeUnit()
            }
        }
        else
        {
            console.log("Stop payment timer")
        }

        onTriggered:
        {
            if(docroot.payMode == 0 || docroot.payMode == 3)
            {
                chargeUnit()
            }
        }
    }

    ServiceModel
    {
        id: labService
        service: "lab"
    }

    CardValidator
    {
        id: cardValidator
        minimumBalance: docroot.minimumBalance
        readerHook: docroot.readerHook
        machine: docroot.device

        onInvalidCardDetected:
        {
            docroot.invalidCardDetected(data.userID)
        }
        onValidCardDetected:
        {
            docroot.detectedUser = data.userName
            docroot.currentUserRole = data.userRole
            if(docroot.minimumBalance > 0 && data.balance < docroot.minimumBalance && docroot.state == 0)
            {
                cardValidator.reader.triggerFunction("showError",{})
                return;
            }
            docroot.validCardDetected(data.userID)

        }
    }

    function sendLogin(user, isLogin)
    {
        var log =
        {
            "cardID":cardValidator.lastCardID,
            "userID": user,
            "resourceID": docroot.device
        }

        if(isLogin)
            labService.call("login", log, function(){});
        else
            labService.call("logout", log, function(){});

    }


    function sendBill()
    {
        labService.call("sendBill",
        {
            "resourceID": docroot.device,
            "cardID": cardValidator.lastCardID,
            "end": new Date(),
            "start": docroot.loginStartedTimestamp,
            "userID": docroot.currentUser,
            "price": p.currentUnits * docroot.pricePerUnit,
            "units": p.currentUnits
        }, chargeCb)

        p.currentUnits = 0;
    }

    function chargeUnit()
    {
        console.log(docroot.currentUserRole)
        if(docroot.employeesForFree && docroot.currentUserRole === "empl")
            return;

        labService.call("chargeUser",{"userID":docroot.currentUser, "value": docroot.pricePerUnit * -1}, docroot.chargeCb)
        p.currentUnits ++
        p.jobUnits ++
    }

    DeviceModel
    {
        id: pow
        resource: docroot.switchHook
    }
}

