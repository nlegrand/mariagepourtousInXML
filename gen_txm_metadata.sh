#!/bin/sh

print_csv () {
    echo \"id\",\"titre\"
    for filename in files/txt/2013*.txt
    do
	echo -n \"$filename\",\"
	sed -e 's/$/"/' -n -e 1p $filename 
    done
}

print_csv > metadata.csv
