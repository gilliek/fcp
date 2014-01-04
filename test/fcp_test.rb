require_relative "mock_ftp_server"

require "./test/test_utils"

require "test/unit"
require "io/console"
require "digest/md5"

class TestFCP < Test::Unit::TestCase
	include TestUtils

	MOCK_FTP_PORT = 9999

	def setup
		@ftp_server    = MockFTPServer.new(MOCK_FTP_PORT)
		@server_thread = Thread.new { @ftp_server.start }

		# dirty hack to change the FTP port
		Net::FTP.send(:remove_const, :FTP_PORT)
		Net::FTP.const_set(:FTP_PORT, MOCK_FTP_PORT)
	end

	def teardown
		@server_thread.exit # stop the MockFTPServer#start thread
		clear_tmp
	end

	def test_all
		test_simple_upload
	end

	private
		# fcp -a -P 9999 test/tmp_client/foo ftp://localhost:test/tmp_server/
		# test:
		#		- anonymous login
		#		- change default port
		#		- copy one file to the server
		def test_simple_upload
			cmd         = "./bin/fcp -a -P 9999"
			file        = "test/tmp_client/foo"
			remote_dir  = "test/tmp_server/"
			remote_file = remote_dir + "/" + File.basename(file)

			create_file(file)

			io     = IO::popen("#{cmd} #{file} ftp://localhost:#{remote_dir}")
			puts "#{cmd} #{file} ftp://localhost:#{remote_dir}"
			output = io.readlines.join

			assert(output.empty?)
			assert(File.exists?(remote_file))
			assert(File.file?(remote_file))

			source_content = File.open(file).readlines.join
			target_content = File.open(remote_file).readlines.join

			assert_equal(
				Digest::MD5.digest(source_content),
				Digest::MD5.digest(target_content))
		end
end
