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
    getColumn '.' 1 $(getColumn " " 1 $(systemctl list-unit-files --type service))
    return $?
}

function getServiceName ()
{
    declare -r PATTERN=$1
    serviceName=$(listServices | grep $PATTERN)

    if $?
    then
        trim $serviceName
        return 0
    fi

    return 1
}

function getService ()
{
    declare -r DAEMON=$1
    message $(getServiceName $DAEMON)
}

function getServicePid ()
{
    declare -r DAEMON=$1
    trim $(systemctl status $(getService $DAEMON) | grep "Main PID" | awk {'print $3'})
}

function isInstalled ()
{
    declare DAEMON=$1
    getServiceName $DAEMON > /dev/null
    return $?
}

function isEnabled ()
{
    declare -r DAEMON=$1

    systemctl is-enabled $DAEMON > /dev/null
    return $?
}

function isActive ()
{
    declare -r DAEMON=$1
    systemctl is-active $DAEMON > /dev/null
    return $?
}

function isServiceInstalled ()
{
    declare -r DAEMON=$1

    if isInstalled $DAEMON
    then
        message "The $DAEMON service is already installed!"
        sleep 3
        return 0
    fi

    return 1
}

function isServiceUninstalled ()
{
    declare -r DAEMON=$1

    if isInstalled $DAEMON
    then
        return 1
    fi

    message "The $DAEMON service is already uninstalled!"
    sleep 3
    return 0
}

function isServiceEnabled ()
{
    declare -r DAEMON=$1

    if isEnabled $deamon
    then
        message "The $DAEMON service is already enabled!"
        sleep 3
        return 0
    fi

    return 1
}

function isServiceDisabled ()
{
    declare -r DAEMON=$1

    if isEnabled $DAEMON
    then
        return 1
    fi

    message "The $DAEMON service is already disabled!"
    sleep 3
    return 0
}

function isServiceRunning ()
{
    declare -r DAEMON=$1

    if isActive $DAEMON
    then
        message "The $DAEMON service is already running!"
        sleep
        return 0
    fi

    return 1
}

function isServiceStopped ()
{
    declare -r DAEMON=$1

    if isActive $DAEMON
    then
        return 1
    fi

    message "The $DAEMON service is already stopped!"
    sleep 3
    return 0
}

function isStartableService ()
{
    if isServiceInstalled && isServiceEnabled
    then
        return 0
    fi

    return 1
}

function getServiceState ()
{
    declare -r DAEMON=$1

    if isInstalled $DAEMON
    then
        message "The $DAEMON service is installed."
    else
        message "The $DAEMON service is not installed."
    fi

    if isEnabled $DAEMON
    then
        message "The $DAEMON service is enabled."
    else
        message "The $DAEMON service is disabled."
    fi

    if isActive $DAEMON
    then
        message "The $DAEMON service is running."
    else
        message "The $DAEMON service has stopped."
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

function getServiceStatus ()
{
    declare -r DAEMON=$1
    systemctl status $DAEMON
}

function getServiceGroupStatus ()
{
    for DAEMON in "$@"
    do
        showServiceStatus $DAEMON
    done
}

function getNetStatus ()
{
    declare -r DAEMON=$1
    netstat -lpna | grep $DAEMON
}

function getGroupNetStatus ()
{
    for DAEMON in "$@"
    do
        getNetStatus $DAEMON
    done
}

function startService ()
{
    declare -r DAEMON=$1

    if [[ ! isStartableService $DAEMON ]]
    then
        return 1
    fi


    if isServiceStarted $DAEMON
    then
        return 1
    fi

    message "Starting $DAEMON ..."
    startDaemon $DAEMON
    return $?
}

function startServiceGroup ()
{
    for DAEMON in "$@"
    do
        startService $DAEMON
    done
}

function stopService ()
{
    declare -r DAEMON=$1

    if [[ ! isStartableService $DAEMON ]]
    then
        return 1
    fi

    if isServiceStopped $DAEMON
    then
        return 1
    fi

    message "Stopping $DAEMON ..."
    stopDaemon $DAEMON
    return $?
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
    isServiceEnabled $DAEMON

    if $?
    then
        return
    fi

    message "Enabling $DAEMON ..."
    enableDaemon $DAEMON
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
    isServiceDisabled

    if [[ $? ]]
    then
        return
    fi

    stopService $DAEMON
    message "Disabling $DAEMON ..."
    disableDaemon $DAEMON
}

function disableServiceGroup ()
{
    for daemon in "$@"
    do
        disableService $daemon
    done
}
