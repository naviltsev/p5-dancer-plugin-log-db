dancer-plugin-log-db
====================

[Still under heavy testing, more documentation to come]

Log arbitrary messages into a database


By default, requires db table with with following SQL declaration:

- id (integer); *not actually required, you can set it to be key field with autoincrement
- timestamp (datetime/timestamp); *not working now
- message (text/varchar);

You can expand functionality by adding any number of columns and write any data into those.
For example, in addition to existing 'timestamp' and 'message' columns, 
you can add 'server_id' column to store server id which left the message.



USAGE

use Dancer;
use Dancer::Plugin::Log::DB;

get '/index' => sub {
	# 'timestamp' is optional - it will be added automatically  
	log_db { message => 'Some message to be logged into database' };

	# or, with additional fields
	log_db { message => 'Some message to log into database',
			server_id => 1,
			field2 => 'field2_content' }
};




SETUP
1) PLUGIN SETUP
Database setup is going to be in application config file.

plugins:
	"Log::DB":
		database:
			driver: 'mysql'
			database: 'logs'
			host: 'localhost'
			port: 3306
			username: 'logs_user'
			password: 'logs_password'
		
		log:
			timestamp_field: 'timestamp'
			message_field: 'message'
			additional_field_list: [ 'server_id', 'field1', 'field2' ]  # what is this for??????? probably for throwing exceptions if there are no such fields in db?
																		# it currently works without this additional_field_list...


Plugin setup section is divided into 2 parts - 'db' and 'log', 'log' section is optional.
In 'db' section you setup connection with database containing table where messages will be logged to.
In 'log' section you setup additional fields in log table, and optionally field name for 'timestamp' and field name for 'message'.


2) SQL TABLE NOTES
There are some rules you have to follow while creating logs table.
- if you don't rename 'timestamp' and 'message' fields in YML, add 'message' field (any type you want), and 'timestamp' field.
- it should contain all fields declared in "log" -> "additional_field_list" list



REQUIREMENTS
- Dancer::Plugin::Database
