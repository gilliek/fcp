require_relative "mock_ftp_server"

require "./test_utils"

require "test/unit"
require "net/ftp"

class TestMockFTPServer < Test::Unit::TestCase
	include TestUtils

	MOCK_FTP_PORT = 9999

	def setup
		@ftp_server    = MockFTPServer.new(MOCK_FTP_PORT)
		@server_thread = Thread.new { @ftp_server.start }
		@files         = []

		# dirty hack to change the FTP port
		Net::FTP.send(:remove_const, :FTP_PORT)
		Net::FTP.const_set(:FTP_PORT, MOCK_FTP_PORT)

		# login as anonymous
		@ftp = Net::FTP.new("localhost")
		@ftp.login
	end

	def teardown
		@ftp.close
		@server_thread.exit # stop the MockFTPServer#start thread
		clear_tmp
	end

	# Since the class is re-instanciated for each test, we have to
	# wrap them all into this method in order to avoid problem with
	# the mock server.
	def test_all
		test_cmd_list
		test_cmd_mkd
	end

	private
		def test_cmd_list
			files = {"tmp_server/foo" => "FOO", "tmp_server/bar" => "BAR"}
			files.each { |k,v| create_file(k, v) }

			tmpl_regexp = /-rw-r--r--\t1 ftp\tftp\t42 Jul 6 21:02 [a-z]+/

			list = @ftp.ls("tmp_server")
			assert_equal(list.length, files.length)

			list.each do |line|
				assert_match(line, tmpl_regexp)

				tmp      = line.split(" ")
				filename = "tmp_server/" + tmp[tmp.length-1]

				assert(files.has_key?(filename))
				files.delete(filename)
			end

			assert(files.empty?)
		end

		def test_cmd_mkd
			folder = "tmp_server/foobar"

			@ftp.mkdir(folder)
			assert(File.exists?(folder))
			assert(File.directory?(folder))
		end
end
