import os
import sys
from PyPDF2 import PdfFileMerger, PdfFileReader, PdfFileWriter


array = [] # (filename, [ pages ])
current_array = [] # temp array

current_page = ""
i = -1

# parse input
for line in sys.stdin:
    filename, page_num = line.split()

    if (filename.split(".")[-1] != "pdf"):
        continue

    if current_page != filename:

        if current_page != "" :
            array.append((current_page, current_array))
            current_array = []

        current_page = filename

        i = i + 1

    current_array.append(page_num)


array.append((current_page, current_array)) # append last found

# convert string to int
intarray = []
for name, pages in array:
    tmparray = []
    for p in pages:
        tmparray.append(int(p))

    intarray.append((name, tmparray))

# sort and remove doubles
sortarr = []
for name, pages in intarray:
    sortarr.append((name, sorted(list(dict.fromkeys(pages)))))

# prepare output
output = PdfFileWriter()

# combine pages
for filename, pages in sortarr:
    f = PdfFileReader(open(filename, "rb"))
    for pagenum in pages:
        output.addPage(f.getPage(pagenum-1))

# filename
f = "output.pdf"

# remove if exists
if os.path.exists(f):
    os.remove(f)

# write
outputStream = open(f, "bw")
output.write(outputStream)
outputStream.close()

print("file written")
