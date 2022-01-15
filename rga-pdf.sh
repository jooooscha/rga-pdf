#!/usr/bin/bash

openDirectly=true
addLinks=true
files=""
saveFile=false
searchTerm=""
excludeprevoutput=false
filename=""

showHelp() {
cat << EOF
rpdf -- Version 2.0
Usage:

    --no-open           Do not open result automatically. Implies --save
    --no-links          Do not add links to original file to pages
    --save              Save result to the current folder
    -n | --name         Result name. Default: 'pages_with_\$searchTerm'. Implies --save
    -s | --seach        Specify search term
    --exclude-previous  Do not search on pages that have been outputted by this script (matched by 'pages_with_')
    -h | --help         Show help
EOF
}

#--------------------------------------------------------------------#
#                   Evaluate command line options                    #
#--------------------------------------------------------------------#

options=$(getopt -l "no-open,no-links,files:,save,search:,help,exclude-previous,name:" -o "f:s:hn:" -a -- "$@")

eval set -- "$options"

while true
do
    case $1 in
         --no-open)
            openDirectly=false
            saveFile=true
            ;;
         --no-links)
            addLinks=false
            ;;
        -f | --files)
            shift
            files=$1
            ;;
        --save)
            saveFile=true
            ;;
        -s | --search)
            shift
            searchTerm=$1
            ;;
        -h | --help)
            showHelp
            exit 0
            ;;
        -n | --name)
            shift
            filename="$1"
            saveFile=true
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

name="pages_with_$searchTerm.pdf"
[ "$filename" = "" ] && filename="$name"

#--------------------------------------------------------------------#
#                  Exit if no search term was given                  #
#--------------------------------------------------------------------#

if [ "$searchTerm" = "" ] # check if no input was given
then
  
  showHelp
  exit
fi


#--------------------------------------------------------------------#
#         Call python script to do the actual searching and          #
#                              stiching                              #
#--------------------------------------------------------------------#

rga -P "($searchTerm)" $files \
  | rga --json -P "(^.+?(?=:)|(?<=Page )[0-9]+)" \
  | jq -rc "select(.type == \"match\").data.submatches | [.[0].match.text, .[1].match.text]" \
  | makePdf.py "$addLinks" "$name" "$(pwd)" "$excludeprevoutput" \
    || echo "Something went wrong; most likely with the python script"


#--------------------------------------------------------------------#
#             Evaluate the result of the python script               #
#--------------------------------------------------------------------#

# exit if pdf is not in tmp folder
! [ -f "/tmp/$name" ] && echo "Could not find /tmp/$name" && exit

filepath="/tmp/$name"

# write file to current directory
if [ "$saveFile" = true ]
then
    mv "/tmp/$name" "$filename"
    filepath=$filename
fi

if [ "$openDirectly" = true ]
then
    evince "$filepath" 2> /dev/null
fi
