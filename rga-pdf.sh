o_flag=false
input=""
delete=false

while getopts "os:d" arg
do
    case "${arg}" in
        o) o_flag=true ;;
        s) input="${OPTARG}" ;;
        d) delete=true ;;
    esac
done

if [ "$input" == "" ]
then
    echo "invalid input"
    exit
fi

name="results_of_$input.pdf"

rga "$input" | sort | sed 's/: .*//' | sed 's/:Page//' | sort | python ~/.local/bin/get_pages.py > /dev/null 2>&1 && mv --backup=numbered "output.pdf" "$name" || echo "python error"

echo "searching for $input"

if [ "$delete" = true ] && [ -f "$name" ]
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


