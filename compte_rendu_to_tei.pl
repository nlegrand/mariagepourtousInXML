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

sub clean_entities {
    my $string = shift @_ ;
    $$string =~ s/<(:?a|b|i|font).*?>//g;
    $$string =~ s!</(:?a|b|i|font)>!!g;
    $$string =~ s/<!--.*?-->//g;
    $$string =~ s/&nbsp;/ /g;
    $$string =~ s/&#8217;/'/g;
    $$string =~ s/&#339;/œ/g;
    $$string =~ s/&#8230;/.../g;
    $$string =~ s/&#8211;/-/g;
}

sub print_body {
    my $aspfilename = shift @_;
    my $state = "main"; #main, subpart, subsubpart
    print "<text>\n";
    print "<body>\n";
    open my $aspfh, "<", $aspfilename
	or die "can't open $aspfilename : $!" ;
    while (<$aspfh>) {
	if (m!^<p>.*?<b>(.*?)(?:,){0,1}</b>(?:<i>(.*?)</i>.){0,1}(.*)</p>!) {
	    my $intervenant = encode("utf8", $1) ;
	    my $titre = encode("utf8", $2) || "";
	    if ($titre) {
		clean_entities(\$titre);
		$titre = "," . $titre ;
	    }
	    my $intervention = encode("utf8", $3) ;
	    clean_entities(\$intervenant);
	    clean_entities(\$intervention);
	    print "\n<sp>\n";
	    print "  <speaker>$intervenant$titre</speaker>\n";
	    print "  <p>$intervention</p>\n";
	    print "</sp>\n";
	}   elsif (m!^<p>(.*?)</p>!) {
	    my $para = encode("utf-8", $1) ;
	    clean_entities(\$para);
	    print "<p>$para</p>\n";
	}

	if (m!<h2 class="(.*?)">(.*?)</h2>!) {
	    my $div_level = $1 ;
	    my $div_head = encode("utf8", $2) ;
	    clean_entities(\$div_head) ;
	    if ($state eq "subpart" or $state eq "subsubpart") {
		print "</div>\n";
	    }
	    if ($div_level eq "titre1") {
		$state = "subpart";
	    } elsif ($div_level eq "titre3") {
		$state = "subsubpart";
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
    if ($state eq "subpart") {
	print "</div>\n";
    } elsif ($state eq "subsubpart") {
	print "</div>\n</div>\n";
    }
    close $aspfh;
    print "</body>\n";
    print "</text>\n";
}

sub print_xml {
    my ($aspfilename, $title, $editiondate, $date, $director) = @_;

    open my $aspfh, "<", $aspfilename
	or die "can't open $aspfilename : $!" ;

    while(<$aspfh>) {
	$_ = encode("utf8", $_);
	clean_entities(\$_);
	if(m!<h1 class="seance">(.*2013)</h1>!) {
	    $title = "Mariage pour tous - " . $1 ;
	    $title =~ /séance du (.*2013)/;
	    $date = $1;
	}
	if(m!<div id="signature"><p align="center">(.*?)</p>!) {
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

    print_body($aspfilename);

    print "</TEI>\n";
}

my $aspfilename =  $ARGV[0];

print_xml($aspfilename, "mariage pour tous","Aujourd'hui","Maintenant","un mec");
