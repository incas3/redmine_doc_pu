class LatexOutputParser

	attr_accessor :warnings, :errors, :bad_boxes, :pages
	attr_accessor :warning_lines, :error_lines, :bad_box_lines
	
	def initialize()
		self.reset()
	end
	
	def parse(lines)
		self.reset()
		lines.each do |line|
			parse_line(line)
		end
	end
	
	def parse_line(line)
		@line_num += 1
		
		# Check for warning
		unless line.match(/\swarning(\s|:)/i).nil?
			@warnings += 1
			@warning_lines.push(@line_num)
		end
		# Check for error
		unless line.match(/(^!\s)|(\serror(\s|:))/i).nil?
			@errors += 1
			@error_lines.push(@line_num)
		end
		# Check for bad box
		unless line.match(/^Overfull/i).nil?
			@bad_boxes += 1
			@bad_box_lines.push(@line_num)
		end
		# Check for pages
		np = line.match(/\s\((\d+)\spages?,/i)
		unless np.nil?
			@pages = $1
		end
	end
	
	def reset()
		@line_num = 0
		@warnings = 0
		@errors = 0
		@bad_boxes = 0
		@pages = 0
		@warning_lines = []
		@error_lines = []
		@bad_box_lines = []
	end

	def to_s()
		"LaTeX-Result: #{@errors} Error(s), #{@warnings} Warning(s), #{@bad_boxes} Bad Box(es), #{@pages} Page(s)"
	end
end

module ModuleLatexBuild
	
	attr_accessor :latex_bin, :work_dir
	attr_accessor :build_log
	
	def version()
		f = IO.popen(self.latex_bin + " --version")
		f.readlines[0]
	end
		
	def build(filename)
		old_work_dir = Dir.pwd
		# Change to working directory
		Dir.chdir(self.work_dir)
		
		begin
			# Run Latex application
			f = IO.popen(self.latex_bin + " -interaction=nonstopmode " + filename)
			self.build_log = f.readlines
			f.close
			
			par = LatexOutputParser.new()
			par.parse(self.build_log)
		ensure
			# Restore working directory
			Dir.chdir(old_work_dir)
		end
		return par
	end

	def clean(filename)
		old_work_dir = Dir.pwd
		# Change to working directory
		Dir.chdir(self.work_dir)
		
		begin
			# Delete files
			name = filename.split(/(\w*)./)[1]
			File.delete(name + ".aux") if File.exist?(name + ".aux")
			File.delete(name + ".idx") if File.exist?(name + ".idx")
			File.delete(name + ".lof") if File.exist?(name + ".lof")
			File.delete(name + ".log") if File.exist?(name + ".log")
			File.delete(name + ".out") if File.exist?(name + ".out")
			File.delete(name + ".toc") if File.exist?(name + ".toc")

			# Add build log message
			self.build_log = [
				"delete file #{name}.aux",
				"delete file #{name}.idx",
				"delete file #{name}.lof",
				"delete file #{name}.log",
				"delete file #{name}.out",
				"delete file #{name}.toc"]
		ensure
			# Restore working directory
			Dir.chdir(old_work_dir)
		end
		return LatexOutputParser.new()
	end
end

class LatexBuild
	include ModuleLatexBuild
		
	def initialize(latex_bin = "latex", work_dir = ".")
		self.latex_bin = latex_bin
		self.work_dir = work_dir
		self.build_log = []
	end
end
