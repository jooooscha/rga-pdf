#!/usr/bin/python3

import os
import sys
import io
from reportlab.pdfgen import canvas
from PyPDF2 import PdfFileReader, PdfFileWriter

#  print(sys.argv)

array = [] # (filename, [ pages ])
current_array = [] # temp array

current_page = ""
i = -1

# parse input
for line in sys.stdin:

    try:
        filename, page_num = line.split()
    except:
        print("Could not parse: " + line)
        continue

    if filename.split(".")[-1] != "pdf" or (filename.startswith("pages_with_") and sys.argv[4]):
        # skip non pdf
        # skip previous ourputs
        continue


    if current_page != filename:
        if current_page != "" :
            array.append((current_page, current_array))
            current_array = []

        current_page = filename

        i = i + 1

    current_array.append(page_num)

array.append((current_page, current_array)) # append last found

if len(array) == 0:
    raise SystemExit("Nothing found") # exits

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

pagecounter = 0

# combine pages
for filename, pages in sortarr:
    if filename == "":
        continue
    f = PdfFileReader(open(filename, "rb"), strict=False)

    # write filename to a temp pdf
    packet = io.BytesIO()
    can = canvas.Canvas(packet)
    can.setFillColorRGB(0.7, 0.7, 0.7)
    can.drawString(4, 4, filename)

    hostnamewidth = can.stringWidth(filename)
    linkRect = (0, 0, hostnamewidth, 20)
    path = "file://" + sys.argv[3] + "/" + filename
    can.linkURL(path, linkRect)
    can.save()

    packet.seek(0)
    tmppdf = PdfFileReader(packet)

    for pagenum in pages:
        page = f.getPage(pagenum-1)
        if sys.argv[1] == 'true': # if wanted: write to original pdf
            page.mergePage(tmppdf.getPage(0))
        output.addPage(page)
        pagecounter += 1

print(str(pagecounter) + " pages have been found")

# filename
f = "/tmp/" + sys.argv[2]

# remove if exists
if os.path.exists(f):
    os.remove(f)


# write
if pagecounter == 0:
    print("Document empty. Nothing written")
    exit()
outputStream = open(f, "bw")
output.write(outputStream)
outputStream.close()

print(sys.argv[2], " written")
