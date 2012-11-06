# NAME

Dancer::Plugin::Log::DB - log arbitrary messages into a database from within
your Dancer application.

# VERSION

Version 0.01

# SYNOPSIS

    
            use Dancer;
            use Dancer::Plugin::Log::DB;
    
            get '/' => sub {
                    # Simple usage - timestamp is NOW 
                    log_db { message => 'Simple log message' };
    
                    # Both message and timestamp are set
                    log_db { message => 'Message at certain time', timestamp => 9982481 };
    
                    # Using additional fields for complementary information
                    log_db { message => 'Another simple message', server_id => $my_server_id }; 
            }

Database connection details and plugin settings are read from application
config file - see below on more details.

# DESCRIPTION

Provides an easy way to add arbitrary logging messages into a database for
your Dancer application. Supports more than one common field ('message') to
add bits of information into.

You can add as many fields as you wish in your database table and fill them in
with _log_db_ calls.

Default fields are _message_ and _timestamp_, thus at its simplest case it
requires database table with the following SQL declaration:

  * _id_ field.

Or any name you want - the plugin doesn't care of this field at all.
Autoincrementing for this field would be a good choice.

  * _message_ field.

This is where message will be stored. TEXT/VARCHAR type.

  * _timestamp_ field.

Where timestamp field will be kept. TIMESTAMP/TEXT/VARCHAR type.

You can expand functionality by adding any number of columns and write any
data supported by your database backend.

For example, in complement to existing _timestamp_ and _message_ fields you
can also add _server_id_ column to store server id which left the message.

# CONFIGURATION

**Table to keep logs should be called 'logs' in your database. This is not configurable in this version. I'm really sorry.**

This plugin makes use of great _Dancer::Plugin::Database_ plugin, thus
configuration is divided into 2 parts - database configuration and plugin
configuration:

    
            plugins:
                    "Log::DB":
                            database:
                                    driver: 'mysql'
                                    database: 'test'
                                    host: 'localhost'
                                    port: 3306
                                    username: 'logs_username'
                                    password: 'logs_password'
                            log:
                                    message_field_name: 'message'
                                    timestamp_field_name: 'timestamp'
                                    additional_fields:
                                            - 'server_id'
                                            - 'author_id'

In the simplest case _log_ section can be empty. In this case message field
name should be _message_, timestamp field name should be _timestamp_.

If you want to rename _message_ and _timestamp_ to something more clear in
your database logs table, make sure you set corresponding names in
_message_field_name_ and _timestamp_field_name_ under the _log_ section.

If you try to leave a log message in a field which is not listed within
_additional_fields_, you will get an exception.

# CAVEATS

Table name in your database backend should be called 'logs' and it's not
configurable at the moment. I'm terribly sorry for this inconvenience and I
promise I will fix this in the 0.02 version.

# BUGS

This is the 0.01 version and there are bugs. Your feedbacks are greatly
welcome.

# TODO

Add configuration parameter to set logs table name in database backend.

Add more tests for various database engines.

# ACKNOWLEDGEMENTS

Thanks to David Precious for the Dancer::Plugin::Database plugin.

Thanks to my wife for support.

# AUTHOR

Nikolay Aviltsev, `navi@cpan.org`

# LICENSE AND COPYRIGHT

Copyright 2012 Nikolay Aviltsev.

This program is free software; you can redistribute it and/or modify it under
the terms of either: the GNU General Public License as published by the Free
Software Foundation; or the Artistic License.

See <http://dev.perl.org/licenses/> for more information.

# SEE ALSO

Dancer

Dancer::Plugin::Database

