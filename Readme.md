Télécharge les comptes rendus de séance de l'Assemblée nationale et
les transforme en XML TEI.

Le but est de pouvoir les retransformer « proprement » en quoique ce
soit (docbook, txt, xhtml...), dans le but de faire des recherches
lexicographiques. Les fichiers générés sont chargeables en l'état dans
le logiciel [philologic](https://sites.google.com/site/philologic3/).

Utilisation
===========

Fonctionne dans un environnement *nix (Linux, Mac OS X,
BSD). Nécessite GNU `make(1)`, `perl(1)`, `wget(1)`, éventuelement
`git(1)`.

    git clone git://github.com/nlegrand/mariagepourtousInXML.git
    cd mariagepourtousInXML/
    make download
    make

Bug
===

&lt;sp&gt; se referme beaucoup trop tôt : prise en compte des autres
paragraphes.


