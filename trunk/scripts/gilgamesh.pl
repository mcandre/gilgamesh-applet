#!/usr/bin/env perl

# Andrew Pennebaker
#
# Based on Colin Edwards' UAC Bypass
# http://www.recursivepenguin.com/index.php?projectID=3
#

use strict;
use warnings;

use Getopt::Long;

use Error qw(:try);
use YAML qw(LoadFile);
use File::Basename;
use Hash::Merge qw(merge);
use Crypt::SSLeay;
use WWW::Mechanize;
use HTML::TokeParser;

our $DEBUG=0;

our @PORTALS=(
	"https://uac.gmu.edu/dana-na/auth/url_0/welcome.cgi?p=failed",
	"https://uacwireless.gmu.edu/dana-na/auth/url_0/welcome.cgi?p=failed"
);

our $LOGOUT_PATH="/dana-na/auth/logout.cgi";

our $CHECK_URL="http://www.google.com/";
our $CHECK_SUCCESS="Google Search";

# From http://perl.coding-school.com/perl-timeout/
sub gripe {
	throw Error::Simple("Timeout");
}
$SIG{ALRM}=\&gripe;

sub check_online {
	print "Checking online status...\n" if $DEBUG;

	my $settings=shift;

	my $useragent=$settings->{"useragent"};
	my $timeout=$settings->{"timeout"};

	my $success=0;

	try {
		print "Creating robot...\n" if $DEBUG;

		my $agent=WWW::Mechanize->new;

		print "Created.\n" if $DEBUG;

		print "Setting useragent: $useragent\n" if $DEBUG;

		$agent->agent_alias($settings->{"useragent"});

		print "Set.\n" if $DEBUG;

		alarm $settings->{"timeout"};

		print "Timeout started: $timeout\n" if $DEBUG;

		$agent->get($CHECK_URL);

		print "Current URI: " . $agent->uri . "\n" if $DEBUG;

		alarm 0;

		print "Timeout cancelled.\n" if $DEBUG;

		print "Reading response...\n" if $DEBUG;

		$success = $agent->success && $agent->content =~ /$CHECK_SUCCESS/;

		print "Read.\n" if $DEBUG;
	}
	catch Error with {
		print "Error checking online status!\n" if $DEBUG;
	};

	print "Online: $success\n" if $DEBUG;

	return $success;
}

sub login {
	print "Logging in ...\n" if $DEBUG;

	my $settings=shift;
	my $useragent=$settings->{"useragent"};
	my $username=$settings->{"username"};
	my $password=$settings->{"password"};
	my $timeout=$settings->{"timeout"};
	my $logout=$settings->{"logout"};

	print "Username: $username\n" if $DEBUG;
	print "Password: $password\n" if $DEBUG;

	my $success=0;

	foreach my $url (@PORTALS) {
		try {
			print "Portal: $url\n" if $DEBUG;

			print "Creating robot...\n" if $DEBUG;

			my $agent=WWW::Mechanize->new;

			print "Created.\n" if $DEBUG;

			print "Setting useragent: $useragent\n" if $DEBUG;

			$agent->agent_alias($useragent);

			print "Set.\n" if $DEBUG;

			print "Opening portal...\n" if $DEBUG;

			alarm $timeout;

			print "Timeout started: $timeout\n" if $DEBUG;

			$agent->get($url);

			print "Opened portal.\n" if $DEBUG;

			print "Current URI: " . $agent->uri . "\n" if $DEBUG;

			print "Submitting login forms...\n" if $DEBUG;

			$agent->submit_form(form_number=>1, fields=>{username=>$username, password=>$password});

			print "Current URI: " . $agent->uri . "\n" if $DEBUG;

			print "Clicking login button...\n" if $DEBUG;

			$agent->submit_form(form_number=>1);

			print "Current URI: " . $agent->uri . "\n" if $DEBUG;

			print "Form submitted.\n" if $DEBUG;

			if ($logout) {
				print "Logging out...\n" if $DEBUG;

				$agent->get($LOGOUT_PATH);

				print "Current URI: " . $agent->uri . "\n" if $DEBUG;
			}

			alarm 0;

			print "Timeout cancelled.\n" if $DEBUG;
		}
		catch Error with {
			if ($logout) {
				print "Error logging out\n" if $DEBUG;
			}
			else {
				print "Error logging in\n" if $DEBUG;
			}
		};
	}

	if ($logout) {
		$success = not check_online($settings);
	}
	else {
		$success = check_online($settings);
	}

	print "Success: $success\n" if $DEBUG;

	return $success;
}

sub usage {
	print "Usage: $0\n";
	print "\n--conf, -c <file> (default)\n";
	print "--logout, -l Login, then logout.\n";
	print "--embed, -e Embed mode. Requires username and password to be set.\n";
	print "\n--user, -u <username>\n";
	print "--pass, -p <password>\n";
	print "--time, -t <timeout> (secs)\n";
	print "--wait, -w <wait_between_login_attempts> (secs)\n";
	print "--agent, -a <useragent>\n";
	print "\n--debug, -d Debug mode\n";
	print "--help, -h Help\n";

	exit 0;
}

my $config=dirname($0) . "/gilgamesh.yaml";
my $embed=0;
my $username="snapuser";
my $password="snappass";
my $timeout=4;
my $wait=60;
my $useragent="Windows Mozilla";
my $logout=0;
my $help=0;

my $result=GetOptions(
	"conf|c=s" => \$config,
	"embed|e" => \$embed,
	"user|u=s" => \$username,
	"pass|p=s" => \$password,
	"time|t=i" => \$timeout,
	"wait|w=i" => \$wait,
	"agent|a=s" => \$useragent,
	"logout|l" => \$logout,
	"debug|d" => \$DEBUG,
	"help|h" => \$help
);

my $settings={
	"username" => $username,
	"password" => $password,
	"timeout" => $timeout,
	"wait" => $wait,
	"useragent" => $useragent,
	"logout" => $logout
};

my $merged_settings;

# Warning: config file overwrites command line options
if ($embed) {
	$merged_settings = $settings;
}
else {
	try {
		print "Opening config file: $config\n" if $DEBUG;

		open my $f, "<", $config;

		print "Opened.\n" if $DEBUG;

		print "Loading settings...\n" if $DEBUG;

		my $file_settings=LoadFile($f);

		print "Loaded.\n" if $DEBUG;

		print "Closing file...\n" if $DEBUG;

		close $f;

		print "Closed.\n" if $DEBUG;

		# Merge. File settings take precedence.
		$merged_settings = merge($file_settings, $settings);
	}
	catch Error with {}; # silently ignore
}

if ($result == 0 || $help) {
	usage;
}

if ($embed) {
	print "Embed mode.\n" if $DEBUG;

	my $success=login $merged_settings;

	if ($success) {
		if ($logout) {
			print "Exiting with logout success signal.\n" if $DEBUG;

			exit 0;
		}
		else {
			print "Exiting with login success signal.\n" if $DEBUG;

			exit 0;
		}
	}
	else {
		if ($logout) {
			print "Exiting with logout failure signal.\n" if $DEBUG;

			exit 1;
		}
		else {
			print "Exiting with login failure signal.\n" if $DEBUG;
		}
	}
}
elsif ($logout) {
	print "Logging out...\n";

	if (login $merged_settings) {
		print "Logged out.\n";
	}
	else {
		print "Logout failed.\n";
	}

}
else {
	print "Beginning SNAP session...\n";

	# Logout once.

	print "Initial logout...\n" if $DEBUG;

	$merged_settings->{"logout"}=1;
	login $merged_settings;
	$merged_settings->{"logout"}=0;

	# Poll for Internet access every WAIT seconds.
	# If disconnected, login.

	while (1) {
		my $time=localtime;

		if (login $merged_settings) {
			print "Logged in. $time\n";
		}
		else {
			print "Login failed. $time\n";
		}

		print "Waiting " . $merged_settings->{"wait"} . " sec...\n";

		sleep $merged_settings->{"wait"};
	}
}