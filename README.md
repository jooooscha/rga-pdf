# Features

Simple script that searches with ![ripgrep-all](https://github.com/phiresky/ripgrep-all) in pdfs and combines all matching pages in one pdf.


# Flags

|              |                                                                       |
|--------------|-----------------------------------------------------------------------|
| -v --no-view | Show pdf                                                              |
| --no-link    | Link to original pdf                                                  |
| -f --files   | Files to seach                                                        |
| -o --output  |                                                                       |
| -s --search  | searchterm                                                            |
    


# Installing

Install: `make install`. Will put both files to `~/.local/bin/<file-name>`. The link for `rga-pdf.sh` will be named `rpdf`.

Clean: `make clean`. Same as `make uninstall`.

Uninstall: `make uninstall`. Will remove both files from `~/.local/bin/`.
