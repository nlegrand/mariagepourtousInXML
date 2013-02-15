#ID des Comptes rendus de l'Assemblée Nationale sur le mariage pour tous
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


%.xml: %.asp compte_rendu_to_tei.pl
	./compte_rendu_to_tei.pl $< > $@

all: $(CRANMPT:%=%.xml)

clean:
	rm *.xml

download:
	@for cranmpt in $(CRANMPT) ; do \
	wget "http://www.assemblee-nationale.fr/14/cri/2012-2013/$${cranmpt}.asp" ; \
	done

