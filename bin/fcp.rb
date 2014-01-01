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

begin

end
