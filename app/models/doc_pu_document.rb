require 'latex_flags'
require 'latex_doc'

class DocPuDocument < ActiveRecord::Base
	unloadable

	belongs_to :user
	belongs_to :project
	has_many :doc_pu_wiki_pages, :dependent => :destroy, :order => "wiki_page_order"
	
	validates_presence_of :name, :template, :user_id, :project_id
	validates_uniqueness_of :name

	include ModuleLatexFlags
	include ModuleLatexDoc

	
	def build(filename = nil)		
		# Set document attributes
		self.latex_template.doc_title = (self.doc_title != "" ? self.doc_title : self.name)
		self.latex_template.doc_author = (self.doc_author != "" ? self.doc_author : self.user.name)
		self.latex_template.doc_date = (self.doc_date != "" ? self.doc_date : self.built_at)
		super(filename)
	end
	
	# Get wiki pages
	def wiki_pages
		return self.doc_pu_wiki_pages.all
	end

	def after_initialize()
		self.flags_from_str(self.doc_flags)
		return true
	end

	def before_save()
		self.doc_flags = self.flags_to_str()
		return true
	end

	def after_destroy()
		# Delete document file, if exist
		File.delete(self.filepath) if File.exist?(self.filepath)
		return true
	end

	def filepath()
		return Rails.root.join("files", self.filename)
	end
	
	def filename()
		return "doc_pu_#{self.id}.pdf"
	end

end
