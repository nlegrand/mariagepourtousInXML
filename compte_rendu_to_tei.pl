#!/usr/bin/perl

use strict ;
use warnings ;
use Encode;

sub clean_entities {
    my $string = shift @_ ;
    $$string =~ s/<(:?a|b).*?>//g;
    $$string =~ s!</(:?a|b)>!!g;
    $$string =~ s/<!--.*?-->//g;
    $$string =~ s/&nbsp;/ /g;
    $$string =~ s/&#8217;/'/g;

}

sub print_body {
    print "<text>";
    print "<body>";
    while (<>) {
	if (m!^<p>.*?<b>(.*)</b>(.*)</p>!) {
	    my $intervenant = encode("utf8", $1) ;
	    my $intervention = encode("utf8", $2) ;
	    clean_entities(\$intervenant);
	    clean_entities(\$intervention);
	    print "<sp>\n";
	    print "  <speaker>$intervenant</speaker>\n";
	    print "  <p>$intervention</p>\n";
	    print "</sp>\n";
	}
    }
    print "</body>";
    print "</text>";
}

sub print_xml {
    my ($title, $editiondate, $date, $director) = @_;
    print <<"TEIHEADER";
<?xml version="1.0" encoding="UTF-8"?>
<TEI>
   <teiHeader>
      <fileDesc>
         <titleStmt>
            <title>$title</title>
            <author>Assemblée nationale</author>
            <respStmt>
               <resp>>Le Directeur du service du compte rendu de la séance</resp>
               <name>$director</name>
            </respStmt>
         </titleStmt>
         <editionStmt>
            <edition> <date>$date</date> </edition>
         </editionStmt>
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

    print_body();

    print "</TEI>";
}

print_xml("mariage pour tous","Aujourd'hui","Maintenant","un mec");
