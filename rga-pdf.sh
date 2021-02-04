rga "$1" | sort | sed 's/: .*//' | sed 's/:Page//' | sort | python ~/.local/bin/get_pages.py 2> /dev/null && mv --backup=numbered "output.pdf" "results_of_$1.pdf"

