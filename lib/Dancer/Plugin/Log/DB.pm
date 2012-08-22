package Dancer::Plugin::Log::DB;

use 5.006;
use strict;
use warnings;

use Data::Dumper;
use Carp;

use List::Util 'first';

use Dancer::Plugin;
use Dancer::Config;
use Dancer::Plugin::Database;

our $VERSION = '0.01';

our $settings = undef;
our $dbh;

my %db_defaults = (
	driver => 'SQLite',
	database => 'test',
	username => 'myusername',
	password => 'password',
	host => 'localhost',
	port => '3106',
);

sub _setup_connection {
	$settings = plugin_setting() if !$settings;
	return unless $settings;
	
	my %connection_params;
	
	for (qw/driver database username password host port/) {
		$connection_params{$_} = $settings->{database}{$_} || $db_defaults{$_};
	}
	
	$dbh = database(\%connection_params);
}

register log_db_dbh => sub {
	$dbh = _setup_connection() unless $dbh;
	return $dbh;
};

register log_db => sub {
	my $params = shift;

	_setup_connection();
	# die "Can't get database handle" unless $dbh;

	my $message_field_name = $settings->{log}->{message_field_name} || 'message';
	my $timestamp_field_name = $settings->{log}->{timestamp_field_name} || 'timestamp';

	my $additional_fields = $settings->{log}->{additional_fields};

	my (@fields, @bind);

	# Handle 'message' and 'timestamp' field values
	my $message = $params->{$message_field_name} || return;
	my $timestamp = $params->{$timestamp_field_name} || time;
	
	push @fields, $message_field_name;
	push @fields, $timestamp_field_name;
	push @bind, $message;
	push @bind, $timestamp;
	
	# Handle additional field values
	delete $params->{$message_field_name};
	delete $params->{$timestamp_field_name};
	
	if (scalar %$params) {
		while (my ($key, $value) = each %$params) {
			unless (first { $_ eq $key } @$additional_fields) {
				Dancer::Logger::error("Non-described field: $key. Add it to 'additional_fields'");
				return;
			}

			push @fields, $key;
			push @bind, $value;
		}		
	}
		
	my $placeholders = join ",", map { "?" } @fields;
	my $query = "INSERT INTO logs (" . join (",", @fields) . ") VALUES($placeholders)";

	my $sth = $dbh->prepare($query);

	$sth->execute(@bind);
};

register_plugin;

1; # End of Dancer::Plugin::Log::DB
