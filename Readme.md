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
lexicographiques avec des outils comme
[Philologic](https://sites.google.com/site/philologic3/) ou
[TXM](http://textometrie.ens-lyon.fr/).

Télécharger
===========

Si vous voulez juste utiliser les fichiers *.txt et *.xml produits
dans une archive .zip :

- les fichiers [XML
  TEI](http://perso.obspm.fr/nicolas.legrand/MPT-TEI.zip) (importable
  en l'état dans [Philologic](https://sites.google.com/site/philologic3/)) ;

- les fichiers
  [TXT](http://perso.obspm.fr/nicolas.legrand/MPT-TXM-TXT-CSV.zip)
  (importable en l'état avec leurs métadonnées en CSV via le module
  TXT+CSV dans le logiciel [TXM](http://textometrie.ens-lyon.fr/)).

Exemples de résultats
=====================

J'ai écris sur mon [carnet hypothèse](http://eproto.hypotheses.org/)
un [premier billet](http://eproto.hypotheses.org/126) débroussaillant
ce que l'on peut tirer de ces débats.

Il est aussi possible de générer des graphiques de ce type :

![enfant](enfant.png)

Vous voyez tous les mots coocurrents du mot « enfant » avec leur
propre fréquence, leur fréquence de cooccurrence ainsi que la
distance moyenne de chaque mots avec le mot « enfant ».

Ce graphique a été réalisé avec un résultat de cooccurrences de
[TXM](http://textometrie.ens-lyon.fr/) et la bibliothèque ggplot2 de
R.

Référence
=========

Serge Heiden m'a averti de l'existence de deux articles de la revue
[Mot](http://mots.revues.org/) de 1999 donnant de très bonnes idées
d'exploitation de ce type de corpus :

- S. Bonnafous, D. Desmarchelier : « [Quand les députés coupent le
  RESEDA](http://www.persee.fr/web/revues/home/prescript/article/mots_0243-6450_1999_num_60_1_2166) » ;

- S. Heiden : [Encodage uniforme et normalisé de corpus. Application à
  l'étude d'un débat
  parlementaire](http://www.persee.fr/web/revues/home/prescript/article/mots_0243-6450_1999_num_60_1_2168).

Utilisation
===========

Fonctionne dans un environnement *nix (Linux, Mac OS X,
BSD). Nécessite GNU `make(1)`, `perl(1)`, `wget(1)`, `xsltproc(1)`,
éventuelement `git(1)` et `zip(1)`.

    git clone git://github.com/nlegrand/mariagepourtousInXML.git
    cd mariagepourtousInXML/
    make

Créer les archives *.zip contenant les *.txt ou les *.xml :

    make archives

Mise à jour
===========

Pour mettre à jour avec les dernières modifications :

    git pull
    make clean
    make

Todo
====

Tester automatiquement la validité du XML.

Enrichir le XML pour faire des recherches par orateur dans philologic.

Créer des fichiers XML importables dans TXM.
