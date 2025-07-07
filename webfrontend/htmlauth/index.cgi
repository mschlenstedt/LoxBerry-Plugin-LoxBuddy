#!/usr/bin/perl

# Copyright 2023 Michael Schlenstedt, michael@loxberry.de
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


##########################################################################
# Modules
##########################################################################

# use Config::Simple '-strict';
# use CGI::Carp qw(fatalsToBrowser);
use CGI;
use LoxBerry::System;
#use LoxBerry::IO;
use LoxBerry::JSON;
use LoxBerry::Log;
use warnings;
use strict;
#use Data::Dumper;

##########################################################################
# Variables
##########################################################################

my $log;

# Read Form
my $cgi = CGI->new;
my $q = $cgi->Vars;

my $version = LoxBerry::System::pluginversion();
my $template;

# Language Phrases
my %L;

##########################################################################
# AJAX
##########################################################################

if( $q->{ajax} ) {
	
	## Logging for ajax requests
	$log = LoxBerry::Log->new (
		name => 'AJAX',
		filename => "$lbplogdir/ajax.log",
		stderr => 1,
		loglevel => 7,
		addtime => 1,
		append => 1,
		nosession => 1,
	);
	
	LOGSTART "P$$ Ajax call: $q->{ajax}";
	
	## Handle all ajax requests 
	my %response;
	ajax_header();

	# Add Icons
	if( $q->{ajax} eq "add" ) {
		$response{error} = &add();
		print JSON->new->canonical(1)->encode(\%response);
	}

	# Remove Icons
	if( $q->{ajax} eq "remove" ) {
		$response{error} = &remove();
		print JSON->new->canonical(1)->encode(\%response);
	}

	# Create Lib
	if( $q->{ajax} eq "create" ) {
		$response{error} = &create();
		print JSON->new->canonical(1)->encode(\%response);
	}

	# UploadLib
	if( $q->{ajax} eq "upload" ) {
		$response{error} = &upload();
		print JSON->new->canonical(1)->encode(\%response);
	}

	exit;

##########################################################################
# Normal request (not AJAX)
##########################################################################

} else {
	
	require LoxBerry::Web;
	
	# Init Template
	$template = HTML::Template->new(
	    filename => "$lbptemplatedir/settings.html",
	    global_vars => 1,
	    loop_context_vars => 1,
	    die_on_bad_params => 0,
	);
	%L = LoxBerry::System::readlanguage($template, "language.ini");
	
	# Default is Loxiconform
	$q->{form} = "loxicon" if !$q->{form};

	if ($q->{form} eq "loxicon") { &form_loxicon() }
	elsif ($q->{form} eq "download") { &form_download() }
	elsif ($q->{form} eq "log") { &form_log() }

	# Print the form
	&form_print();
}

exit;


##########################################################################
# Form: LOXICON
##########################################################################

sub form_loxicon
{
	$template->param("FORM_LOXICON", 1);
	return();
}


##########################################################################
# Form: DOWNLOAD
##########################################################################

sub form_download
{
	$template->param("FORM_DOWNLOAD", 1);
	return();
}


##########################################################################
# Form: Log
##########################################################################

sub form_log
{
	$template->param("FORM_LOG", 1);
	$template->param("LOGLIST", LoxBerry::Web::loglist_html());
	return();
}

##########################################################################
# Print Form
##########################################################################

sub form_print
{
	# Navbar
	our %navbar;

	$navbar{10}{Name} = "$L{'COMMON.LABEL_LOXICON'}";
	$navbar{10}{URL} = 'index.cgi?form=loxicon';
	$navbar{10}{active} = 1 if $q->{form} eq "loxicon";
	
	$navbar{30}{Name} = "$L{'COMMON.LABEL_DOWNLOAD'}";
	$navbar{30}{URL} = 'index.cgi?form=download';
	$navbar{30}{active} = 1 if $q->{form} eq "download";

	$navbar{99}{Name} = "$L{'COMMON.LABEL_LOG'}";
	$navbar{99}{URL} = 'index.cgi?form=log';
	$navbar{99}{active} = 1 if $q->{form} eq "log";
	
	$template->param("HTMLPATH", "http://loxberrykeller/admin/plugins/loxoneicons");
	# Template
	LoxBerry::Web::lbheader($L{'COMMON.LABEL_PLUGINTITLE'} . " V$version", "https://wiki.loxberry.de/plugins/loxoneicons/start", "");
	print $template->output();
	LoxBerry::Web::lbfooter();
	
	exit;

}


######################################################################
# AJAX functions
######################################################################

sub ajax_header
{
	print $cgi->header(
			-type => 'application/json',
			-charset => 'utf-8',
			-status => '200 OK',
	);	
}


sub add
{

	# Add Icons
	my $errors;
	system("$lbpbindir/add_icons.sh >/dev/null 2>&1");
	if ($?) {
		$errors++;
	}
	return ($errors);

}

sub remove
{

	# Remove Icons
	my $errors;
	system("$lbpbindir/remove_icons.sh >/dev/null 2>&1");
	if ($?) {
		$errors++;
	}
	return ($errors);

}

sub create
{

	# Create Lib
	my $errors;
	system("$lbpbindir/create_iconlib.sh 1 >/dev/null 2>&1");
	if ($?) {
		$errors++;
	}
	return ($errors);

}

sub upload
{

	# Upload Lib
	my $errors;
	system("$lbpbindir/upload_iconlib.sh 1 >/dev/null 2>&1");
	if ($?) {
		$errors++;
	}
	return ($errors);

}

END {
	if($log) {
		LOGEND;
	}
}

