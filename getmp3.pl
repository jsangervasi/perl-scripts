#!/usr/bin/perl -w
##################################################################
##################################################################
#     DOWNLOADS LIST OF MP3'S FROM A GOOGLE SEARCH
#     EXAMPLE SEARCH: "index of" mp3 <artist> <album>
#     EXAMPLE URL: perl getmp3.pl http://notfound.land/zik/Nirvana/MTV%20_%20Unplugged%20In%20New%20York/ Nirvana-MTV
#     Author Joe Sangervasi <jsangervasi at gmail dot com>
#     Modified 7/27/2017 
##################################################################
##################################################################
use strict;
package URL::Encode;
use LWP::Simple;
use URL::Encode;
use File::Basename;

my $ext = qw/mp3/;
my $pattern = qr/href="(.*\.mp3)"/;
my $linkPattern = qr/\bhref/;

length($ARGV[0]) > 0 && length($ARGV[1]) > 0 or die("Usage: $0 <http://www.example.com/music> <localstore>\n");
my $url = $ARGV[0];
my $localpath  = $ARGV[1];
my (@lines,@urldecoded,@links,@music,$content);

#create new music directory
if( ! -e $localpath ) {
    mkdir($localpath) or die("Unable to create $localpath\n");
}

#change to music directory
chdir($localpath) or die("Unable to chdir to $localpath\n");
   
#get the page content
$content = get($url);
@lines = split(/\bhref="/i,$content);

#find each mp3 URI amidst the markup
foreach(@lines) {
    if( $_ =~ m/(.*?\.mp3)/i ) {
        my $mp3 = basename($1);
        push(@links,$mp3);
        push(@urldecoded,url_decode($mp3));
    }
}

#print list of songs
print "Found " . scalar(@links) . " mp3's\n";
foreach(@urldecoded) {
    print $_ . "\n";
}
print "Download all? \n";
my $input = <STDIN>;
$input = lc($input);
chomp($input);

#begin download
if( $input eq 'y' or $input eq 'yes') {
    my $key = 0;
    foreach(@links) {
        my $uri = $url . $_;
        print "Attempting to download: $urldecoded[$key]\n";
        print "curl \'" . url_decode($uri) . "\' -o \"" . $urldecoded[$key] . "\"";
        system("curl \'$uri\' -o \"" . $urldecoded[$key] . "\"");
        $key++;
    }
    print "Done.\n";
} else {
    print "Bye~~\n";
    exit;
}
