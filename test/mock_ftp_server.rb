require 'socket'

class MockFTPServer
	SUPPORTED_CMD = ["LIST", "MKD", "PORT", "RETR", "STOR", "TYPE"]

	attr_reader :port # server port
	attr_reader :user # FTP user
	attr_reader :pass # FTP user password
	attr_reader :type

	@server    = nil # TCP server instance
	@client    = nil # client TCP socket
	@data_conn = nil # client TCP socket used for data transfer

	def initialize(port=9999)
		@port = port
		@server = TCPServer.new(@port)
	end

	# start the FTP server
	def start
		loop do
			@client = @server.accept          # Wait for a client to connect
			@client.sendmsg "220 ready\r\n"  # 220 - the server is ready

			# authentication (we assume that the client does this correctly)
			@user = @client.gets.gsub("\r\n", "") # => USER
			@client.sendmsg "331\r\n"            # => USER ok

			@pass = @client.gets.gsub("\r\n", "") # => PASS
			@client.sendmsg "230\r\n"            # => PASS ok

			while req = @client.gets
				req.gsub!("\r\n", "")
				tmp  = req.split(" ")
				cmd, args  = tmp[0], tmp[1..tmp.length-1]

				if !SUPPORTED_CMD.include?(cmd)
					@client.sendmsg "500\r\n"
					next
				end

				self.__send__("cmd_#{cmd.downcase}", args)
			end
		end
	end

	# LIST [path]
	def cmd_list(args=[])
		path, len = args[0], args[0].length
		path += "/" if path[len-1] != "/" && path[len-1] != "*"
		path += "*" if path[len-1] != "*"

		# we actually only care about the file name
		tmpl = "-rw-r--r--\t1 ftp\tftp\t42 Jul 6 21:02 %s"

		# we assume that the data socket connection is already established
		@client.sendmsg "150\r\n" # => ready for the transfer

		files = Dir.glob(path).map { |f| sprintf(tmpl, File.basename(f)) }
		@data_conn.write(files.join("\n"))
		@data_conn.close

		@client.sendmsg "226\r\n" # => download finished
	end

	# MKD [path]
	def cmd_mkd(args=[])
		Dir.mkdir(args[0])
		@client.sendmsg "257\r\n" # => MKD ok
	end

	# PORT [port]
	def cmd_port(args=[])
		tmp = args[0].split(",")
		p1, p2 = tmp[4], tmp[5]

		@data_conn = TCPSocket.new('localhost', p1.to_i * 256 + p2.to_i)
		@client.sendmsg "200\r\n" # => PORT ok
	end

	def cmd_retr(args=[]) ; end

	# STOR [path]
	def cmd_stor(args=[])
		puts args
		# we assume that the data socket connection is already established
		@client.sendmsg "150\r\n" # => ready for the transfer

		data = @data_conn.read(nil).chomp

		# save data to a new file
		file = File.open(args[0], "w")
		file.write(data) # FIXME problem with a missing "\n" for ASCII file
		file.close
		@data_conn.close

		@client.sendmsg "226\r\n" # => upload finished
	end

	# TYPE [type]
	def cmd_type(args=[])
		@type = args[0]
		@client.sendmsg "200\r\n" # => TYPE set
	end
end
