# Features

Simple script that searches with ![ripgrep-all](https://github.com/phiresky/ripgrep-all) in pdfs and combines all matching pages in one pdf.


# Flags

| Flag               | Description                                                                               |
|--------------------|-------------------------------------------------------------------------------------------|
| --no-open          | Do not open result automatically. Implies --save                                          |
| --no-links         | Do not add links to original file to pages                                                |
| --save             | Save result to the current folder                                                         |
| -n / --name        | Result name. Default: 'pages_with_\$searchTerm'. Implies --save                           |
| -s / --seach       | Specify search term                                                                       |
| --exclude-previous | Do not search on pages that have been outputted by this script (matched by 'pages_with_') |
| -h / --help        | Show help                                                                                 |

# Installing

Install: `make install`. Will put rga-pdf.sh (rpdf) and makePdf.py (makePdf.py) files to `~/.local/bin/<file-name>`. The link for `rga-pdf.sh` will be named `rpdf`.

Clean: `make clean`. Same as `make uninstall`.

Uninstall: `make uninstall`. Will remove both files from `~/.local/bin/`.

## Nixos

- `nix build && ./result/bin/rpdf`
