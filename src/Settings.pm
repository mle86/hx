#!/usr/bin/perl
use strict;
use vars qw(
	$do_linesep $str_linesep
);


## Imports and Declarations:  ##################################################

# Line start strings. See Output.pm.
our $linestart;
our $contlinestart;
our $metalinestart;

# Line separator settings. See main.
our $do_linesep;  # pause time (ms)
our $str_linesep;  # separator character


## Constants:  #################################################################

my %ABBREV = (
	pw => 'pausewait',
	ps => 'pausesep',
	px => 'lineprefix',
	lp => 'loglineprefix',
	cp => 'contlineprefix',
	mp => 'metalineprefix',
	48 => 'ecma48',
);


my %DEFAULTS = (
	'loglineprefix'  => "● ",
	'contlineprefix' => "● ",
	'metalineprefix' => "● ",
	'pausewait' => 200,
	'pausesep' => "⁻",
);


## Parse and apply env var:  ###################################################

sub read_settings ($) {
	my %settings = %DEFAULTS;

	while ($_[0] =~ m/\b(?<disable>no)?+(?<option>[a-z0-9]++)(?:=(?<value>[^"\s]*+)|="(?<value>(?:\\.|[^"\\])*+)")?(?:\s|$)/g) {
		my $opt = $ABBREV{ $+{'option'} } // $+{'option'};
		my $setto = ($+{'disable'})
			? ""
			: ($+{'value'} =~ s/\\(.)/$1/gr) // $DEFAULTS{$opt} // 1;

		$settings{ $opt } = $setto;

		if ($opt eq 'lineprefix') {
			$settings{'loglineprefix'}  = $setto;
			$settings{'contlineprefix'} = $setto;
			$settings{'metalineprefix'} = $setto;
		}
	}

	apply_settings(%settings)
}

sub apply_settings (%) {
	my %settings = @_;

	if ($settings{'ecma48'}) { use_ecma48_colors() }

	if (defined $settings{'pausewait'} && defined $settings{'pausesep'} && $settings{'pausewait'} > 0 && $settings{'pausesep'} ne '') {
		$str_linesep = $settings{'pausesep'};
		$do_linesep  = int $settings{'pausewait'};
	}

	if (defined $settings{'loglineprefix'})  { $linestart     = $settings{'loglineprefix'} }
	if (defined $settings{'contlineprefix'}) { $contlinestart = $settings{'contlineprefix'} }
	if (defined $settings{'metalineprefix'}) { $metalinestart = $settings{'metalineprefix'} }
}


1
