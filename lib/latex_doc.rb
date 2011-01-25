require 'latex_build'
require 'latex_template'

module ModuleLatexDoc

	include ModuleLatexBuild

	attr_accessor :wiki_pages
	attr_accessor :latex_template
	attr_accessor :makeindex_bin

	def version_makeindex()
		old_work_dir = Dir.pwd
		# Change to working directory
		Dir.chdir(self.work_dir)

		begin
			# Create dummy file and run makeindex
			File.new("makeindex.txt", "w").close
			IO.popen(self.makeindex_bin + " makeindex.txt").close
		
			# Read logfile
			f = File.new("makeindex.ilg")
			version = f.readline
			f.close
		ensure
			# Delete generated files
			File.delete("makeindex.ilg") if File.exist?("makeindex.ilg")
			File.delete("makeindex.ind") if File.exist?("makeindex.ind")
			File.delete("makeindex.txt") if File.exist?("makeindex.txt")
			
			# Restore working directory
			Dir.chdir(old_work_dir)
		end
		return version
	end
	
	def makeindex()
		old_work_dir = Dir.pwd
		# Change to working directory
		Dir.chdir(self.work_dir)
		
		begin
			# Run makeindex application
			IO.popen(self.makeindex_bin + " template.idx").close
			
			# Read logfile
			f = File.new("template.ilg")
			self.build_log += f.readlines
			f.close
			
		ensure
			# Restore working directory
			Dir.chdir(old_work_dir)
		end
	end
	
	def add_page(page)
		self.wiki_pages.push(page)
	end
	
	def to_latex()
		doc_txt = ""
		self.wiki_pages.each do |page|
			doc_txt += page.to_latex
		end
		return doc_txt
	end
	
	def build(filename = nil)
		# Get latex doc
		doc_txt = self.to_latex
		
		# Write document file
		f = File.new(self.work_dir + "document.tex", "w")
		f.write(doc_txt)
		f.close
		
		# Save template
		self.latex_template.save(self.work_dir + "template.tex")
		
		# Build document
		ret = super("template.tex")
		
		# Rename document
		File.rename(self.work_dir + "template.pdf", self.work_dir + filename) if not filename.nil? and File.exist?(self.work_dir + "template.pdf")
		return ret
	end
	
	def clean()
		# Delete latex files
		File.delete(self.work_dir + "document.tex") if File.exist?(self.work_dir + "document.tex")
		File.delete(self.work_dir + "template.tex") if File.exist?(self.work_dir + "template.tex")
		File.delete(self.work_dir + "template.ilg") if File.exist?(self.work_dir + "template.ilg")
		File.delete(self.work_dir + "template.ind") if File.exist?(self.work_dir + "template.ind")
		res = super("template.tex")
		
		# Add build log message
		self.build_log.push("delete file document.tex")
		self.build_log.push("delete file template.tex")
		self.build_log.push("delete file template.ilg")
		self.build_log.push("delete file template.ind")
		
		return res
	end
end

class LatexDoc
	include ModuleLatexDoc
	
	def initialize(latex_bin = "latex", work_dir = ".", makeindex_bin = "makeindex")
		self.wiki_pages = []
		self.latex_template = nil
		self.latex_bin = latex_bin
		self.makeindex_bin = makeindex_bin
		self.work_dir = work_dir
		self.build_log = []
	end
end
