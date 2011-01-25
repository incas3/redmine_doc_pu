require 'latex_flags'

module ModuleLatexWikiPage
	include ModuleLatexFlags
	
	def to_latex()
		# Collect all attached images and get disk filename
		file_sub = {}
		self.wiki_page.attachments.each do |att|
			unless att.content_type.match(/^image/i).nil?
				file_sub[att.filename] = att.disk_filename
			end
		end
		
		# Get version of page
		if self.wiki_page_version == 0
			# Get latest page
			page_txt = String.new(self.wiki_page.content.text)
		else
			ver = self.wiki_page.content.versions.find(:first, :conditions => [ "version = ?", self.wiki_page_version])
			raise ArgumentError, "Can't find Page version!" if ver.nil?
			page_txt = String.new(ver.text)
		end
		
		# Replace alle image filenames with disk filenames
		file_sub.each do |fn, dsk_fn|
			page_txt.gsub!(fn, dsk_fn)
		end
		
		# Check wiki referenzes for redirects
		page_txt.gsub!(/(\s|^)\[\[(.*?)(\|(.*?)|)\]\]/i) do |m|
			ref = $2
			label = $4
			ref = Wiki.titleize(ref)
			redir = WikiRedirect.all(:conditions => ["title = ?", ref])[0]
			ref = redir.redirects_to unless redir.nil?
			" [[#{ref}|#{label}]]"
		end
		
		# Collect rules
		rules = []
		rules.push(:latex_image_ref) if self.latex_image_ref
		rules.push(:latex_code) if self.latex_code
		rules.push(:latex_page_ref) if self.latex_page_ref
		rules.push(:latex_footnote) if self.latex_footnote
		rules.push(:latex_index_emphasis) if self.latex_index_emphasis
		rules.push(:latex_index_importance) if self.latex_index_importance
		rules.push(:latex_remove_macro) if self.latex_remove_macro
		
		# Convert page to latex
		r = TextileDocLatex.new(page_txt)
		r.draw_table_border_latex = self.latex_table_border
		page_txt = r.to_latex(*rules)
		
		if self.latex_add_chapter
			# Add chapter tag
			page_txt = "\n\\chapter{#{self.chapter_name}} \\label{page:#{self.wiki_page.title}}\n" + page_txt
		else
			# Add label to first section, if section exists
			page_txt.sub!(/\\section\{(.+)\}/i) do |m| 
				"\\section{#{$1}}\\label{page:#{self.wiki_page.title.gsub(" ", "_")}}"
			end
		end
		
		return page_txt
	end
end

class LatexWikiPage
	include ModuleLatexWikiPage
	
	attr_accessor :wiki_page
	attr_accessor :wiki_page_version
	attr_accessor :chapter_name
	
	def initialize(wiki_page, wiki_page_version = 0, chapter_name = "Chapter")
		self.wiki_page = wiki_page
		self.wiki_page_version = wiki_page_version
		self.chapter_name = chapter_name
		
		# Set default flag values
		ModuleLatexWikiPage::FLAGS.each do |m, v|
			self.send(m.to_s + "=", v)
		end
	end
end