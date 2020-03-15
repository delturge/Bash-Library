# Anthony Rutledge
# aerutledge101@gmail.com
#
# https://www.linkedin.com/in/anthony-rutledge-2988b0125/
# https://stackoverflow.com/users/2495645/anthony-rutledge
#
# A Linux process library.
#
# 1) Makes dealing with process lifecycle easier
# 
# ##########################################################
############################################################

function getProcesses ()
{
    ps -e -o comm,pid,ppid,pgid,user,ruid,euid,group,rgid,egid,etime,etimes,stat --no-headers
}

function getProcess ()
{
   declare -r PID=$1
   ps -p $PID -o comm,pid,ppid,pgid,user,ruid,euid,group,rgid,egid,etime,etimes,stat --no-headers
}

function getProcessReport ()
{
   declare -r PID=$1
   ps -p $PID -o comm,pid,ppid,pgid,user,ruid,euid,group,rgid,egid,etime,etimes,stat
}

function isProcess ()
{
    kill -s EXIT $1 > /dev/null 2>&1
    return $?
}

function getProcessSeconds ()
{
    declare -r PID=$1
    getProcess $PID | awk '{print $12}' | trim
}

function getProcessStatus ()
{
    declare -r PID=$1
    getProcess $PID | awk '{print $13}' | trim
}

function getPgid ()
{
    declare -r PID=$1
    getProcess $PID | awk '{print $3}' | trim
}

function isZombie ()
{
    declare -r PID=$1
    declare processStatus

    processStatus=$(getProcessStatus $PID)
    
    [[ "$processStatus" == "Z" ]]
    return $?
}

function hasChildPids ()
{
    declare -r PPID=$1
    echo $(getProcesses) | awk '{print $3}' | sort -n | uniq | grep "^${PPID}$"
    return $?
}

function getChildPids ()
{
    declare -r PPID=$1
    echo $(getProcesses) | awk '{print $2, $3}' | sort -k 2 | awk "\$2 == $PPID {print \$1}" | sort -n
}

function getParentPid ()
{
    declare -r PID=$1
    getProcess $PID | awk '{print $3}') | trim
}

function killProcess ()
{
    declare -r PID=$1

    if [[ ! isProcess $PID ]]
    then
        errorMessage "Process $PID cannot be terminated because it does not exist!"
        return 0
    elif [[ kill -s TERM $PID ]] && [[ ! isProcess $PID ]]
    then
        errorMessage "Process $PID was terminated.\n"
        return 0
    elif kill -s KILL $PID
        errorMessage "Process $PID killed with SIGKILL (9) signal."
        return 0
    elif isZombie $PID
    then
        errorMessage "Process $PID in the defunct / ZOMBIE status!"
        return 1
    else
        errorMessage "Process $PID is alive! SIGTERM and SIGKILL had no effect. It is not a zombie."
    fi

    return 2
}

function attemptToKillPid ()
{
    declare -r PID=$1

    if killProcess $PID
    then 
        return 0
    fi

    declare ppid=$(getParentPid $pid)
    errorMessage "Process id $pid of parent process $ppid was not able to be killed."
    return 1
}

function killPidFamily ()
{
    declare -r PROCESSES="$@"
    declare -ir NUM_PROCESSES_TO_KILL=$#
    declare -i numKilledProcesses=0
    declare ppid

    for pid in $PROCESSES
    do
        pid=$(echo $pid | trim)

        if ! hasChildPids $pid
        then
            attemptToKillPid $pid && (( numKilledProcesses++ ))
        else
            killPidFamily $(getChildPids $pid) && attemptToKillPid $pid && (( numKilledProcesses++ ))
        fi
    done

    (( numKilledProcesses == NUM_PROCESSES_TO_KILL ))
    return $?
}

function getRuntimeSeconds ()
{
    declare -r PID=$1
    declare -r DEAD_PROCESS=86400
    declare runtimeSeconds

    if [[ ! isProcess $PID ]]
    then
        echo -n $DEAD_PROCESS
        return 1
    fi

    runtimeSeconds=$(getProcessSeconds $PID)

    # Check to see if nothing was returned.
    if [[ -z $runtimeSeconds ]]
    then
        runtimeSeconds=$DEAD_PROCESS
    fi

    echo -n $runtimeSeconds
    return 0
}

function limitProcessRuntime ()
{
    declare -ir PID=$1
    declare -ir MAX_RUNTIME_SECONDS=$2
    declare -ir MAX_STRIKES=$3
    declare -ir DELAY_SECONDS=$4
    declare -ir CURRENT_TIME_IN_SECONDS=$SECONDS # Where $SECONDS is a built-in, global variable.
    declare -ir TIMEOUT=$(( MAX_RUNTIME_SECONDS + CURRENT_TIME_IN_SECONDS ))

    declare -i strikes=0
    declare -i runtimeSeconds

    runtimeSeconds=$(getRuntimeSeconds $PID)

    while (( runtimeSeconds < TIMEOUT )) && (( strikes < MAX_STRIKES ))
    do
        (( strikes++ ))
        sleep $DELAY_SECONDS
        runtimeSeconds=$(getRuntimeSeconds $PID)
    done

    if ! isProcess $PID
    then
        # The process is dead. All is well.
        return 0
    fi

    # The process is still running and needs to be killed by higher client code.
    return 1
}
