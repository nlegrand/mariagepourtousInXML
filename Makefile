.PHONP: clean all cleanasp txm tei archives

#export directories
XMLARCHIVE=MPT

#Generated docs directories
XMLDIR=files/xml/
TXTDIR=files/txt/
HTMLDIR=files/html/
GEXFDIR=files/gexf/

#ID of National French Assembly Report about same sex marriage
CRANMPT=20130118 \
	20130119 \
	20130120 \
	20130121 \
	20130124 \
	20130125 \
	20130126 \
	20130127 \
	20130128 \
	20130129 \
	20130130 \
	20130131 \
	20130132 \
	20130133 \
	20130134 \
	20130135 \
	20130136 \
	20130137 \
	20130138 \
	20130139 \
	20130140 \
	20130141 \
	20130142 \
	20130143 \
	20130144


$(TXTDIR)%.txt: $(XMLDIR)%.xml
	xsltproc xmltei_to_plaintext.xsl $< > $@

all: $(TXTDIR)tout.txt

$(TXTDIR)tout.txt: $(CRANMPT:%=$(TXTDIR)%.txt)
	cat $$(ls $(TXTDIR)2013*.txt |sort) >$(TXTDIR)tout.txt

$(GEXFDIR)/mpt.gexf: tei_to_gexf.py $(CRANMPT:%=$(XMLDIR)%.xml)
	tei_to_gexf.py $(CRANMPT:%=$(XMLDIR)%.xml) > $@

clean:
	rm -rf $(XMLDIR)*.xml $(TXTDIR)*.txt $(TXMDIR)* $(TEIDIR)* metadata.csv

cleanasp:
	rm -f $(HTMLDIR)*.asp

$(XMLARCHIVE):
	mkdir $@

archive: $(XMLARCHIVE)
	cp $(CRANMPT:%=$(XMLDIR)%.xml) $(XMLARCHIVE)
	cp $(XMLDIR)/metadata.csv $(XMLARCHIVE)
	zip $(XMLARCHIVE)_$$(date +%Y-%m-%d).zip $(XMLARCHIVE)/*

metadata.csv:
	./gen_txm_metadata.sh

download:
	@for cranmpt in $(CRANMPT) ; do \
	cd $(HTMLDIR)
	wget "http://www.assemblee-nationale.fr/14/cri/2012-2013/$${cranmpt}.asp" ; \
	done

