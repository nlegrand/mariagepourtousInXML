#!/usr/bin/perl

# Copyright (c) 2012 Nicolas Legrand <nicolas.legrand@gmail.com>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

# Usage: compte_rendu_to_tei <french national assembly report>

# transform a french national assembly report into TEI lite. Written
# specifically for "mariage pour tous" sessions.

use strict ;
use warnings ;
use Encode;
use JSON;

sub clean_entities {
    my $string = shift @_ ;
    $$string =~ s/<(:?a|b|i|font).*?>//g;
    $$string =~ s!</(:?a|b|i|font)>!!g;
    $$string =~ s/<!--.*?-->//g;
    $$string =~ s/&nbsp;/ /g;
    $$string =~ s/&#8217;/'/g;
    $$string =~ s/&#339;/œ/g;
    $$string =~ s/&#8230;/.../g;
    $$string =~ s/&#8211;/–/g;
}

sub tag_interruption {
    my $string = shift @_;
    $$string =~ s/\((?:Vives |Nouvelles ){0,1}(«.*?»|Applaudissements|Mêmes mouvements|Exclamations|Protestations|Les députés|Sourires|Rires|Murmures)(.*?)\)/<mpt:interruption type="$1" text="$1$2"\/>/g;
    $$string =~ s/([\w0-9]+)<sup>(.*?)<\/sup>/<w>$1<hi rend="sup">$2<\/hi><\/w>/g;
    $$string =~ s/(aujourd'hui)/<w>$1<\/w>/ig;
#    $$string =~ s/\((Applaudissements)(.*?)\)/<mpt:interruption type="$1" text="$1$2"\/>/g;
}

sub print_body {
    my ($aspfilename, $deputes_id, $official_id) = @_;
    my $div_state = "main";	#main, subpart, subsubpart
    my $sp_state = "closed";	#closed open
    my $debat_position = "other"; #mpt -> mariage pour tous, qag -> question au gouvernement
    my $debat = "";
    my $last_intervenant = "";
    print "<text>\n";
    print "<body>\n";
    open my $aspfh, "<", $aspfilename
      or die "can't open $aspfilename : $!" ;
    while (<$aspfh>) {

	if (m!<p class="sstitreinfo"><b><i>(Suite de la discussion d&#8217;un projet de loi)</i></b></p>!) {
	    my $sstitre = $1;
	    clean_entities(\$sstitre);
	    print "<p>$sstitre</p>\n";
	} elsif (m!^<p>.*?<b>(.*?)</b>(?:<i>(.*?)</i>.){0,1}(.*)</p>!) {
	    my $intervenant = encode("utf8", $1);
	    my $titre = encode("utf8", $2) || "";
	    if ($titre) {
		clean_entities(\$titre);
		$titre = "," . $titre ;
	    }
	    my $intervention = encode("utf8", $3) ;
	    my $intervenant_id = "";
	    my $genre = "";
	    my $intervention_type = "";
	    my $intervention_id = "";
	    my $political_group = "";
	    my $vote = "";
	    if (m!<a href="http://www.assemblee-nationale.fr/14/tribun/fiches_id/([0-9]+).asp" target="_top">!) {
		$intervenant_id = $1;

		if ($deputes_id->{$intervenant_id}{'nom'}) {
		    $intervenant = encode("utf8", $deputes_id->{$intervenant_id}{'nom'});
		}
		if ($deputes_id->{$intervenant_id}{'sexe'}) {
		    if ($deputes_id->{$intervenant_id}{'sexe'} eq 'H') {
			$genre="male";
		    } elsif ($deputes_id->{$intervenant_id}{'sexe'} eq 'F') {
			$genre="female";
		    }
		}
	    } elsif ($intervenant =~ /Taubira/i) {
		$genre="female";
		$political_group = "GVT";
		$intervenant = "Christiane Taubira"
	    } elsif ($intervenant =~ /Bertinotti/i) {
		$genre="female";
		$political_group = "GVT";
		$intervenant = "Dominique Bertinotti"
	    }
	    if ($intervenant =~ /président/) {
		$intervention_type = "régulation";
	    } elsif (m!<a name="(INTER_(?:MINISTRE_ADT_|ADT_){0,1}[0-9]+)"></a>!) {
		$intervention_id = "corresp=\"http://www.assemblee-nationale.fr/14/cri/2012-2013/$official_id#$1\"";
		$intervention_type = "intervention";
		$last_intervenant = $intervenant;
	    } elsif ($last_intervenant eq $intervenant) {
		$intervention_type = "intervention";
	    } else {
		$intervention_type = "interruption";
	    }
	    if ($intervention_type && $intervenant_id) {
		if ($deputes_id->{$intervenant_id}{'groupe'}) {
		    $political_group =
			encode("utf8", $deputes_id->{$intervenant_id}{'groupe'}) ;
		    $vote = "vote=\""
			. encode("utf8", $deputes_id->{$intervenant_id}{'vote'})
			. "\"";
		}
	    }
	    clean_entities(\$intervenant);
	    clean_entities(\$intervention);
	    if ($sp_state eq "open") {
		print "\n</mpt:metadata>\n";
		print "\n</sp>\n";
	    } else {
		$sp_state = "open";
	    }
	    $intervenant =~ s/(?:M\.|Mme) //;
	    $intervenant =~ s/[\.,]//g;
	    &tag_interruption(\$intervention);
	    my $who = $intervenant;
	    $who =~ s/ /_/g;
	    print "\n<sp who=\"$who\">\n";
	    print "  <speaker>$intervenant$titre</speaker>\n";
	    my $att_political = "";
	    my $att_gender = "";
	    my $att_political_gender = "";
	    if ($political_group) {
		$att_political = "politicalgroup=\"$political_group\"";
	    }
	    if ($genre) {
		$att_gender = "gender=\"$genre\"";
	    }
	    if ($genre && $political_group) {
		$att_political_gender = "politicalgender=\""
		    . $political_group
		    . "_"
		    . $genre
		    . "\"";
	    }
	    my $wing="";
	    if ($political_group eq 'ECOLO') {
		$wing="left";
	    }
	    if ($political_group eq 'GDR') {
		$wing="left";
	    }
	    if ($political_group eq 'GVT') {
		$wing="left";
	    }
	    if ($political_group eq 'NI') {
		$wing="right";
	    }
	    if ($political_group eq 'RRDP') {
		$wing="left";
	    }
	    if ($political_group eq 'SRC') {
		$wing="left";
	    }
	    if ($political_group eq 'UDI') {
		$wing="right";
	    }
	    if ($political_group eq 'UMP') {
		$wing="right";
	    }
	    my $winggender = "";
	    if ($genre && $wing) {
		$winggender = "winggender=\""
		    . $wing
		    . "_"
		    . $genre
		    . "\"";
	    }
	    $wing = "wing=\"$wing\"" if $wing;
	    if ($genre) {
		$att_gender = "gender=\"$genre\"";
	    }
	    if ($genre && $political_group) {
		$att_political_gender = "politicalgender=\""
		    . $political_group
		    . "_"
		    . $genre
		    . "\"";
	    }
	    print "\n<mpt:metadata auteur=\"$who\" interventiontype=\"$intervention_type\" $att_political $intervention_id $vote $att_gender $att_political_gender $wing $winggender $debat>\n";
	    print "  <p>$intervention</p>\n";
	} elsif (m!^<p>(.*?)</p>!) {
	    my $para = encode("utf-8", $1) ;
	    clean_entities(\$para);
	    &tag_interruption(\$para);
	    print "<p>$para</p>\n";
	}

	if (m!<h2 class="(.*?)">(.*?)</h2>!) {
	    if ($sp_state eq "open") {
		print "</mpt:metadata>";
		print "</sp>\n";
		$sp_state = "closed";
	    }
	    my $div_level = $1 ;
	    my $div_head = encode("utf8", $2) ;
	    if ($div_level eq 'titre1') {
		if (/(?:Ouverture du mariage|Projet de loi)/i) {
		    $debat_position = "mpt";
		} elsif (/Questions/) {
		    $debat_position = "qag";
		} else {
		    $debat_position = "other";
		}
	    }
	    $debat = "debat=\"$debat_position\" subject=\"$debat_position\"";
	    clean_entities(\$div_head) ;
	    if ($div_state eq "subpart" and $div_level eq "titre1") {
		print "</div>\n";
	    } elsif ($div_state eq "subsubpart" and $div_level eq "titre1") {
		print "</div>\n</div>\n";
	    } elsif ($div_state eq "subsubpart"
		     and ($div_level eq "titre3" or $div_level eq "titre2")) {
		print "</div>\n";
	    }  
	    if ($div_state eq "main" and $div_level eq "titre3") {
		print "<div>\n"; # XXX empty div, generated to follow the logic check 2013125
	    }
	    if ($div_level eq "titre1") {
		$div_state = "subpart";
	    } elsif ($div_level eq "titre3"
		or $div_level eq "titre2") {
		$div_state = "subsubpart";
	    }
	    print "\n\n<div>\n";
	    print "<head>$div_head</head>\n";
	}
	if (m!<h5 class="presidence"><b>(.*?)</b></h5>!) {
	    my $presidence = encode("utf8", $1);
	    clean_entities(\$presidence);
	    print "<p>$presidence</p>\n";
	}
    }
    if ($sp_state eq "open") {
	print "</mpt:metadata>\n";
	print "</sp>\n";
    }
    if ($div_state eq "subpart") {
	print "</div>\n";
    } elsif ($div_state eq "subsubpart") {
	print "</div>\n</div><\n";
    }
    close $aspfh;
    print "</body>\n";
    print "</text>\n";
}

  sub print_xml {
      my ($aspfilename, $deputes_id , $official_id) = @_;

      my $title = $official_id;
      my $date = "";
      my $director = "";
      open my $aspfh, "<", $aspfilename
	or die "can't open $aspfilename : $!" ;

      while (<$aspfh>) {
	  $_ = encode("utf8", $_);
	  clean_entities(\$_);
	  if (m!<h1 class="seance">(.*2013)</h1>!) {
	      $title = "Mariage pour tous - " . $1 ;
	      $title =~ /séance du (.*2013)/;
	      $date = $1;
	  }
	  if (m!<div id="signature"><p align="center">(.*?)</p>!) {
	      $director = $1;
	  }
      }

      close $aspfh ;

      print <<"TEIHEADER";
<?xml version="1.0" encoding="UTF-8"?>
<TEI xmlns="http://www.tei-c.org/ns/1.0" xmlns:mpt="http://mpt.ethelred.fr/ns/0.0/">
   <teiHeader>
      <fileDesc>
         <titleStmt>
            <title>$title</title>
            <author>Assemblée nationale</author>
            <respStmt>
               <resp>Le Directeur du service du compte rendu de la séance</resp>
               <name>$director</name>
            </respStmt>
         </titleStmt>
         <editionStmt>
            <edition> <date>$date</date> </edition>
         </editionStmt>
	 <publicationStmt>
            <publisher>Nicolas Legrand</publisher>
	    <availability>
               <p>Made from the pages at http://www.assemblee-nationale.fr/14/dossiers/mariage_personnes_meme_sexe.asp</p>
            </availability>
	 </publicationStmt>
      </fileDesc>
      <encodingDesc>
         <projectDesc>
            <p>Comptes rendus des débats de l AN sur le mariage pour tous</p>
         </projectDesc>
      </encodingDesc>
      <profileDesc>
         <creation>
            <date>$date</date>
            <address>
               <addrLine>France</addrLine>
            </address>
         </creation>
         <langUsage>
            <language>Français</language>
         </langUsage>
    </profileDesc>
    </teiHeader>
TEIHEADER

      print_body($aspfilename, $deputes_id, $official_id);

      print "</TEI>\n";
  }

my $aspfilename =  $ARGV[0];
my $official_id = $aspfilename;
$official_id =~ s!files/html/!!;

open my $fh, "<", "deputes_id.json";
my $deputes_id;
  {
      local $/;
       $deputes_id =  decode_json <$fh> ;
  }
close $fh;

&print_xml($aspfilename , $deputes_id , $official_id);

