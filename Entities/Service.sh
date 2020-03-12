# Anthony Rutledge
# aerutledge101@gmail.com
#
# https://www.linkedin.com/in/anthony-rutledge-2988b0125/
# https://stackoverflow.com/users/2495645/anthony-rutledge
#
# A Linux systemd library.
#
# 1) Makes managing services easier.
# 2) systemd edition :-)
# 3) Take advantage of getServiceName in your client code.
#    This way you will get the name of the service as registered
#    with systemd, before sending the service name to various
#    untility functions found in this library. :-)

# 4) Depends on the Base libary (message()) in ../Base/
# 5) Depends on the String library (trim()) in ../Datatypes/ 
# ##########################################################
############################################################

function listServices ()
{
    systemctl list-units --type=service | sed =n '2,/^$/' | grep -v "$^" | awk '{print $1}' | awk -F. '{print $1}'
}

function getServiceName ()
{
    declare -r SERVICE=$1
    listServices | grep -E "^${SERVICE}" | trim
}

function isService ()
{
    declare -r SERVICE=$1
    declare -r SERVICE_NAME=$(getSericeName $SERVICE)

    [[ ! -z $SERVICE_NAME ]]
    return $?
}

function getServicePid ()
{
    declare -r SERVICE=$1
    systemctl status $(getServiceName $SERVICE) | grep "Main PID" | awk '{print $3}' | trim
}

function isServiceConfLoaded ()
{
    declare -r SERVICE=$1

    [[ systemctl list-units --type=service --state=loaded "${SERVICE}.service" > /dev/null 2>&1 ]]
    return $?
}

function isServiceEnabled ()
{
    declare -r SERVICE=$1

    [[ systemctl is-enabled $SERVICE > /dev/null 2>&1 ]]
    return $?
}

function isServiceActive ()
{
    declare -r SERVICE=$1

    [[ systemctl list-units --type=service --state=active "${SERVICE}.service" > /dev/null 2>&1 ]]
    return $?
}

function isServiceRunning ()
{
    declare -r SERVICE=$1

    [[ systemctl list-units --type=service --state=running "${SERVICE}.service" > /dev/null 2>&1 ]]
    return $?
}

function isStartableService ()
{
    declare -r SERVICE=$1

    if [[ ! isService $SERVICE ]]
    then
        return 2
    fi

    declare -r SERVICE_NAME=$(getServiceName $SERVICE)

    [[ isServiceConfLoaded $SERVICE_NAME && isServiceEnabled $SERVICE_NAME ]] && [[ ! isServiceRunning $SERVICE_NAME ]]
    return $?
}

function getServiceState ()
{
    declare -r SERVICE=$1

    if isServiceConfLoaded $SERVICE
    then
        message "The $SERVICE configuration is loaded."
    else
        message "The $SERVICE configuration is not loaded!"
    fi

    if isServiceEnabled $SERVICE
    then
        message "The $SERVICE service is enabled."
    else
        message "The $SERVICE service is disabled!"
    fi

    if isServiceActive $SERVICE
    then
        message "The $SERVICE service is started successfully."
    else
        message "The $SERVICE service did not start successfully!"
    fi

    if isServiceRunnting $SERVICE
    then
        message "The $SERVICE service is running."
    else
        message "The $SERVICE service is not running."
    fi
}

function maskService ()
{
    declare -r SERVICE=$1
    systemctl mask $SERVICE
}

function unmaskService ()
{
    declare -r SERVICE=$1
    systemctl unmask $SERVICE
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

function getGroupNetStatus ()
{
    for daemon in "$@"
    do
        getNetStatus $daemon
    done
}

function startService ()
{
    declare -r SERVICE=$1

    if [[ isServiceStartable $SERVICE ]]
    then
        message "Starting $SERVICE ..."
        startDaemon $SERVICE
        return $?
    fi

    message "$SERVICE cannot start. Check the load configration, enable, and stop it first."
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
    declare -r SERVICE=$1

    if isServiceRunning $SERVICE
    then
        message "Stopping $SERVICE ..."
        stopDaemon $SERVICE
        return $?
    fi

    message "$SERVICE is already stopped ..."
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
    declare -r SERVICE=$1
    
    if [[ ! isServiceEnabled $SERVICE ]]
    then
        message "Enabling $SERVICE ..."
        enableDaemon $SERVICE
        return $?
    fi

    message "$SERVICE is already enabled."
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
    declare -r SERVICE=$1
    
    if isServiceEnabled $SERVICE
    then
        message "Disabling $SERVICE ..."
        disableDaemon $SERVICE
        return $?
    fi

    message "$SERVICE is already disabled."
    return 2
}

function disableServiceGroup ()
{
    for daemon in "$@"
    do
        disableService $daemon
    done
}
