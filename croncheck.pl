#!/usr/bin/perl

## Run to see what cron jobs are currently executing

use strict;
use Term::Cap;
use POSIX;

my ($norm, $bold, $under) = define_char_format();


my @proc_info = ();
my @output = ();
@proc_info = `ps -o pid,sess,cmd afx`;

#my $line = sprintf("%04d %8s %5s %02d:%02d %s",$pid,$tty,$stat,$time,$command);

for (my $i=0;$i<scalar(@proc_info);$i++){
   chomp($proc_info[$i]);
#   if ($proc_info[$i] =~ /^(.{5})\s+(.{5})\s+\\_\s+(.+)/){
#      print "PATTERN A: 1: $1 2: $2 3: $3\n";
#   }elsif ($proc_info[$i] =~ /^(.{5})\s+(.{5})\s+\|\s+(.+)/){
#      print "PATTERN B: 1: $1 2: $2 3: $3\n";
#}

   if ($proc_info[$i] =~ /CROND/){  ## Found a cron running.  Start parsing next line
        $i++;
      print "${bold}$proc_info[$i]$norm";  ## print parent task in bold
         my @arr = split(" ",$proc_info[$i+1]);
      while (($arr[2] !~ /^\//) && ($proc_info[$i+1] !~ /CROND/)){ 
         $i++;
      print "$proc_info[$i]";
      @arr = split(" ",$proc_info[$i]);
   }
    print "\n";
   }



}



sub define_char_format{

   my $termios = new POSIX::Termios; $termios->getattr;
   my $ospeed = $termios->getospeed;
   my $t = Tgetent Term::Cap { TERM => undef, OSPEED => $ospeed };
   my ($norm, $bold, $under) = map { $t->Tputs($_,1) } qw/me md us/;


   return ($norm,$bold,$under);
}

