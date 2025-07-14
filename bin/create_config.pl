#!/usr/bin/perl

use LoxBerry::System;
use LoxBerry::IO;
use LoxBerry::Log;
use LoxBerry::JSON;
use Getopt::Long;
#use warnings;
#use strict;
#use Data::Dumper;

# Version of this script
my $version = "0.1.0";

# Globals
my $error;
my $verbose;
my $action;

# Logging
my $log = LoxBerry::Log->new (  name => "create_config",
	package => 'loxbuddy',
	logdir => "$lbplogdir",
	addtime => 1,
);

# Commandline options
GetOptions ('verbose=s' => \$verbose,
            'ms=s' => \$ms);

# Verbose
if ($verbose) {
        $log->stdout(1);
        $log->loglevel(7);
}

# Language File
#my %L = LoxBerry::System::readlanguage("language.ini");

LOGSTART "Starting create_config";

# Check for MS
if ( $ms eq "" ) {
	LOGINF "No Miniserver specified. Unsing No. 1";
	$ms = "1";
}
my %miniservers = LoxBerry::System::get_miniservers();
if (! %miniservers{$ms}) {
	LOGCRIT "Miniserver No. $ms does not exist.";
	exit(1);
}

# Check for Lox2MQTT Plugin
my $l2m = LoxBerry::System::plugindata("lox2mqtt");
if (! $l2m->{PLUGINDB_FOLDER}) {
	LOGCRIT "Cannot find Lox2MQTT Plugin. Is it installed?";
	exit(1);
}

# Read Lox2MQTT Config
my $cfgfile = $lbhomedir . "/config/plugins/" . $l2m->{PLUGINDB_FOLDER} . "/default.json";
$jsonobj = LoxBerry::JSON->new();
$cfgl2m = $jsonobj->open(filename => $cfgfile);
LOGINF "Found Lox2MQTT Topic: " . $cfgl2m->{"miniserver"}->{$ms}->{"mqtt_topic_ms"}; 

# Read MQTT connection
my $mqtt = LoxBerry::IO::mqtt_connectiondetails();
if (! $mqtt->{brokerhost} || ! $mqtt->{websocketport} || ! $mqtt->{brokeruser} || ! $mqtt->{brokerpass}) {
	LOGCRIT "Cannot read MQTT config or some data is missing.";
	exit(1);
}
if ( $mqtt->{brokerhost} eq "localhost" || $mqtt->{brokerhost} eq "127.0.0.1" ) {
	$mqtt->{brokerhost} = LoxBerry::System::get_localip();
}
LOGINF "Found MQTT Config: " . "Host:" . $mqtt->{brokerhost} . " Websocket:" . $mqtt->{websocketport} . " User:" . $mqtt->{brokeruser} . " Pass:*******";

# Write Config if any changes
my $content = "";
my $string = "MQTT_HOSTNAME=" . $mqtt->{brokerhost} . "\nMQTT_PORT=" . $mqtt->{websocketport} . "\nMQTT_USERNAME=" . $mqtt->{brokeruser} . "\nMQTT_PASSWORD=" . $mqtt->{brokerpass} . "\nMQTT_TOPIC=" . $cfgl2m->{"miniserver"}->{$ms}->{"mqtt_topic_ms"};
if ( -e $lbpbindir . "/loxbuddy/.env.local" ) {
	$content = LoxBerry::System::read_file($lbpbindir . "/loxbuddy/.env.local");
}
if ( $string ne $content ) {
	LOGINF "Settings changed - writing new config";
	my $response = LoxBerry::System::write_file($lbpbindir . "/loxbuddy/.env.local", $string);
	if( $response ) {
		LOGCRIT "Cannot write config: $response"; 
		exit (1);
	}
	LOGOK "Config was written successfully.";
} else {
	LOGINF "Settings haven't changed. No config was written.";
}

# All went fine
exit (0);
