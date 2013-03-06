.PHONP: clean all cleanasp txm tei archives

#export directories
TXMDIR=MPT-TXM-TXT-CSV
TEIDIR=MPT-TEI

#Generated docs directories
XMLDIR=files/xml/
TXTDIR=files/txt/
HTMLDIR=files/html/

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


$(XMLDIR)%.xml: $(HTMLDIR)%.asp compte_rendu_to_tei.pl
	./compte_rendu_to_tei.pl $< > $@

$(TXTDIR)%.txt: $(XMLDIR)%.xml
	xsltproc xmltei_to_plaintext.xsl $< > $@

all: $(CRANMPT:%=$(XMLDIR)%.xml) $(TXTDIR)tout.txt

$(TXTDIR)tout.txt: $(CRANMPT:%=$(TXTDIR)%.txt)
	cat $$(ls 2013*.txt |sort) >$(TXTDIR)tout.txt

clean:
	rm -rf *.xml *.txt $(TXMDIR)* $(TEIDIR)* metadata.csv

cleanasp:
	rm -f *.asp

$(TXMDIR):
	mkdir $(TXMDIR)

$(TEIDIR):
	mkdir $(TEIDIR)

txm: metadata.csv $(TXMDIR) $(CRANMPT:%=%.txt)
	cp $(TXTDIR)2013*.txt $(TXMDIR)
	cp metadata.csv $(TXMDIR)
	zip $(TXMDIR).zip $(TXMDIR)/*

metadata.csv:
	./gen_txm_metadata.sh

tei: $(TEIDIR) $(CRANMPT:%=%.xml)
	cp $(XMLDIR)*.xml $(TEIDIR)
	zip $(TEIDIR).zip $(TEIDIR)/*

archives: txm tei

download:
	@for cranmpt in $(CRANMPT) ; do \
	cd $(HTMLDIR)
	wget "http://www.assemblee-nationale.fr/14/cri/2012-2013/$${cranmpt}.asp" ; \
	done

