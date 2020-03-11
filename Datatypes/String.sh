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
    typeset -r PREFIX=$1
    typeset -r SUFFIX=$2

    returnValue "${PREFIX}${SUFFIX}"
}

function strhas()
{
    typeset -r PATTERN=$1
    typeset -r TARGET=$2

    echo $TARGET | grep -q $PATTERN 1>&2 /dev/null
    return $?
}

function strCount()
{
    typeset -r PATTERN=$1
    typeset -r TARGET=$2

    echo $TARGET | grep -c $PATTERN
    return $?
}

function isMatch ()
{
    typeset -r PATTERN=$1
    typeset -r TARGET=$2

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
    typeset -ir END_VALUE=$1

    typeset pattern=""
    typeset -i counter=1

    while (( counter <= END_VALUE ))
    do
        pattern=$(concat $pattern $counter)
        (( counter++ ))
    done

    returnValue "[$pattern]"
}

function fileToString ()
{
    typeset -r INPUT_FILE=$1
    listToString $(cat $INPUT_FILE))
