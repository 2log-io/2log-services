import QtQuick 2.0
import QtQml.StateMachine 1.0 as DSM

Item {

    id: docroot

    property double         machineActivityThreshold
    property bool           intercept: false
    property int            machineActivityTimeout
    property int            idleTimeTimeout
    readonly property alias machineRunning: p.machineActive
    property real           machineCurrent
    property int            machineInitTime
    readonly property alias currentUser: p.currentUser
    property int            state
    signal                  jobFinished(int duration, string userID)
    signal                  wrongUser()
    signal                  machineDisabled()
    signal                  login(string user)
    signal                  logout(string user)
    onInterceptChanged: p.interceptChanged()


    onMachineCurrentChanged:
    {
        if(!waitForMachineInit.running)
        {
            if(machineCurrent >= machineActivityThreshold )
            {
                timer.stop()
                p.machineActive=true
                p.machineRunning()
            }
            else
            {
                if(!timer.running)
                {
                    timer.restart()
                }
            }
        }
    }

    Timer
    {
        id: waitForMachineInit
        interval: docroot.machineInitTime
    }

    Timer
    {
        id: timer
        interval: machineActivityTimeout
        onTriggered:   p.machineActive=false
    }

    QtObject
    {
        id: p

        property bool machineActive
        property string lastUser
        property string currentUser
        property date startTime


        onMachineActiveChanged:
        {
            if(machineActive)
                p.machineRunning()
            else
                p.machineFinished()
        }

        signal currentUserDetected()
        signal validUserDetected()
        signal machineRunning()
        signal machineFinished()
        signal interceptChanged()
        signal forceLogout()
    }


    function validCardDetected(userID)
    {
        if(docroot.state == 0 && !docroot.enabled)
        {
            docroot.machineDisabled()
                return;
        }

        p.lastUser = userID
        if(userID === p.currentUser)
        {
            p.currentUserDetected()
        }
        else
        {
            if(state > 0)
                docroot.wrongUser();
            else
                p.validUserDetected()
        }
    }

    function invalidCardDetected(userID)
    {
        if(docroot.state >= 1 && userID === p.currentUser)
        {
            p.currentUserDetected()
        }
    }

    function forceLogout()
    {
        p.forceLogout()
    }

    DSM.StateMachine
    {
        initialState: idle
        running: true

        DSM.State
        {
            id: maintainance

            onEntered:
            {
                p.currentUser = ""
                docroot.state = -3
            }

            DSM.SignalTransition
            {
                signal:  docroot.enabledChanged
                guard: docroot.enabled
                targetState: idle
            }
        }

        DSM.State
        {
            id: idle

            DSM.SignalTransition
            {
                signal:  docroot.enabledChanged
                guard: !docroot.enabled
                targetState: maintainance
            }

            DSM.SignalTransition
            {
                signal: p.validUserDetected
                targetState: loggedIn
                guard: !docroot.intercept
                onTriggered:
                {
                    waitForMachineInit.start()
                    p.currentUser = p.lastUser
                    docroot.login(p.currentUser)
                }
            }

            DSM.SignalTransition
            {
                signal: p.validUserDetected
                targetState: intercepted
                guard: docroot.intercept
            }


            onEntered:
            {
                p.currentUser = ""
                docroot.state = 0
            }
        }

        DSM.State
        {

            id: intercepted

            // intercepted --> Idle nach 10 sek Timeout
            DSM.TimeoutTransition
            {
                timeout: docroot.idleTimeTimeout // * 60 * 1000
                targetState: idle
            }

            // intercepted --> Idle wenn selber User noch mal die Karte dranhält
            DSM.SignalTransition
            {
                signal:  p.currentUserDetected
                targetState: idle
            }

            // intercepted --> Logged In wenn Bedingung erfüllt
            DSM.SignalTransition
            {
                signal: p.interceptChanged
                targetState: loggedIn
                guard: docroot.intercept == false
                onTriggered:
                {
                    p.currentUser = p.lastUser
                    docroot.login(p.currentUser)
                    waitForMachineInit.start()
                }
            }

            onEntered:
            {
                p.currentUser = p.lastUser
                docroot.state = -1
            }
        }

        DSM.State
        {
            id: errorWhileRunning

            // ErrorImBetrieb --> läuft  wenn Bedingung wieder erfüllt
            DSM.SignalTransition
            {
                signal: p.interceptChanged
                targetState: running
                guard: docroot.intercept == false && docroot.machineRunning
            }

            // ErrorImBetrieb --> Intercepted wenn Maschine aufhört zu arbeiten
            DSM.SignalTransition
            {
                targetState: intercepted
                signal: p.machineFinished
                onTriggered: docroot.jobFinished(new Date - p.startTime, p.currentUser)
            }

            onEntered:
            {
                docroot.state = -2
            }
        }


        DSM.State
        {
            id: loggedIn


            DSM.SignalTransition
            {
                signal:  p.forceLogout
                targetState: idle
                onTriggered: docroot.logout(p.currentUser)
            }


            DSM.SignalTransition
            {
                signal:  docroot.enabledChanged
                guard: !docroot.enabled
                targetState: maintainance
                onTriggered: docroot.logout(p.currentUser)
            }

            // LoggedIn --> Idle wenn selber User noch mal die Karte dranhält
            DSM.SignalTransition
            {
                signal:  p.currentUserDetected
                targetState: idle
                onTriggered: docroot.logout(p.currentUser)
            }

            // LoggedIn --> Idle  nach Timeout
            DSM.TimeoutTransition
            {
                timeout: docroot.idleTimeTimeout // * 60 * 1000
                targetState: idle
                onTriggered: docroot.logout(p.currentUser)
            }

            // LoggedIn --> running  wenn Maschine gestartet wird
            DSM.SignalTransition
            {
                targetState: running
                signal: p.machineRunning
                onTriggered: p.startTime = new Date()
            }

            // LoggedIn --> Intercepted  wenn Bedingung nicht (mehr) erfüllt
            DSM.SignalTransition
            {
                targetState: intercepted
                signal: p.interceptChanged
                guard: docroot.intercept == true
            }

            onEntered:
            {
                docroot.state = 1
            }
        }

        DSM.State
        {
            id: running

//            DSM.SignalTransition
//            {
//                targetState: idle
//                signal: p.validCardDetected
//            }


            DSM.SignalTransition
            {
                signal:  p.forceLogout
                targetState: idle
                onTriggered: docroot.logout(p.currentUser)
            }

            // running -> ErrorImBetrieb wenn mitten im betrieb Bedingung nicht mehr erfüllt
            DSM.SignalTransition
            {
                targetState: errorWhileRunning
                signal: p.interceptChanged
                guard: docroot.intercept == true
            }


            DSM.SignalTransition
            {
                targetState: loggedIn
                signal: p.machineFinished
                guard: docroot.enabled
                onTriggered: docroot.jobFinished(new Date - p.startTime, p.currentUser)
            }

            DSM.SignalTransition
            {
                targetState: maintainance
                signal: p.machineFinished
                guard: !docroot.enabled
                onTriggered:
                {
                    docroot.jobFinished(new Date - p.startTime, p.currentUser)
                    onTriggered: docroot.logout(p.currentUser)
                }
            }

            onEntered:
            {
                docroot.state = 2
            }
        }
    }
}
