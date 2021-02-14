#!/usr/bin/sh

o_flag=false
input=""
persistent=false
addfilename=false
excludeprevoutput=true

# get opts ------------------------------------------------------------
while getopts "os:pfi" arg
do
    case "${arg}" in
        o) o_flag=true ;;
        s) input="${OPTARG}" ;;
        p) persistent=true ;; # p - move file to persistent storage (current dir)
        f) addfilename=true ;; # f - add Filename to bottom of page
        i) excludeprevoutput=false ;; # i - Include prev outptu
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

name="pages_with_$input.pdf"

echo "searching for '$searchterm'"

# ---------------------------------------------------------------------

# main command
rga "($searchterm)" | sort | sed 's/: .*//' | sed 's/:Page//' | sort | python ~/.local/bin/makePdf.py "$addfilename" "$name" "$(pwd)" "$excludeprevoutput" || echo "Something went wrong; most likely with python"

# ---------------------------------------------------------------------

if [ "$persistent" = true ] && [ -f "/tmp/$name" ] # persistent
then
    mv "/tmp/$name" "$name"
    if [ "$o_flag" = true ] && [ -f "$name" ] # persistent and open
    then
        xdg-open "$name" 2> /dev/null
    fi
elif [ "$o_flag" = true ] && [ -f "/tmp/$name" ] # non persistant but open
then
    xdg-open "/tmp/$name" 2> /dev/null
fi

