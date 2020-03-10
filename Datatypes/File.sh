function isFile ()
{
    declare -r FILENAME=$1

    [[ -e $FILENAME ]]
    return $?
}

function isRegFile ()
{
    declare -r FILENAME=$1

    [[ -f $FILENAME ]]
    return $?
}

function isDirectory ()
{
    declare -r FILENAME=$1

    [[ -d $FILENAME ]]
    return $?
}

function isReadable ()
{
    declare -r FILENAME=$1

    [[ -r $FILENAME ]]
    return $?
}

function isWritable ()
{
    declare -r FILENAME=$1

    [[ -w $FILENAME ]]
    return $?
}

function isExecutable ()
{
    declare -r FILENAME=$1

    [[ -x $FILENAME ]]
    return $?
}

function isConfigurable ()
{
    declare -r FILENAME=$1

    [[ isRegFile $FILENAME && isReadable $FILENAME && isWritable $FILENAME ]]
    return $?
}

function fileToList ()
{
    declare -r FILENAME=$1
    cat $FILENAME
}

function getFileType ()
{
    FILENAME=$1
    file -b $FILENAME
}

function makeFile ()
{
    declare -r FILENAME=$1
    decalre ERROR_MESSAGE_PREFIX="$FILENAME already exists."

    if ! isFile $FILENAME
    then
        touch $FILENAME
        return 0
    fi

    errorMessage "$ERROR_MESSAGE_PREFIX: $(getFileType))"
    return 1
}

function makeManyFiles ()
{
    for filename in "$@"
    do
        makeFile $filename
    done
}
