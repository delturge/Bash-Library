#!/bin/bash

function getUser ()
{
    declare -r USER=$1
    declare -r PASSWORD_FILE="/etc/passwd"

    getLine $USER $PASSWORD_FILE
}

function isUser ()
{
    declare USER=$1
    getUser $user &> /dev/null
}
