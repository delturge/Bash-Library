#!/bin/bash

function trim ()
{
    echo -n "$1" | tr -d [:space:]
}

function concat ()
{
    declare -r PREFIX=$1
    declare -r SUFFIX=$2

    returnValue "${PREFIX}${SUFFIX}"
}

function strhas()
{
    declare -r PATTERN=$1
    declare -r TARGET=$2

    echo $TARGET | grep -q $PATTERN 1>&2 /dev/null
    return $?
}

function strCount()
{
    declare -r PATTERN=$1
    declare -r target=$2

    echo $TARGET | grep -c $PATTERN
    return $?
}

function isMatch ()
{
    declare -r PATTERN=$1
    declare -r TARGET=$2

    [[ "$TARGET" =~ $PATTERN ]]
    return $?
}

function strEqual ()
{
    [[ "$1" == "$2" ]]
    return $?
}

function makeNumberPattern ()
{
    declare -ir END_VALUE=$1

    declare pattern=""
    declare -i counter=1

    while (( counter <= END_VALUE ))
    do
        pattern=$(concat $pattern $counter)
        (( counter++ ))
    done

    returnValue "[$pattern]"
}

function fileToString ()
{
    declare -r INPUT_FILE=$1
    listToString $(cat $INPUT_FILE))
}
