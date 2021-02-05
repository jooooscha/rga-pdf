o_flag=false
input=""
persistent=false

while getopts "os:p" arg
do
    case "${arg}" in
        o) o_flag=true ;;
        s) input="${OPTARG}" ;;
        p) persistent=true ;;
    esac
done

if [ "$input" == "" ]
then
    echo "invalid input"
    exit
fi

echo "searching for $input"

name="results_of_$input.pdf"

rga "$input" | sort | sed 's/: .*//' | sed 's/:Page//' | sort | python ~/.local/bin/get_pages.py > /dev/null 2>&1 && mv --backup=numbered "output.pdf" "$name" || echo "python error"

if [ "$persistent" = false ] && [ -f "$name" ]
then
    mv "$name" "/tmp/$name"
    if [ "$o_flag" = true ] && [ -f "$name" ]
    then
        xdg-open "/tmp/$name" 2> /dev/null
    fi
elif [ "$o_flag" = true ] && [ -f "$name" ]
then
    xdg-open "$name" 2> /dev/null
fi


