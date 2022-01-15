INSTALLPATH = ~/.local/bin
WORKINGDIR = $(shell pwd)

install:
	sudo chmod +x rga-pdf.sh
	ln -si ${WORKINGDIR}/makePdf.py ${INSTALLPATH}/makePdf.py
	chmod +x ${INSTALLPATH}/makePdf.py
	ln -si ${WORKINGDIR}/rga-pdf.sh ${INSTALLPATH}/rpdf

clean: uninstall

uninstall:
	rm ${INSTALLPATH}/makePdf.py
	rm ${INSTALLPATH}/rpdf
