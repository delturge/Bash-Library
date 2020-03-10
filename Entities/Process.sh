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
# Todo: Process group functions: (PGID).
# 
# ##########################################################
############################################################

function getProcesses ()
{
    ps -e -o pid,ppid,pgid,user,ruid,euid,group,rgid,egid,etime,etimes,stat --no-headers
}

function getProcess ()
{
   declare -r PID=$1
   ps -p $PID -o comm,pid,ppid,pgid,user,ruid,euid,group,rgid,egid,etime,etimes,stat --no-headers
}

function isProcess ()
{
    kill -s EXIT $1 2> /dev/null
    return $?
}

function getProcessStatus ()
{
    declare -r PID=$1
    trim $(ps -p $PID -o stat --no-headers)
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
    trim $(echo $(getProcess $PID) | awk '{print $3}')
}

function killProcess ()
{
    declare -r PID=$1

    if [[ ! isProcess $PID ]]
    then
        errorMessage "Process $PID cannot be terminated because it does not exist!"
        return 1
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
        return 2
    else
        errorMessage "Process $PID is alive! SIGTERM and SIGKILL had no effect. It is not a zombie."
    fi

    return 3
}

function attemptToKillPid ()
{
    declare -r PID=$1

    if killProcess $PID
    then 
        return 0
    fi

    ppid=$(getParentPid $pid)
    errorMessage "Process $pid of parent $ppid was not able to be killed.\n" 1>&2
    return 1
}

function killPidFamily ()
{
    declare -r PROCESSES=$*
    declare -ir NUM_PROCESSES_TO_KILL=$(countLines $PROCESSES)
    declare -i numKilledProcesses=0
    declare ppid

    for pid in $PROCESSES
    do
        pid=$(trim $pid)

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
    declare -r DEAD_PROCESS=-1

    declare runtimeSeconds=$(trim $(ps -p $PID -o etimes --no-headers 2> /dev/null) 2> /dev/null)

    if [[ -z $runtimeSeconds ]]
    then
        runtimeSeconds=$DEAD_PROCESS
    fi

    echo -n $runtimeSeconds
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

    if [[ ! isProcess $PID ]]
    then
        return 0
    fi

    runtimeSeconds=$(getRuntimeSeconds $PID)

    while (( runtimeSeconds < TIMEOUT )) && (( strikes < MAX_STRIKES ))
    do
        (( strikes++ ))
        sleep $DELAY_SECONDS

        if ! isProcess $PID
        then
            return 0
        fi

        runtimeSeconds=$(getRuntimeSeconds $PID)
    done

    return 1
}
