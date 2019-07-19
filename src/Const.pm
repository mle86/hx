#!/usr/bin/perl
use strict;


## Log levels:  ################################################################

sub L_LOW     () { 10 }
sub L_WARNING () { 20 }
sub L_ERROR   () { 30 }


## HTTP status maps:  ##########################################################

my %http_success        = map{$_=>1} (200 .. 299);
my %http_redir          = map{$_=>1} (300 .. 399, 100 .. 199);
my %http_client_error   = map{$_=>1} (400, 404, 405, 407, 408, 410, 411, 413, 414, 415, 429, 431);
my %http_client_failure = map{$_=>1} (401, 402, 403, 406, 409, 412, 416, 417, 420, 421, 422, 423, 424, 426, 428, 451);
my %http_server_error   = map{$_=>1} (500 .. 599);

sub is_http_client_error   ($) { exists $http_client_error{$_[0]} }
sub is_http_client_failure ($) { exists $http_client_failure{$_[0]} }
sub is_http_server_error   ($) { exists $http_server_error{$_[0]} }
sub is_http_success        ($) { exists $http_success{$_[0]} }
sub is_http_redir          ($) { exists $http_redir{$_[0]} }


1
