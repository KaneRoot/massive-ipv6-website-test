#!/usr/bin/perl -w
use strict;
use warnings;
use v5.14;

die "usage : cat website_list.txt | ./$0 > page.html" if @ARGV != 0;

my @tab;
my %dom;

sub get_urls {
    while(<>) {
        chomp;
        last if $_ eq "";

        if(m#/#) {
            $_ =~ s#https?://##;
            @tab = split '/', $_;
            $_ = $tab[0];
        }

        # securité
        @tab = split ';', $_;
        $_ = $tab[0];
        m/^([0-9a-zA-Z\.-]+)/;
        $_ = $1;

        $dom{$_} = 0;
    }
}

sub test_ipv6 {
    my $domain = shift;

    my $ret = `/usr/bin/dig +short AAAA $domain`;

    if(not length $ret) { # no ipv6 ? check www.$domain
        $ret = `/usr/bin/dig +short AAAA www.$domain`;
    }

    if(length $ret != 0) { # there is at least an IPv6 configured
        chomp $ret;

        my @var = split "\n", $ret;
        for(@var) {
            next unless /:/;

            chomp;
            say; # print the IPv6

            # we try to reach the website's server
            my $retping = 
            `/bin/ping6 -i 0.5 -c 2 $_ | grep ' 0% packet loss'`;
            chomp $retping;

            if(length $retping) {
                $dom{$domain}++;
            }
        }

    }

}

sub check_reachability {

    say '<!-- ';
    for(keys %dom) {
        chomp;
        test_ipv6 $_;
    }
    say '--!>';
}

sub do_html {
    my @passed = grep { $dom{$_} } keys %dom;
    my @notpassed = grep { not $dom{$_} } keys %dom;

    say '<html><head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    </head><body>';
    say "<h1> Domaines accessibles en IPv6 (♥) : </h1>";
    say "<p>", join(', ', @passed), "</p>";

    say "<h1> Mauvais élèves, non accessibles en IPv6 : </h1>";
    say "<p>", join(', ', @notpassed), "</p>";
    say "</body></html>";
}

get_urls;
check_reachability;
do_html;
