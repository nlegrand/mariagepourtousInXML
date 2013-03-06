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

sub print_body {
    my ($aspfilename, $deputes_id, $official_id) = @_;
    my $div_state = "main";	#main, subpart, subsubpart
    my $sp_state = "closed";	#closed open
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
	    if (m!<a href="http://www.assemblee-nationale.fr/14/tribun/fiches_id/([0-9]+).asp" target="_top">!) {
		$intervenant_id = $1;

		if ($deputes_id->{$intervenant_id}{'nom'}) {
		    $intervenant = encode("utf8", $deputes_id->{$intervenant_id}{'nom'});
		}
	    }
	    my $intervention_type = "";
	    my $intervention_id = "";
	    if ($intervenant =~ /président/) {
		$intervention_type = "régulation";
	    } elsif (m!<a name="(INTER_[0-9]+)"></a>!) {
		$intervention_id = "corresp=\"http://www.assemblee-nationale.fr/14/cri/2012-2013/$official_id#$1\"";
		$intervention_type = "intervention";
		$last_intervenant = $intervenant;
	    } elsif ($last_intervenant eq $intervenant) {
		$intervention_type = "intervention";
	    } else {
		$intervention_type = "interruption";
	    }
	    if ($intervention_type && $intervention_id) {
		if ($deputes_id->{$intervenant_id}{'groupe'}) {
		    $intervention_type =
			encode("utf8", $deputes_id->{$intervenant_id}{'groupe'})
			. " " . $intervention_type ;
		}
	    }
	    clean_entities(\$intervenant);
	    clean_entities(\$intervention);
	    if ($sp_state eq "open") {
		print "\n</sp>\n";
	    } else {
		$sp_state = "open";
	    }
	    print "\n<sp who=\"$intervenant\" n=\"$intervention_type\" $intervention_id>\n";
	    print "  <speaker>$intervenant$titre</speaker>\n";
	    print "  <p>$intervention</p>\n";
	} elsif (m!^<p>(.*?)</p>!) {
	    my $para = encode("utf-8", $1) ;
	    clean_entities(\$para);
	    print "<p>$para</p>\n";
	}

	if (m!<h2 class="(.*?)">(.*?)</h2>!) {
	    if ($sp_state eq "open") {
		print "</sp>\n";
		$sp_state = "closed";
	    }
	    my $div_level = $1 ;
	    my $div_head = encode("utf8", $2) ;
	    clean_entities(\$div_head) ;
	    if ($div_state eq "subpart" or $div_state eq "subsubpart") {
		print "</div>\n";
	    }
	    if ($div_level eq "titre1") {
		$div_state = "subpart";
	    } elsif ($div_level eq "titre3") {
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
	print "</sp>\n";
    }
    if ($div_state eq "subpart") {
	print "</div>\n";
    } elsif ($div_state eq "subsubpart") {
	print "</div>\n</div>\n";
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
<TEI>
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

