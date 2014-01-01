#!/usr/bin/env ruby
=begin
  _____ ____ ____
 |  ___/ ___|  _ \
 | |_ | |   | |_) |
 |  _|| |___|  __/
 |_|   \____|_|

	FCP stands for FTP Copy. It aims to be a simple CLI tool that performs copy
	through FTP.

	Version:
		1.0.0

	Author:
		Kevin Gillieron <kevin.gillieron@gw-computing.net>

	License:
		BSD 3-clauses (see LICENSE file)
=end

class Logger
	@@verbose_enabled = false

	def self.enable_verbose()  ; @@verbose_enabled = true      ; end
	def self.disable_verbose() ; @@verbose_enabled = false     ; end
	def self.verbose(msg="")   ; puts msg if @@verbose_enabled ; end

	def self.info(msg="") ; puts msg        ; end
	def self.warn(msg="") ; STDERR.puts msg ; end

	def self.err(msg="", status=1)
		STDERR.puts msg
		exit status
	end
end

module FCP
	require 'net/ftp'

	MODE_ASCII = 0 # ASCII copy
	MODE_BIN   = 1 # Binary copy

	DEFAULT_CONFIG_PATH = [ENV["HOME"] + "/.config/ftpconfig",
												 ENV["HOME"] + "/.ftpconfig"]
	DEFAULT_PORT        = "21"

	# copy options
	@@host      = nil                  # FTP host. Must contain protocol (ftp://)
	@@user      = nil                  # user if login mode is not anonymous
	@@password  = nil                  # password if login mode is not anonymous
	@@port      = DEFAULT_PORT         # FTP port
	@@recursive = false                # for copying directories
	@@anonymous = false                # false if credentials are needed
	@@mode      = MODE_BIN             # transfer mode: ASCII or binary
	@@config    = DEFAULT_CONFIG_PATH  # list of possible path for config file
	@@dir       = ""                   # default remote directory
	@@safe      = false                # Safe mode (ask before overwriting).

	# accessors
	def user=(value)      ; @@user = value      ; end
	def password=(value)  ; @@password = value  ; end
	def port=(value)      ; @@port = value      ; end
	def recursive=(value) ; @@recursive = value ; end
	def anonymous=(value) ; @@anonymous = value ; end
	def mode=(value)      ; @@mode = value      ; end
	def config=(value)    ; @@config = value    ; end
	def safe=(value)      ; @@safe = value      ; end

	def cp_from_ftp(source, target)
		# TODO
	end

	# copy a given array of files to a remote FTP server.
	def cp_to_ftp(source, target)
		# TODO
	end
end

begin

end
