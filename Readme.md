Télécharge les comptes rendus de séance de l'Assemblée nationale sur
l'[ouverture du mariage aux couples de même
sexe](http://www.assemblee-nationale.fr/14/dossiers/mariage_personnes_meme_sexe.asp)
et les transforme en XML TEI et en fichier texte.

À partir de chaque fichier source « _identifiant_.asp » (eg
20130129.asp) sont générés un équivalent « _identifiant_.xml » (XML
TEI) et « _identifiant_.txt ». Un fichier « tout.txt » contient la
concaténation de tous les « _identifiant_.txt ».

Le but est de pouvoir les retransformer « proprement » en quoique ce
soit (docbook, xhtml...), dans le but de faire des recherches
lexicographiques. Les fichiers générés sont chargeables en l'état dans
le logiciel [philologic](https://sites.google.com/site/philologic3/).

Utilisation
===========

Fonctionne dans un environnement *nix (Linux, Mac OS X,
BSD). Nécessite GNU `make(1)`, `perl(1)`, `wget(1)`, `xsltproc(1)`,
éventuelement `git(1)`.

    git clone git://github.com/nlegrand/mariagepourtousInXML.git
    cd mariagepourtousInXML/
    make download
    make

Mise à jour
===========

Pour mettre à jour avec les dernières modifications :

    git pull
    make clean
    make

Todo
====

Tester automatiquement la validité du XML.
