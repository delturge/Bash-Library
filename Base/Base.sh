#!/bin/bash

# Anthony Rutledge
# aerutledge101@gmail.com
#
# https://www.linkedin.com/in/anthony-rutledge-2988b0125/
# https://stackoverflow.com/users/2495645/anthony-rutledge
#
# The base library of the bash library.
#
# 1) Loads the extended datatypes
# 2) Loads the Linux entities.
# ##########################################################
############################################################

function returnValue ()
{
    echo $1
}

function newline ()
{
    echo -e "\n\n"
}

function message ()
{
    newline
    echo -e "$1"
    newline
}

function errorMessage ()
{
    newline
    echo -e "$1" 1>&2
    newline
}

function showPwd ()
{
    message "Current Directory: $(pwd)"
}

function pause ()
{
    text="$1"
    read -p "$text: "
}

# Load datatype libaries.
. ../Datatypes/Datatype.sh

# Load entities.
. ../Entities/Entity.sh
