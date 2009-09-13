#!/usr/bin/env perl -w

# Andrew Pennebaker
#
# Based on Colin Edwards' UAC Bypass
# http://www.recursivepenguin.com/index.php?projectID=3
#
# KOPIMI

use Error qw(:try);
use Crypt::SSLeay;
use WWW::Mechanize;
use HTML::TokeParser;

use strict;

my ($url, $useragent, $success, $timeout, $username, $password)=@ARGV;

# From http://perl.coding-school.com/perl-timeout/
sub gripe {
	throw Error::Simple("Timeout");
}
$SIG{ALRM}=\&gripe;

sub login {
	my ($url, $ua, $s, $u, $p)=@_;

	try {
		my $agent=WWW::Mechanize->new;
		$agent->agent_alias($ua);

		alarm $timeout;
		$agent->get($url);
		alarm 0;

		$agent->submit_form(form_number=>1, fields=>{username=>$u, password=>$p});
		$agent->submit_form(form_number=>1);

		return $agent->success && $agent->content =~ /$s/;
	}
	catch Error with {
		return 0;
	};
}

if (login($url, $useragent, $success, $username, $password)) {
	exit 0;
}
else {
	exit -1;
}
