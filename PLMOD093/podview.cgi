#!/usr/bin/perl

use strict;

####################################################
# Configuration:
####################################################

# add any site specific library directories to @libs

my @libs = (
   '/data/lib/perl',
);

my @dev_libs = (
   '/data/projects/perlmod',
);

####################################################


use Cwd;
use Pod::Html;
use Config;

push @libs, $Config{'privlib'};
push @libs, $Config{'sitelib'};
my $pod_root = $Config{'privlib'};

my $pod = $ENV{PATH_INFO};
$pod =~ s/\.html(\#.*)?$//;
$pod =~ tr!a-zA-Z0-9_/!!cd;

my $tempdir = $ENV{TMP} || $ENV{TEMP};


my $self_url = $ENV{REQUEST_URI};
$self_url =~ s/$ENV{PATH_INFO}$//;

my @args = (
   "--htmlroot=$self_url",
   "--libpods=pod",
   "--podroot=$pod_root",
   "--podpath=pod",
);

my $cwd = getcwd;

chdir $tempdir;

print "Content-Type: text/html\n\n";

my $found = 0;

unless ($found) {
    foreach my $lib (@dev_libs) {
        my $dev_pod = $pod;
        my $name = $1 if $dev_pod =~ m{/([^/]*)$};
        foreach my $file ("$lib/$dev_pod/$name.pod", "$lib/$dev_pod/$name.pm", "$lib/pod/$dev_pod/$name.pod") {

            print STDERR "searching: $file\n";
            if (-f $file) {
                print STDERR "Found: $file\n";
                pod2html (
                    "--infile=$file",
                    @args,
                );
                $found = 1;
                last;
            }
        }
    }
}

unless ($found) {
    foreach my $lib (@libs) {
        foreach my $file ("$lib/$pod.pod", "$lib/$pod.pm", "$lib/pod/$pod.pod") {
            if (-f $file) {
                print STDERR "Found: $file\n";
                pod2html (
                    "--infile=$file",
                    @args,
                );
                $found = 1;
                last;
            }
        }
    }
}


print_error("not found: $pod") unless $found;

chdir $cwd;

sub print_error {
    my ($error) = @_;
    print <<EOF;
    <html>
    <head>
    <title>Error displaying POD
    </title>
    </head>
    <body>
    <h1>Could not display the Pod file:</h1>
    $error
    </body>
    </html>
EOF
}


