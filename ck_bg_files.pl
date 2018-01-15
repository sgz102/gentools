#!/usr/bin/perl

use strict;
use Getopt::Long;
use Cwd 'abs_path';
use File::Basename;

my $help = '';
my $usage = '';
our $in_my_tty = '';
my $VERSION = "1.2";


## Get the name of the configuration file by
#  1. Get the full path to the executing script
#  2. remove the executable extension "pl" and replace with "config"

## The following does not honor the symlink to the executable for this script
#my $script_path_full = abs_path($0);

## so, I'm using this because it's the actual argument on the command line...
my $script_path_full = $0;

my @suffixlist = qw/.pl/;


my ($scriptname,$scriptpath,$suffix) = fileparse($script_path_full,@suffixlist);
#my $scriptname = fileparse($script_path,@suffixlist);
my $config_file = "$scriptpath$scriptname.config";
my $exceptions_ref = check_config($config_file);


## http://unixhelp.ed.ac.uk/CGI/man-cgi?ps
## PROCESS STATE CODES

## Get the tty of the current terminal we are in
my $mytty_info = `tty`;
my @info = split("/",$mytty_info);
our $mytty = $info[$#info];
chomp($mytty);
my $version = '';
GetOptions(t=>\$in_my_tty,
		u=>\$usage,
		h=>\$help,
		v=>\$version);

if ($usage || $help){
	print_usage();
}

if ($version){
	print "$script_path_full -- VERSION $VERSION--\n";
	exit(0);
}


#my $myuser=`whoami`;
my $myusername=`whoami`;
chomp($myusername);
my $myuserid=`id -u $myusername`;
chomp($myuserid);




## Columns:
##  1: USER
##  2: PID
##  3: %CPU
##  4: %MEM
##  5: VSZ
##  6: RSS
##  7: TTY
##  8: STAT
##  9: START
## 10: TIME
## 11: COMMAND

my @arr = `ps aux | awk '{\$3=\$4=\$5=\$6=\$9=\$10=""; print \$0'}`;
my ($foreground_ref,$background_ref) = get_process_info(\@arr);
print_processes($foreground_ref,$background_ref);


###############################################################
sub get_process_info{
###############################################################
	my ($info_ref) = @_;
	my @foreground = ();
	my @background = ();

	foreach my $elem (@$info_ref){
		chomp($elem);
		my @arr = split(" ",$elem);
		my $user=shift(@arr);
		$user =~ s/ //g;
		my $pid = shift(@arr);
		$pid =~ s/ //g;
		my $tty = shift(@arr);
		$tty =~ s/ //g;
		my @tty_arr = split("/",$tty);
		my $tty_num = $tty_arr[$#tty_arr];

		my $type = shift(@arr);
		$type =~ s/ //g;
		my $proc = sprintf '%s ' x @arr, @arr;

		if ($user eq $myusername || $user eq $myuserid){
			if (($type eq "S") || ($type eq "T")){ ## S (alone) means it's in the background)
#			if (($type eq "S") || ($type =~ /T/)){ ## S (alone) means it's in the background)
	my @matches = ();
	## check to see if the process is one of the exceptions
	@matches = grep (/$arr[0]/,@$exceptions_ref);
	my $num_matches = scalar(@matches);
	if ($num_matches < 1){

		if ($in_my_tty){
			if ($tty_num eq $mytty){
				my $what_to_print = "   $proc  (PID = $pid)  (TTY = $tty)\n";

				push(@background,$what_to_print);
			}
		}else{
			my $what_to_print = "   $proc  (PID = $pid)  (TTY = $tty)\n";

			push(@background,$what_to_print);
		}

	}
}elsif (($type eq "S+")){ ## Process in the foreground
	my @matches = ();
	@matches = grep (/$arr[0]/,@$exceptions_ref);
	my $num_matches = scalar(@matches);
	if ($num_matches < 1){
		if ($in_my_tty){
			if ($tty_num eq $mytty){
				my $what_to_print = "   $proc  (PID = $pid)  (TTY = $tty)\n";
				push(@foreground,$what_to_print); 
			}
		}else{
			my $what_to_print = "   $proc  (PID = $pid)  (TTY = $tty)\n";
			push(@foreground,$what_to_print); 
		}
	}
}
}
} 
return (\@foreground,\@background);
}


###############################################################
sub print_processes{
###############################################################

	my ($foreground_ref,$background_ref)= @_;
	print "\n*********************************************************************\n";
	print "Processes in Interruptible sleep or stopped by a job control signal\n";
	print "*********************************************************************\n\n";

	print "Background processes\n";
	foreach my $elem (@$background_ref){
		chomp($elem);
		print "$elem\n";
	}

	print "\n\n";
	print "Foreground Processes\n";
	foreach my $elem (@$foreground_ref){
		chomp($elem);
		print "$elem\n";
	}

	print "\n";

}


###############################################################
sub print_usage{
###############################################################
	print "syntax: $0 <options>\n";
	print "   where options are -t to show only processes in this terminal\n";
	exit(1);


}

###############################################################
sub check_config{
###############################################################
#
	my ($config_file) = @_;
	my @exceptions = ();

	if (! -e $config_file){
		die "Error! Cannot open configuration file $config_file!\n";
	}
	if (-z $config_file){
		print "Warning! Configuration file $config_file is empty.  No parameters will be read in!\n";
	}

	open (CONFIG, $config_file);
	while (<CONFIG>) {
		chomp;              # no newline
			push (@exceptions,$_);
	}
	close (CONFIG);

	return (\@exceptions);
}

