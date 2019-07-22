#!/usr/bin/perl
use strict;
use vars qw(
	$c_bold $c_unbold
	$c_faint $c_unfaint
	$c0
	$c_sym $c_contsym $c_meta $c_followsep
	$c_rpt
	$c_date $c_host $c_app
	$c_loglevel $c_loglevel_warn $c_loglevel_err
	$c_info $c_info_prefix
	$c_trace $c_stack $c_stack_msg
	$c_exception_fqcn $c_exception_scn $c_exception_code
	$c_message
	$c_http_info $c_http_success $c_http_redir $c_http_client_error $c_http_client_failure $c_http_server_error
);


## Base constants:  ############################################################

our $c_bold   = '[1m';
our $c_unbold = '[22m';

our $c_faint   = '[2m';
our $c_unfaint = '[22m';

our $c0 = '[0m';



## Color constants:  ###########################################################

# Base color configuration:
our $c_sym = '[33m';
our $c_contsym = '[38;2;113;97;25m';
our $c_meta = '[38;2;114;204;204m';
our $c_followsep = '[32m'.$c_faint;
our $c_rpt = '[34m';

# Detailed color configuration:
our $c_date = $c_sym;
our $c_host = $c_sym;
our $c_app = $c_sym;
our $c_message = $c0;
our $c_loglevel = $c_sym;
our $c_loglevel_warn = '[38;5;220m';
our $c_loglevel_err = '[38;2;255;145;36m';
our $c_info = '[38;5;243m';
our $c_info_prefix = '[38;2;125;117;83m';
our $c_trace = $c_info;
our $c_stack = $c_info;
our $c_stack_msg = $c0;
our $c_exception_fqcn = $c_message;
our $c_exception_scn  = $c_bold;
our $c_exception_code = $c_bold;

our $c_http_success        = '[38;2;98;214;113m';
our $c_http_redir          = '[38;2;202;214;98m';
our $c_http_client_error   = '[38;2;155;72;72m';
our $c_http_client_failure = '[38;2;235;41;41m';
our $c_http_server_error   = '[38;5;199;1m';
our $c_http_info           = $c_http_redir;


## Other presets:  #############################################################

sub use_ecma48_colors () {
	$c_contsym       = $c_sym . $c_faint;
	$c_meta          = '[36m';
	$c_loglevel_warn = $c_sym . $c_bold;
	$c_loglevel_err  = $c_sym . $c_bold;
	$c_info          = '[37m' . $c_faint;
	$c_info_prefix   = $c_info;

	$c_http_success        = '[32m';
	$c_http_redir          = '[33m';
	$c_http_client_error   = '[31m';
	$c_http_client_failure = $c_http_client_error . $c_bold;
	$c_http_server_error   = $c_http_client_failure;
	$c_http_info           = $c_http_redir;
}


1
