
class LatexTemplate
	
	attr_accessor :file_content, :doc_title
	attr_accessor :doc_author, :doc_date
	
	def initialize(filename)
		@doc_title = nil
		@doc_author = nil
		@doc_date = nil
		self.load(filename)
	end
	
	def load(filename)
		# Load template file
		f = File.new(filename)
		@file_content = f.read
		f.close
		self.update_macros
	end
	
	def update_macros()
		# Replace macros
		@file_content.sub!(/\\title\{(.*?)\}/i, "\\title{#{doc_title}}") unless @doc_title.nil?
		@file_content.sub!(/\\author\{(.*?)\}/i, "\\author{#{doc_author}}") unless @doc_author.nil?
		@file_content.sub!(/\\date\{(.*?)\}/i, "\\date{#{doc_date}}") unless @doc_date.nil?
	end
	
	def save(filename)
		self.update_macros
		# Write template file
		f = File.new(filename, "w")
		f.write(@file_content)
		f.close
	end
	
	def header()
		return @file_content.scan(/^%%%(.*)/)
	end

end
