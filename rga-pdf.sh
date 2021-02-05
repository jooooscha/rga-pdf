o_flag=false
input=""
persistent=false
addfilename=false

while getopts "os:pf" arg
do
    case "${arg}" in
        o) o_flag=true ;;
        s) input="${OPTARG}" ;;
        p) persistent=true ;;
        f) addfilename=true
    esac
done

searchterm=$input
input=${input// /_}

if [ "$input" == "" ]
then
    echo "invalid input"
    exit
fi

name="results_of_$input.pdf"

# rga "$searchterm" | sort | sed 's/: .*//' | sed 's/:Page//' | sort | python ~/.local/bin/get_pages.py "$addfilename" > /dev/null 2>&1 && mv --backup=numbered "output.pdf" "$name" || echo "python error"
rga "$searchterm" | sort | sed 's/: .*//' | sed 's/:Page//' | sort | python ~/.local/bin/get_pages.py "$addfilename" && mv --backup=numbered "output.pdf" "$name" || echo "python error"

echo "searching for $input"

if [ "$persistent" = false ] && [ -f "$name" ]
then
    mv "$name" "/tmp/$name"
    if [ "$o_flag" = true ] && [ -f "/tmp/$name" ]
    then
        xdg-open "/tmp/$name" 2> /dev/null
    fi
elif [ "$o_flag" = true ] && [ -f "$name" ]
then
    xdg-open "$name" 2> /dev/null
fi


