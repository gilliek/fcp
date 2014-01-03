require "fileutils"

module TestUtils
	@@files = []

	def create_file(filepath="foobar", content="Hello, World!")
		f = File.open(filepath, "w")
		f.puts content
		f.close
		@@files = filepath
	end

	def remove_files
		@@files.each { |f| FileUtils.rm(f) }
	end
end
