require "fileutils"

module TestUtils
	def create_file(filepath="foobar", content="Hello, World!")
		f = File.open(filepath, "w")
		f.puts content
		f.close
	end

	def clear_tmp
		Dir["./tmp_server/*", "./tmp_client/*"].each do |f|
			FileUtils.rm_r(f)
		end
	end
end
