#!/usr/bin/env python3

import os
import sys
import io
import json
from reportlab.pdfgen import canvas
from PyPDF2 import PdfFileReader, PdfWriter

OUTPUT_PREFIX = "pages_with_"
BOOL_TRUE = ['true', '1', 't', 'y', 'yes']

#--------------------------------------------------------------------#
#               Matches a filename to a list of pages                #
#--------------------------------------------------------------------#

class Matches:
    def __init__(self):
        self.matches = {}

    def addMatch(self, filename, pageNum):
        # convert pageNum to int
        pageNum = int(pageNum)

        # get current pages
        pages = self.getMatches(filename)

        # don't add duplicates
        if pageNum not in pages:
            pages.append(pageNum)

            pages.sort()

            # put array back into place
            self.matches.update({filename:pages})

    # return pages for a filename
    def getMatches(self, filename):
        return self.matches.get(filename, [])

    # return all file names
    def getFiles(self):
        keys = list(self.matches.keys())
        keys.sort()
        return keys

    # count all pages
    def size(self):
        size = 0
        for filename in self.matches:
            size += len(self.getMatches(filename))

        return size

#--------------------------------------------------------------------#
#                          Parse arguments                           #
#--------------------------------------------------------------------#

addLinks = sys.argv[1].lower() in BOOL_TRUE
fileName = sys.argv[2]
current_path = sys.argv[3]
skipPrevOutput = sys.argv[4].lower() in BOOL_TRUE

#--------------------------------------------------------------------#
#                           Prepare pages                            #
#--------------------------------------------------------------------#

matches = Matches()

# parse stin
for line in sys.stdin:

    try:
        filename = json.loads(line)[0]
        page = json.loads(line)[1]
    except:
        print("Could not parse input: " + line)
        continue

    # skip non-pdf files
    if filename.split(".")[-1] != "pdf":
        print("Skipping non-pdf: " + filename)
        continue

    # skip pdfs that have been outputted by this script
    if filename.startswith(OUTPUT_PREFIX) and skipPrevOutput:
        print("Skipping " + filename)
        continue

    matches.addMatch(filename, page)

if matches.size() == 0:
    print("No matches")
    exit()
else:
    print("%s pages matched" % matches.size())

# prepare output
output = PdfWriter()

#--------------------------------------------------------------------#
#                           Create new pdf                           #
#--------------------------------------------------------------------#

# frankensteining new pdf
for filename in matches.getFiles():
    if filename == "":
        continue
    f = PdfFileReader(open(filename, "rb"), strict=False)

    # write filename to a temp pdf
    packet = io.BytesIO()
    can = canvas.Canvas(packet)
    can.setFillColorRGB(0.7, 0.7, 0.7)
    can.drawString(4, 4, filename)

    filenameWidth = can.stringWidth(filename)
    linkRect = (0, 0, filenameWidth, 20)
    path = "file://" + current_path + "/" + filename
    can.linkURL(path, linkRect)
    can.save()

    packet.seek(0)
    tmppdf = PdfFileReader(packet)

    # go through pages
    for pageNum in matches.getMatches(filename):
        page = f.getPage(pageNum-1)
        # add links with wanted
        if addLinks:
            page.merge_page(tmppdf.getPage(0))

        # add page to output pdf
        output.addPage(page)

#--------------------------------------------------------------------#
#                           Write new pdf                            #
#--------------------------------------------------------------------#

# filename
path = "/tmp/" + fileName

# remove if exists
if os.path.exists(path):
    os.remove(path)

# write pdf
outputStream = open(path, "bw")
output.write(outputStream)
outputStream.close()

print("Pdf ready")
