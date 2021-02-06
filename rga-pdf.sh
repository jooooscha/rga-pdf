#!/usr/bin/sh

o_flag=false
input=""
persistent=false
addfilename=false

# get opts ------------------------------------------------------------
while getopts "os:pf" arg
do
    case "${arg}" in
        o) o_flag=true ;;
        s) input="${OPTARG}" ;;
        p) persistent=true ;;
        f) addfilename=true
    esac
done

# ---------------------------------------------------------------------

searchterm=$input
input=${input// /_} # replace space with underline

if [ "$input" == "" ] # check if no input was given
then
    echo "invalid input"
    exit
fi

name="results_of_$input.pdf"

# ---------------------------------------------------------------------

# main command
rga "$searchterm" | sort | sed 's/: .*//' | sed 's/:Page//' | sort | python ~/.local/bin/makePdf.py "$addfilename" "$name" || echo "Something went wront; most likely with python"

# ---------------------------------------------------------------------

echo "searching for $input"

if [ "$persistent" = true ] && [ -f "/tmp/$name" ] # persistent
then
    mv "/tmp/$name" "$name"
    if [ "$o_flag" = true ] && [ -f "$name" ] # persistent and open
    then
        xdg-open "/tmp/$name" 2> /dev/null
    fi
elif [ "$o_flag" = true ] && [ -f "/tmp/$name" ] # non persistant but open
then
    xdg-open "/tmp/$name" 2> /dev/null
fi

