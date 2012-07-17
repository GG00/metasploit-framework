##
# $Id$
##

##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# web site for more information on licensing and terms of use.
#   http://metasploit.com/
##

require 'msf/core' 

class Metasploit3 < Msf::Auxiliary

	include Msf::Exploit::Remote::MSSQL

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'MSSQL - Execute SQL from file',
			'Description'    => %q{
					This module will allow for multiple SQL queries contained within a specified 
					file to be executed against a MSSQL instance given the appropiate credentials.
			},
			'Author'         => [ 'j0hn__f : <jf[at]tinternet.org.uk>' ],
			'License'        => MSF_LICENSE,
			'Version'        => '$Revision: 1 $'
		))

		register_options(
			[
				OptString.new('SQL_FILE', [ true, "file containing multiple SQL queries execute (one per line)"]),
				OptString.new('QUERY_PREFIX', [ false, "string to append each line of the file",""]),
				OptString.new('QUERY_SUFFIX', [ false, "string to prepend each line of the file",""])
			], self.class)
	end


	def run

		queries = File.readlines(datastore['SQL_FILE'])

		prefix = datastore['QUERY_PREFIX']
		suffix = datastore['QUERY_SUFFIX']

		begin
			queries.each do |sql_query|
				mssql_query(prefix+sql_query.chomp+suffix,true) if mssql_login_datastore
			end
		rescue Rex::ConnectionRefused, Rex::ConnectionTimeout
			print_error "Error connecting to server: #{$!}"
		ensure
			disconnect
		end
	end
end


