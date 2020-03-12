# Anthony Rutledge
# aerutledge101@gmail.com
#
# https://www.linkedin.com/in/anthony-rutledge-2988b0125/
# https://stackoverflow.com/users/2495645/anthony-rutledge
#
# A Linux service library.
#
# 1) Makes managing services easier.
# 2) systemd edition :-)
# 
# ##########################################################
############################################################

function listServices ()
{
    systemctl list-unit-files --type=service | awk '{print $1}' | awk -F. '{print $1}'
}

function getServiceName ()
{
    declare -r SERVICE_NAME=$1
    listServices | grep -E "$SERVICE_NAME" | trim
}

function isService ()
{
    declare -r SERVICE=$1
    declare -r SERVICE_NAME=$(getSericeName $SERVICE)

    if [[ ! -z $SERVICE_NAME ]]
    then
        return 0
    fi

    return 1
}

function getServicePid ()
{
    declare -r SERVICE=$1
    systemctl status $(getServiceName $SERVICE) | grep "Main PID" | awk '{print $3}' | trim
}

function isServiceInstalled ()
{
    declare SERVICE=$1

    if isService $SERVICE
    then
        errorMessage "$SERVICE is not a service!"
        return 0
    fi

    return 1
}

function isServiceEnabled ()
{
    declare -r SERVICE=$1

    if ! isServiceInstalled $SERVICE
    then
        errorMessage "$SERVICE is not installed!"
    fi

    systemctl is-enabled $SERVICE > /dev/null 2>&1
    return $?
}

function isServiceActive ()
{
    declare -r SERVICE=$1

    if ! isServiceEnabled $SERVICE
    then
        errorMessage "$SERVICE is not enabled!"
    fi

    systemctl is-active $SERVICE > /dev/null 2>&1
    return $?
}

function isServiceRunning ()
{
    declare -r SERVICE=$1

    if isServiceActive $SERVICE
    then
        return 0
    fi

    return 1
}

function isStartableService ()
{
    declare -r SERVICE=$1

    if isServiceEnabled SERVICE
    then
        return 0
    fi

    return 1
}

function getServiceState ()
{
    declare -r SERVICE=$1

    if isInstalled $SERVICE
    then
        message "The $SERVICE service is installed."
    else
        message "The $SERVICE service is not installed."
    fi

    if isEnabled $SERVICE
    then
        message "The $SERVICE service is enabled."
    else
        message "The $SERVICE service is disabled."
    fi

    if isActive $SERVICE
    then
        message "The $SERVICE service is running."
    else
        message "The $SERVICE service has stopped."
    fi
}

function enableDaemon ()
{
    declare -r DAEMON=$1
    systemctl enable $DAEMON
}

function disableDaemon ()
{
    declare -r DAEMON=$1
    systemctl disable $DAEMON
}

function startDaemon ()
{
    decalre -r DAEMON=$1
    systemctl start $DAEMON
}

function stopDaemon ()
{
    declare -r DAEMON=$1
    systemctl stop $DAEMON
}

function restartDaemon ()
{
    declare -r DAEMON=$1
    systemctl restart $DAEMON
}

function reloadDaemon ()
{
    declare -r DAEMON=$1
    systemctl reload $DAEMON
}

function getServiceStatus ()
{
    declare -r SERVICE=$1
    systemctl status $SERVICE
}

function getServiceGroupStatus ()
{
    for serviceName in "$@"
    do
        showServiceStatus $serviceName
    done
}

function getNetStatus ()
{
    declare -r DAEMON=$1
    netstat -lpna | grep $DAEMON
}

function getGroupNetStatus ()
{
    for daemon in "$@"
    do
        getNetStatus $daemon
    done
}

function startService ()
{
    declare -r DAEMON=$1

    if [[ ! isServiceActive $DAEMON ]]
    then
        message "Starting $DAEMON ..."
        startDaemon $DAEMON
        return $?
    fi

    message "$DAEMON is already started ..."
    return 2
}

function startServiceGroup ()
{
    for daemon in "$@"
    do
        startService $daemon
    done
}

function stopService ()
{
    declare -r DAEMON=$1

    if isServiceActive $DAEMON
    then
        message "Stopping $DAEMON ..."
        stopDaemon $DAEMON
        return $?
    fi

    message "$DAEMON is already stopped ..."
    return 2
}

function stopServiceGroup ()
{
    for daemon in "$@"
    do
        stopService $daemon
    done
}

function enableService ()
{
    declare -r DAEMON=$1
    
    if [[ ! isServiceEnabled $DAEMON ]]
    then
        message "Enabling $DAEMON ..."
        enableDaemon $DAEMON
        return $?
    fi

    message "$DAEMON is already enabled."
    return 2
}

function enableServiceGroup ()
{
    for daemon in "$@"
    do
        enableService $daemon
    done
}

function disableService ()
{
    declare -r DAEMON=$1
    
    if isServiceEnabled $DAEMON
    then
        message "Disabling $DAEMON ..."
        disableDaemon $DAEMON
        return $?
    fi

    message "$DAEMON is already disabled."
    return 2
}

function disableServiceGroup ()
{
    for daemon in "$@"
    do
        disableService $daemon
    done
}
