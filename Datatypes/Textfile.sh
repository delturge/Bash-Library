#!/bin/bash

# Anthony Rutledge
# aerutledge101@gmail.com
#
# https://www.linkedin.com/in/anthony-rutledge-2988b0125/
# https://stackoverflow.com/users/2495645/anthony-rutledge
#
# A generic library that provides for easy file maniupluation using cut, sed, grep, and awk.
#
# Note: This library depends on a another libary (String), as there is no trim() command in the GNU command set.

#########################################################
#              Line Matching Operations (boolean)       #
#########################################################

##
# Determine if a file has a string pattern in a Boolean way.
###
function fileHas ()
{
    declare -r PATTERN="$1"
    declare -r FILENAME="$2"

    grep $PATTERN $FILENAME > /dev/null 2>&1
    return $?
}

#########################################################
#          Basic Line Selection Operations              #
#########################################################

##
# Print all lines that match a pattern.
###
function getLines ()
{
    declare PATTERN=$1
    declare INPUT_FILE=$2

    grep -E $PATTERN $INPUT_FILE
}

##
# Get one specific line from a file.
###
function getLine ()
{
    declare -r PATTERN="$1"
    declare -r FILENAME="$2"

    grep -E -m 1 $PATTERN $FILENAME
}

#########################################################
#               Line Counting Operations                #
#########################################################

##
# Count the total number of lines in a file.
# 
# Note: This function requires access to the String library.
###
function getLineCount ()
{
    declare -r FILENAME="$1"
    wc -l $FILENAME | awk '{print $1}' | trim
}

##
# Count the number of lines that match a pattern.
###
function lineMatchCount ()
{
    declare -r PATTERN="$1"
    declare -r FILENAME="$2"

    grep -E -c $PATTERN $FILENAME
}

#########################################################
#                 Line Number Operations                #
#########################################################

##
# Get matching lines with their row number prepended: n:line
###
function getNumberedLines ()
{
    pattern=$1
    inputFile=$2

    grep -E -n $pattern $inputFile
}

##
# Get the line numbers of all matching lines.
###
function getLineNumbers ()
{
    pattern=$1
    inputFile=$2

    getNumberedLines $pattern $inputFile | awk -F: '{print $1}'
}

##
# Get one line with its row number prepended. n:line
###
function getNumberedLine ()
{
    declare -r PATTERN="$1"
    declare -r FILENAME="$2"

    grep -E -n -m 1 $PATTERN $FILENAME
}

##
# Get the line number of one line / record.
###
function getLineNumber ()
{
    declare -r PATTERN="$1"
    declare -r FILENAME="$2"

    getNumberedLine $PATTERN $FILENAME | awk -F : '{print $1}' | trim
}

#########################################################
#          sed Based Line Selection Operations          #
#########################################################

##
# Get an inclusive range of lines by start and end line numbers.
###
function selectLinesByNumRange ()
{
    declare -r STARTING_LINE_NUMBER=$1
    declare -r ENDING_LINE_NUMBER=$2
    declare -r FILENAME="$3"

    sed -n "${STARTING_LINE_NUMBER},${ENDING_LINE_NUMBER} p" "$FILENAME"
}

##
# Get an inclusive range of lines from start number to a string pattern.
###
function selectLinesNumToRegex ()
{
    declare -r STARTING_LINE_NUMBER=$1
    declare -r ENDING_LINE_REGEXP="$2"
    declare -r FILENAME="$3"

    sed -n "${STARTING_LINE_NUMBER},/${ENDING_LINE_REGEXP}/ p" "$FILENAME"
}

##
# Get an inclusive range of lines from start number to a string pattern.
###
function selectLinesPatternToNum ()
{
    declare -r STARTING_LINE_REGEXP="$1"
    declare -r ENDING_LINE_NUMBER=$2
    declare -r FILENAME="$3"

    sed -n "/${STARTING_LINE_REGEXP}/,${ENDING_LINE_NUMBER} p" "$FILENAME"
}

##
# Get an inclusive range of lines from start pattern to a end pattern.
###
function selectLinesPatternToPattern ()
{
    declare -r STARTING_LINE_REGEXP="$1"
    declare -r ENDING_LINE_REGEXP="$2"
    declare -r FILENAME="$3"

    sed -n "/${STARTING_LINE_REGEXP}/,/${ENDING_LINE_REGEXP}/ p" "$FILENAME"
}

#########################################################
#          Column / Field Selection Operations          #
#########################################################

##
# Get an entire column / field of values for the entire file.
###
function getColumn ()
{
    declare -r DELIMITER="$1"
    declare -r COLUMN="$2"
    declare -r FILENAME="$3"

    cut -d $DELIMITER -f $COLUMN "$FILENAME" 
#   awk -F"${DELMITER}" "{print \$${COLUMN}}" "$FILENAME" # The same action in awk
}

#########################################################
#             Content Mutation Functions                #
#########################################################

##############################################################
#                Output Generating Functions                 #
#                                                            #
#  Warning: "With great power comes great responsibility."   #
#                                                            #
#  Tip:  Multiple, consecutive sed commands on one file      #
#        should be done transactionally.                     #
#                                                            #
#  Tip:  Use one function to control calling all instances   #
#        of sed, or each function designed to call sed.      #
#                                                            #
#  Tip:  Use trap to handle signals: HUP, INT, QUIT, TERM    #
#                                                            #
#                                                            #
#        trap '' HUP INT QUIT TERM  # at least ignore these  #
#                                                            #
#                                                            #
#        ##### Encapsulate below with a function.  #####     #
#                                                            #
#        if sed '<commands>' "$filename" > $outputFile       #
#        then                                                #
#            # sed executed without error.                   #
#            return 0                                        #
#        else                                                #
#            # sed executed with an error.                   #
#            return 1                                        #
#        fi                                                  #
#                                                            #
#        ##### Encapsulate above with a function.  #####     #
#                                                            #
#                                                            #
#        trap - HUP INT QUIT TERM     # restore these        #
#                                                            #
##############################################################

##
# Insert text above a target line number.
###
function insertAboveOg ()
{
    declare -r TARGET_LINE_NUMBER=$1
    declare -r NEW_LINE="$2"
    declare -r SOURCE_FILE="$3"

    sed -n -r "${TARGET_LINE_NUMBER}i${NEW_LINE}" "$SOURCE_FILE"
}

##
# Insert text below a target line number.
###
function insertBelowOg ()
{
    declare -r TARGET_LINE_NUMBER=$1
    declare -r NEW_LINE="$2"
    declare -r SOURCE_FILE="$3"

    sed -n -r "${TARGET_LINE_NUMBER}a${NEW_LINE}" "$SOURCE_FILE"
}

##
# Update / patch a specific portion of a line. Does not overwrite entire line.
###
function updateRecordOg  ()
{
    declare -r TARGET_LINE_NUMBER=$1
    declare -r SEARCH_STRING="$2"
    declare -r SUBSTITUTION="$3"
    declare -r SOURCE_FILE="$4"

    sed -n -r "${TARGET_LINE_NUMBER}s/${SEARCH_STRING}/${SUBSTITUTION}/" "$SOURCE_FILE"
}

##
# Erase a line and then replace it with new text.
###
function overwriteOg ()
{
    declare -r TARGET_LINE_NUMBER=$1
    declare -r REPLACEMENT_LINE="$2"
    declare -r SOURCE_FILE="$3"

    sed -n -r "${TARGET_LINE_NUMBER}c${REPLACEMENT_LINE}" "$SOURCE_FILE"
}

##
# Remove an entire line from a file.
###
function deleteRecordOg ()
{
    declare -r TARGET_LINE_NUMBER=$1
    declare -r SOURCE_FILE="$2"

    sed -n -r "${TARGET_LINE_NUMBER}d" "$SOURCE_FILE"
}

#################################################################
#        Original File, Inline, Content Mutating Operations     #
#################################################################

##############################################################
#       Output Generating, Content Mutation Operations       #
#                                                            #
#  Warning: "With great power comes great responsibility."   #
#                                                            #
#  Tip:  Multiple, consecutive sed commands on one file      #
#        should be done transactionally.                     #
#                                                            #
#  Tip:  Use one function to control calling all instances   #
#        of sed, or each function designed to call sed.      #
#                                                            #
#  Tip:  Use trap to handle signals: HUP, INT, QUIT, TERM    #
#                                                            #
#                                                            #
#        trap '' HUP INT QUIT TERM  # at least ignore these  #
#                                                            #
#                                                            #
#        ##### Encapsulate below with a function.  #####     #
#                                                            #
#        if sed '<commands>' "$filename"                     #
#        then                                                #
#            # sed executed without error.                   #
#            return 0                                        #
#        else                                                #
#            # sed executed with an error.                   #
#            return 1                                        #
#        fi                                                  #
#                                                            #
#        ##### Encapsulate above with a function.  #####     #
#                                                            #
#                                                            #
#        trap - HUP INT QUIT TERM     # restore these        #
#                                                            #
##############################################################

##
# Insert text above a target line number.
###
function insertAbove ()
{
    declare -r TARGET_LINE_NUMBER=$1
    declare -r NEW_LINE="$2"
    declare -r FILENAME="$3"

    sed -i -n -r "${TARGET_LINE_NUMBER}i${NEW_LINE}" "$FILENAME"
}

##
# Insert text below a target line number.
###
function insertBelow ()
{
    declare -r TARGET_LINE_NUMBER=$1
    declare -r NEW_LINE="$2"
    declare -r FILENAME="$3"

    sed -i -n -r "${TARGET_LINE_NUMBER}a${NEW_LINE}" "$FILENAME"
}

##
# Update / patch a specific portion of a line. Does not overwrite entire line.
###
function updateRecord ()
{
    declare -r TARGET_LINE_NUMBER=$1
    declare -r SEARCH_STRING="$2"
    declare -r SUBSTITUTION="$3"
    declare -r FILENAME="$4"

    sed -i -n -r "${TARGET_LINE_NUMBER}s/${SEARCH_STRING}/${SUBSTITUTION}/" "$FILENAME"
}

##
# Erase a line and then replace it with new text.
###
function overwrite ()
{
    declare -r TARGET_LINE_NUMBER=$1
    declare -r REPLACEMENT_LINE="$2"
    declare -r FILENAME="$3"

    sed -i -n -r "${TARGET_LINE_NUMBER}c${REPLACEMENT_LINE}" "$FILENAME"
}

##
# Remove an entire line from a file.
###
function deleteRecord ()
{
    declare -r TARGET_LINE_NUMBER=$1
    declare -r FILENAME="$2"

    sed -i -n -r "${TARGET_LINE_NUMBER}d" "$FILENAME"
}

#########################################################
#             File Mutating Operations                  #
#########################################################

##
# Join two files together.
###
function appendFile ()
{
    declare -r MAIN_FILE="$1"
    declare -r FILE_TO_ADD_ON="$2"

    if cat "$FILE_TO_ADD_ON" >> "$MAIN_FILE"
    then
        return 0
    fi

    return 1
}
