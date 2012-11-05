package Dancer::Plugin::Log::DB;


=head1 NAME
Dancer::Plugin::Log::DB - log arbitrary messages into a database
=cut

use 5.006;
use strict;
use warnings;

use Carp;
use List::Util 'first';
use Time::Piece;

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
	port => '3306',
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

	my $message_field_name = $settings->{log}->{message_field_name} || 'message';
	my $timestamp_field_name = $settings->{log}->{timestamp_field_name} || 'timestamp';

	my $additional_fields = $settings->{log}->{additional_fields};

	my (@fields, @bind);

	my $message = $params->{message} || return;
	my $timestamp = $params->{timestamp} ? localtime($params->{timestamp}) : localtime;
	
	push @fields, $message_field_name;
	push @fields, $timestamp_field_name;
	push @bind, $message;
	push @bind, sprintf("%s %s", $timestamp->ymd, $timestamp->hms);
	
	# Handle additional field values
	delete $params->{message};
	delete $params->{timestamp};
	
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
