require 'latex_template'

class DocPuTemplates < LatexTemplate
	
	attr_accessor :template_dir
	
	def initialize(template_dir = ".")
		@template_dir = Dir.new(template_dir).path
	end
	
	def header(filename)
		self.load(filename)
		super()
	end
	
	def load(filename)
		super(@template_dir + "/" + filename)
	end
	
	def list()
		old_work_dir = Dir.pwd
		# Change to working directory
		Dir.chdir(@template_dir)
		
		# List directory
		list = Dir.glob("*.tex")
		
		# Restore working directory
		Dir.chdir(old_work_dir)
		return list
	end
end
