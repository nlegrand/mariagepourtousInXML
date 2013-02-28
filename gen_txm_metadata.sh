#!/bin/sh

echo \"id\",\"titre\"
cd TXM-TXT-CVS
for filename in *.txt
do
    echo -n \"$filename\",\"
    sed -e 's/$/"/' -n -e 1p $filename 
done