require_relative "mock_ftp_server"
require_relative "test_utils"

require "test/unit"
require "net/ftp"

class TestMockFTPServer < Test::Unit::TestCase
	include TestUtils

	def setup
		@ftp_server    = MockFTPServer.new
		@server_thread = Thread.new { @ftp_server.start }
		@files         = []
	end

	def teardown
		Thread.kill(@server_thread)
		TestUtils::remove_files
	end
end
