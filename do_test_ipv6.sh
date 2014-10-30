#!/bin/bash

# get the website list on a pad
URL=http://pad.arn-fai.net/p/website_ipv6_test/export/txt

REP=`dirname $0`

wget -q -O - $URL | perl $REP/get_no_v6_websites.pl > $REP/ipv6.html
