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
	end

	def teardown
		@server_thread.exit # stop the MockFTPServer#start thread
		clear_tmp
	end

	# Since the class is re-instanciated for each test, we have to
	# wrap them all into this method in order to avoid problem with
	# the mock server.
	def test_all
		test_simple_upload
		test_config
		test_recursive_copy
		test_safe_copy_without_overwriting
		test_safe_copy_with_overwriting
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

			create_file(file,  "FOO")

			test_copy_helper("#{cmd} #{file} ftp://localhost:#{remote_dir}",
				file, remote_file)
		end

		# fcp -c test/fcpconfig test/tmp_client/bar ftp://local:
		# test:
		#		- copy using config file settings
		def test_config
			cmd         = "./bin/fcp -c test/fcpconfig"
			file        = "test/tmp_client/bar"
			remote_dir  = "test/tmp_server/"
			remote_file = remote_dir + "/" + File.basename(file)

			create_file(file, "BAR")

			test_copy_helper("#{cmd} #{file} ftp://local:", file, remote_file)
		end

		# fcp -c test/fcpconfig test/tmp_client/bar ftp://local:
		# test:
		#		- recursive copy
		def test_recursive_copy
			cmd          = "./bin/fcp -c test/fcpconfig -r"
			dir          = "test/tmp_client/plop"
			remote_dir   = "test/tmp_server/plop"
			file1        = dir + "/foobar1"
			file2        = dir + "/foobar2"
			remote_file1 = remote_dir + "/" + File.basename(file1)
			remote_file2 = remote_dir + "/" + File.basename(file2)

			Dir.mkdir(dir)
			create_file(file1)
			create_file(file2)

			io = IO::popen("#{cmd} #{dir} ftp://local:")

			assert(io.readlines.join.empty?)
			assert(File.exists?(remote_dir))
			assert(File.directory?(remote_dir))

			assert(check_file(file1, remote_file1))
			assert(check_file(file2, remote_file2))
		end

		# fcp -s -c test/fcpconfig test/tmp_client/foo ftp://local:
		# test:
		#		- safe copy without overwriting
		def test_safe_copy_without_overwriting
			# we assume that the file is already created by previous tests
			cmd         = "./bin/fcp -s -c test/fcpconfig"
			file        = "test/tmp_client/bar"
			remote_file = "test/tmp_server/foo"
			expected    = "already exists. Would you like to overwrite it ? (y/n) "

			IO::popen("#{cmd} #{file} ftp://local:foo", "r+") do |io|
				io.puts "n"
				assert_equal(io.read, "'#{File.basename(remote_file)}' #{expected}")
				assert(!check_file(file, remote_file))
			end
		end

		# fcp -s -c test/fcpconfig test/tmp_client/foo ftp://local:
		# test:
		#		- safe copy with overwriting
		def test_safe_copy_with_overwriting
			# we assume that the file is already created by previous tests
			cmd         = "./bin/fcp -s -c test/fcpconfig"
			file        = "test/tmp_client/bar"
			remote_file = "test/tmp_server/foo"
			expected    = "already exists. Would you like to overwrite it ? (y/n) "
			IO::popen("#{cmd} #{file} ftp://local:foo", "r+") do |io|
				io.puts "y"
				assert_equal(io.read, "'#{File.basename(remote_file)}' #{expected}")
				assert(check_file(file, remote_file))
			end
		end

		def test_copy_helper(cmd, file, remote_file)
			io = IO::popen(cmd)
			assert(io.readlines.join.empty?)
			assert(check_file(file, remote_file))
		end

		def check_file(file, remote_file)
			assert(File.exists?(remote_file))
			assert(File.file?(remote_file))

			source_content = File.open(file).readlines.join
			target_content = File.open(remote_file).readlines.join

			source_digest = Digest::MD5.digest(source_content)
			target_digest = Digest::MD5.digest(target_content)

			return source_digest == target_digest
		end
end
