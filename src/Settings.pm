#!/usr/bin/perl
use strict;
use vars qw(
	$do_linesep
);


## Imports and Declarations:  ##################################################

# Line start strings. See Output.pm.
our $linestart;
our $contlinestart;
our $metalinestart;

# Line separator pause time (ms). See main.
our $do_linesep;


## Constants:  #################################################################

my %DEFAULTS = (
	'loglineprefix'  => "● ",
	'contlineprefix' => "● ",
	'metalineprefix' => "● ",
	'pausesep' => 200,
);


## Apply defaults:  ############################################################

sub read_settings ($) {
	my %settings = %DEFAULTS;
	apply_settings(%settings)
}

sub apply_settings (%) {
	my %settings = @_;

	if (defined $settings{'pausesep'} && $settings{'pausesep'} > 0) { $do_linesep = int $settings{'pausesep'} }

	if (defined $settings{'loglineprefix'})  { $linestart     = $settings{'loglineprefix'} }
	if (defined $settings{'contlineprefix'}) { $contlinestart = $settings{'contlineprefix'} }
	if (defined $settings{'metalineprefix'}) { $metalinestart = $settings{'metalineprefix'} }
}


1
