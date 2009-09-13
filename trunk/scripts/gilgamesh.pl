#!/usr/bin/env perl

# Andrew Pennebaker
#
# Based on Colin Edwards' UAC Bypass
# http://www.recursivepenguin.com/index.php?projectID=3
#
# Usage: ./gilgamesh.pl or ./gilgamesh.pl -n <options>

use strict;
use warnings;

use Error qw(:try);
use YAML qw(LoadFile);
use File::Basename;
use Crypt::SSLeay;
use WWW::Mechanize;
use HTML::TokeParser;

# From http://perl.coding-school.com/perl-timeout/
sub gripe {
	throw Error::Simple("Timeout");
}
$SIG{ALRM}=\&gripe;

sub login {
	my $settings=shift;

	my $agent=WWW::Mechanize->new;
	$agent->agent_alias($settings->{"useragent"});

	try {
		$settings->{"connection"}="wireless";

		alarm $settings->{"timeout"};
		$agent->get($settings->{"url_wireless"});
		alarm 0;
	}
	catch Error with {
		alarm 0;

		$agent=WWW::Mechanize->new;
		$agent->agent_alias($settings->{"useragent"});

		try {
			$settings->{"connection"}="wired";

			alarm $settings->{"timeout"};
			$agent->get($settings->{"url"});
			alarm 0;
		}
		catch Error with {
			alarm 0;
		};
	};

	if ($agent->success) {
		$agent->submit_form(form_number=>1, fields=>{username=>$settings->{"username"}, password=>$settings->{"password"}});
		$agent->submit_form(form_number=>1);

		if ($settings->{"connection"} eq "wireless") {
			return $agent->success && $agent->content =~ /$settings->{"success_wireless"}/;
		}
		else {
			return $agent->success && $agent->content =~ /$settings->{"success"}/;
		}
	}

	return 0;
}

my $settings={};

# -n for no yaml config
if (@ARGV>0 && $ARGV[0] eq "-n") {
	$settings={
		"url" => $ARGV[1],
		"url_wireless" => $ARGV[2],
		"useragent" => $ARGV[3],
		"success" => $ARGV[4],
		"success_wireless" => $ARGV[5],
		"timeout" => $ARGV[6],
		"username" => $ARGV[7],
		"password" => $ARGV[8]
	};

	if (login($settings)) {
		exit(0);
	}
	else {
		exit(1);
	}
}
else {
	try {
		open my $f, "<", dirname($0)."/gilgamesh.yaml";
		$settings=LoadFile($f);
		$settings->{"no-config"}=0;
		close $f;
	}
	catch Error with {
		die("Error reading gilgamesh.yaml\n");
	};

	while(1) {
		my $time=localtime;

		if (login($settings)) {
			print("Login   $time\n");
		}
		else {
			print("Failure $time\n");
		}

		sleep $settings->{"wait"};
	}
}