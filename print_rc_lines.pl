#!/usr/bin/perl
#
use strict;

use Cwd;


my %map_hash=("whomach"=> "who_machine/who_machine.bash",
              "jobbg" => "background_jobs/ck_bg_files.pl",
              "sysinfo" => "sysinfo/ahsysinfo",
              "ztree" => "ztree/ztree.bash");


my $working_dir = cwd();


print "\nAdd the following lines to your .bashrc:\n";

foreach my $key (keys %map_hash){
    print "alias $key=\'$working_dir/$map_hash{$key}\'\n";
}


