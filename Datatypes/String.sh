#!/bin/bash

# Anthony Rutledge
# aerutledge101@gmail.com
#
# https://www.linkedin.com/in/anthony-rutledge-2988b0125/
# https://stackoverflow.com/users/2495645/anthony-rutledge
#
# A library for dealing with Strings.
# 
# Note: trim() is especially useful.
#######################################
#######################################

function trim ()
{
    tr -d [:space:]
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
    declare -r TARGET=$2

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
    listToString $(cat $INPUT_FILE)
}
