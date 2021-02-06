# Features

Simple script that searches with ![ripgrep-all](https://github.com/phiresky/ripgrep-all) in pdfs and combines all matching pages in one pdf.


# Flags

|             |                                                                       |
|-------------|-----------------------------------------------------------------------|
| -s <string> | Term to search for in pdfs                                            |
| -o          | Automatically open pdf viewer                                         |
| -p          | Keep the result file persistant. Otherwise will be created in `/tmp/` |
| -f          | Add origin file to bottom corner of page.                             |
    


# Installing

Install: `make install`. Will put both files to `~/.local/bin/<file-name>`. The link for `rga-pdf.sh` will be named `rpdf`.

Clean: `make clean`. Same as `make uninstall`.

Uninstall: `make uninstall`. Will remove both files from `~/.local/bin/`.
