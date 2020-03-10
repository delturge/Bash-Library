#!/bin/bash

# Anthony Rutledge
# aerutledge101@gmail.com
#
# https://www.linkedin.com/in/anthony-rutledge-2988b0125/
# https://stackoverflow.com/users/2495645/anthony-rutledge
#
# A Linux service library.
#
# 1) Makes managing users easier.
# 
# Todo: Make variables local in scope with "declare"
# ##########################################################
############################################################

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
function setPasswordDefaults ()
{
    grep 'PASS_' login.defs
    message "Setting PASS_MAX_DAYS to 90."
    sed -i "s/^PASS_MAX_DAYS\t99999/PASS_MAX_DAYS\t90/" login.defs
    message "Setting PASS_WARN_AGE to 10."
    sed -i "s/^PASS_WARN_AGE\t7/PASS_MAX_DAYS\t10/" login.defs
    grep 'PASS_' login.defs
    newline
    sleep 5
}

function showChangePasswordReport ()
{
    if [[ $1 == 0 ]]
    then 
        message "Password changed successfully!"
    else
        message "Failed to change password!"
        exit
    fi
}

function setPassword ()
{
    passwd -S $1
    sleep 2

    message "Setting password for $1 ..."

    passwd $1
    showChangePasswordReport $?

    passwd -S $1
    sleep 2

}

function setManyPasswords ()
{
    message "Setting passwords for $*"

    for user in "$@"
    do
        setPassword $user
        newline
    done
}

function configureHomeDir()
{
    chown $1:$1 /home/${1}
    chmod 700 /home/${1}
}

function secureHomeDirs ()
{
    message "Securing home directories for $*"

    for user in "$@"
    do
        configureHomeDir $user
        newline
    done
}

function secureHomeDirsFromFile ()
{
    message "Securing home directories from this file: ${1}"

    usersString=$(fileToString $1)
    read -a users <<< $usersString
    secureHomeDirs "${users[@]}"
}

function showUseraddReport ()
{
    if [[ $1 == 0 ]] then 
        message "User added successfully."
    else
        message "Error: Failed to create the user and group!"
        exit
    fi
}

function addRegularUser ()
{
    if [[ ! `grep "^${1}:x:" /etc/passwd` ]] then
        message "Adding $1 to /etc/passwd"
        useradd -d /home/$1 -e 2020-01-01 -c "Normal user." -s /bin/sh -U $1
        showUseraddReport $?
        showUser $1
        sleep 2
        return 0
    fi

    message "The $1 user already exist! No user added."
}

function addAccounts ()
{
    message "Adding users: ${*}"

    for user in "$@"
    do
        addRegularUser `echo $user | tr -d [:space:]`
    done
}

function addAccountsFromFile ()
{
    message "Adding users from this file: ${1}"

    usersString=$(fileToString $1)
    read -a users <<< $usersString
    addAccounts "${users[@]}"
}

function addGroup ()
{
    groupadd -g $2 $1
}

function addToGroup ()
{
    group=$1
    shift

    for $user in "$@"
    do
        usermod -G $group $user
    done
}
function setPasswordDefaults ()
{
    grep 'PASS_' login.defs
    message "Setting PASS_MAX_DAYS to 90."
    sed -i "s/^PASS_MAX_DAYS\t99999/PASS_MAX_DAYS\t90/" login.defs
    message "Setting PASS_WARN_AGE to 10."
    sed -i "s/^PASS_WARN_AGE\t7/PASS_MAX_DAYS\t10/" login.defs
    grep 'PASS_' login.defs
    newline
    sleep 5
}

function showChangePasswordReport ()
{
    if [[ $1 == 0 ]]
    then 
        message "Password changed successfully!"
    else
        message "Failed to change password!"
        exit
    fi
}

function setPassword ()
{
    passwd -S $1
    sleep 2

    message "Setting password for $1 ..."

    passwd $1
    showChangePasswordReport $?

    passwd -S $1
    sleep 2

}

function setManyPasswords ()
{
    message "Setting passwords for $*"

    for user in "$@"
    do
        setPassword $user
        newline
    done
}

function configureHomeDir()
{
    chown $1:$1 /home/${1}
    chmod 700 /home/${1}
}

function secureHomeDirs ()
{
    message "Securing home directories for $*"

    for user in "$@"
    do
        configureHomeDir $user
        newline
    done
}

function secureHomeDirsFromFile ()
{
    message "Securing home directories from this file: ${1}"

    usersString=$(fileToString $1)
    read -a users <<< $usersString
    secureHomeDirs "${users[@]}"
}

function showUseraddReport ()
{
    if [[ $1 == 0 ]] then 
        message "User added successfully."
    else
        message "Error: Failed to create the user and group!"
        exit
    fi
}

function addRegularUser ()
{
    if [[ ! `grep "^${1}:x:" /etc/passwd` ]] then
        message "Adding $1 to /etc/passwd"
        useradd -d /home/$1 -e 2020-01-01 -c "Normal user." -s /bin/sh -U $1
        showUseraddReport $?
        showUser $1
        sleep 2
        return 0
    fi

    message "The $1 user already exist! No user added."
}

function addAccounts ()
{
    message "Adding users: ${*}"

    for user in "$@"
    do
        addRegularUser `echo $user | tr -d [:space:]`
    done
}

function addAccountsFromFile ()
{
    message "Adding users from this file: ${1}"

    usersString=$(fileToString $1)
    read -a users <<< $usersString
    addAccounts "${users[@]}"
}

function addGroup ()
{
    groupadd -g $2 $1
}

function addToGroup ()
{
    group=$1
    shift

    for $user in "$@"
    do
        usermod -G $group $user
    done
}
