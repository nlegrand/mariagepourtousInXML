Sur le long terme je souhaiterai avoir un joli fichier
[TEI](http://www.tei-c.org/index.xml) à partir duquel je générerai les
fichiers dont j'ai besoin. Pour l'instant le XML en l'état est plutôt
laid, mais déjà utilisable. N'hésitez pas à me conseiller un meilleur
encodage, je compte l'améliorer au fur et à mesure.

Les fichiers sont consultables en ligne sur [ce
repository](https://github.com/nlegrand/mariagepourtousInXML/tree/master/files/xml).

Entête
======

L'entête est repris de l'[entête exemple de
Philologic](https://sites.google.com/site/philologic3/encoding), à
l'exception du tag racine qui est <TEI>.

Outre l'espace de nom de TEI on voit un espace de nom
`xmlns:mpt="http://mpt.ethelred.fr/ns/0.0/"`. Cet espace de nom bidon
permet de mettre des balises custom contenant des métadonnées.

Corps de texte
==============

Le texte se trouve dans un jeu de balise TEI classique :

    <text>
      <body>
      LE TEXTE SE TROUVE LÀ
      </body>
    </text>

Partie et sous partie sont un simple emboîtage de :

    <div>
      <head>PARTIE</head>
      TEXTE
      <div>
        <head>SOUS-PARTIE</head>
	TEXTE
      </div> 
    </div>

Le texte lui-même
=================

Le texte ressemble à un encodage très minimaliste de théâtre :

    <sp>
      <speaker>Henri Jibrayel</speaker>
      <p>Grâce à vous !</p>
    <sp>

La différence avec de la TEI classique est que le texte lui-même est
englobé dans une balise `<mpt:metadata>`, qui comme son nom l'indique
décrit le texte :

    <sp who="Henri_Jibrayel">
      <speaker>Henri Jibrayel</speaker>
      <mpt:metadata auteur="Henri_Jibrayel" interventiontype="interruption" politicalgroup="SRC"  vote="pour" gender="male" politicalgender="SRC_male" wing="left" winggender="left_male" debat="qag" subject="mpt">
      <p>Grâce à vous !</p>
      </mpt:metadata>
    </sp>

Il est probable que des spécialistes des métadonnées se crèvent un œil
en voyant ça, n'hésitez pas à m'indiquer de meilleures manières de
procéder. Finalement cela ressemble plus au format de sortie avant
import dans TXM qu'au fichier que je compte avoir.

Les métadonnées permettent d'échantillonner, rééchantillionner le
texte dans TXM. Ainsi peut on étudier seulement les interventions des
membres du groupe SRC, ou comparer interventions des groupes GDR et
Ecolo, etc.

Voyons les attributs :

- auteur : l'auteur de la réplique ;

- interventiontype : 'interruption', 'intervention' ou
  'régulation'. Régulation représente l'ensemble des interventions de
  la présidence (on peut donc les exclure d'une
  analyse). 'interruption' est une saillieq d'un député n'ayant pas la
  parole et qui est rapportée par le compte rendu. 'intervention' est
  une intervention appelé par le présidence de séance. Ce tag a été
  fait automatiquement et nécessite encore une relecture avant d'être
  exploité ;

- politicagroup : SRC, GDR, RRDP, UMP, ECOLO, NI, UDI et GVT (pour le
  gouvernement) ;

- vote : 'pour', 'contre', le résultat du vote final (notez le mélange
  d'anglais et de français que je compte corriger) ;

- gender : 'male', 'female' ;

- politicalgender : politicalgroup_gender (crade, mais permet de faire
  des échantillons plus raffinées dans TXM ;

- wing : 'left', 'right' ;

- wingender : wing_gender ;

- debat : la position de la réplique dans la séance. Questions au
  gouvernement, 'qag', discussions sur l'ouverture du mariage aux
  couples de même sexe 'mpt', autres (comme la présidence) 'other'.

- subject : mêmes valeurs que debat, permet de repérer quand on a
  parlé du mariage pour tous dans les qag par exemple.

Autre balise custom : <mpt:interruption>. Eg :

    <mpt:interruption type="Applaudissements" text="Applaudissements sur les bancs du groupe UMP"/>

Relève une description d'interruption, sans polluer le texte avec.
