require_relative "mock_ftp_server"

require "./test/test_utils"

require "test/unit"
require "net/ftp"
require "digest/md5"

class TestMockFTPServer < Test::Unit::TestCase
	include TestUtils

	MOCK_FTP_PORT = 10000

	def setup
		@ftp_server    = MockFTPServer.new(MOCK_FTP_PORT)
		@server_thread = Thread.new { @ftp_server.start }

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
		test_cmd_stor
	end

	private
		def test_cmd_list
			files = {"test/tmp_server/foo" => "FOO", "test/tmp_server/bar" => "BAR"}
			files.each { |k,v| create_file(k, v) }

			tmpl_regexp = /-rw-r--r--\t1 ftp\tftp\t42 Jul 6 21:02 [a-z]+/

			list = @ftp.ls("test/tmp_server")
			assert_equal(list.length, files.length)

			list.each do |line|
				assert_match(line, tmpl_regexp)

				tmp      = line.split(" ")
				filename = "test/tmp_server/" + tmp[tmp.length-1]

				assert(files.has_key?(filename))
				files.delete(filename)
			end

			assert(files.empty?)
		end

		def test_cmd_mkd
			folder = "test/tmp_server/foobar"

			@ftp.mkdir(folder)
			assert(File.exists?(folder))
			assert(File.directory?(folder))
		end

		def test_cmd_stor
			filepath        = "test/tmp_client/file_to_store"
			remote_filepath = "test/tmp_server/" + File.basename(filepath)

			create_file(filepath)

			@ftp.puttextfile(filepath, remote_filepath)

			assert(File.exists?(remote_filepath))

			source_content = File.open(filepath).readlines.join
			target_content = File.open(remote_filepath).readlines.join

			assert_equal(
				Digest::MD5.digest(source_content),
				Digest::MD5.digest(target_content))
		end
end
