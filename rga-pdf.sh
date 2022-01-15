#!/usr/bin/bash

# open=true
# input=""
# output=false
# linkfilename=true
# excludeprevoutput=true
# filestosearch=""

# get opts ------------------------------------------------------------
# while getopts "os:plif:" arg
# do
#     case "${arg}" in
#         # o) o_flag=false ;;
#         s) input="${OPTARG}" ;;
#         o) output=true ;; # p - move file to persistent storage (current dir)
#         l) linkfilename=false ;; # f - add Filename to bottom of page
#         i) excludeprevoutput=false ;; # i - Include prev outptu
#         f) filestosearch="${OPTARG}" ;; # files to seach through
#     esac
# done

view=true
links=true
files=""
output=false
search=""
excludeprevoutput=false

showHelp() {
cat << EOF
Usage:

    --open  Open pdf automatically
EOF
}

options=$(getopt -l "no-view,no-link,files:,output,search:,help,exclude-previous" -o "f:os:hv" -a -- "$@")

eval set -- "$options"

while true
do
    case $1 in
         -v | --no-view)
            view=false
            ;;
         --no-link)
            links=false
            ;;
        -f | --files)
            shift
            files=$1
            ;;
        -o | --output)
            output=true
            ;;
        -s | --search)
            shift
            search=$1
            ;;
        -h | --help)
            showHelp
            exit 0
            ;;
        --exclude-previous)
            excludeprevoutput=true
            ;;
        --)
            shift
            break
            ;;
    esac
    shift
done

# ---------------------------------------------------------------------
# exit if search is empty


if [ "$search" = "" ] # check if no input was given
then
    echo "empty search, use -s or -h for help"
    exit
fi

# ---------------------------------------------------------------------

name="pages_with_$search.pdf"
echo "searching for '$search'"

# ---------------------------------------------------------------------

# main command
# rga --pcre2 "($search)" $files | sort | sed 's/: .*//' | sed 's/:Page//' | sort | python /home/joscha/main/programming/rga-pdf/makePdf.py "$links" "$name" "$(pwd)" "$excludeprevoutput" || echo "Something went wrong; most likely with python"
rga --pcre2 "($search)" $files | sort | sed 's/: .*//' | sed 's/:Page//' | sort | makePdf.py "$links" "$name" "$(pwd)" "$excludeprevoutput" || echo "Something went wrong; most likely with python"

# ---------------------------------------------------------------------

# [ -s "$output" ] && filename=$name || filename="$output"
if [ "$output" = true ] && [ -f "/tmp/$name" ] # write file to current directory
then
    mv "/tmp/$name" "$name"
    if [ "$view" = true ] && [ -f "$filename" ] # write with given name
    then
        evince "$filename" 2> /dev/null
    fi
elif [ "$view" = true ] && [ -f "/tmp/$name" ] # open file
then
    evince "/tmp/$name" 2> /dev/null
fi

