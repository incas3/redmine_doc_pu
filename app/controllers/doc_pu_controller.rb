require 'doc_pu_templates'

class DocPuController < ApplicationController
	unloadable
	layout "base"
	menu_item :doc_pu_menu
	#before_filter :find_project
	before_filter :find_project, :authorize
	#, :only => [:build, :new, :edit]
	
	# Show all documents
	def index
		@documents = DocPuDocument.find_all_by_project_id(@project)
	end


	# Create new document
	def new
		@templates_list = DocPuTemplates.new(Rails.root.join(Setting.plugin_redmine_doc_pu["template_dir"])).list
		@doc = DocPuDocument.new
		@doc.project = @project
		@doc.user = User.current
		if request.post?
			# Save object
			@doc.attributes = checkbox_to_boolean(params[:doc])
			if @doc.save
				flash[:notice] = t(:flash_document_saved)
				redirect_to :action => :edit, :project_id => @project, :id => @doc
				return
			end
		end
	end


	# Edit document
	def edit
		@doc = DocPuDocument.find(params[:id])		
		if request.post?
			# Update document
			@doc.attributes = checkbox_to_boolean(params[:doc])
			flash[:notice] = t(:flash_document_updated) if @doc.save
		end 
		
		# Create template list and info
		@templates = DocPuTemplates.new(Rails.root.join(Setting.plugin_redmine_doc_pu["template_dir"]))
		@templates_list = @templates.list
		@template_info = @templates.header(@doc.template).join("\n")
	end

	# Open document
	def open
		@doc = DocPuDocument.find(params[:id])
		begin
			send_file @doc.filepath, :type => "application/pdf"
		rescue
			flash[:warning] = t(:flash_no_document_found)
			redirect_to :action => :build, :project_id => @project, :id => @doc
		end
	end
	
	
	def template
		@doc = DocPuDocument.find(params[:id])
		@templates = DocPuTemplates.new(Rails.root.join(Setting.plugin_redmine_doc_pu["template_dir"]))
		@templates.load(@doc.template)
		@code = @templates.file_content
	end
	
	def code
		@doc = DocPuDocument.find(params[:id])
		@code = @doc.to_latex
	end
	
	def build
		@doc = DocPuDocument.find(params[:id])
	end
	
	
	# Build document
	def build_remote
		# Save build date
		@doc = DocPuDocument.find(params[:id])
		@doc.built_at = Time.now
		@doc.save
	
		# Create template
		@templates = DocPuTemplates.new(Rails.root.join(Setting.plugin_redmine_doc_pu["template_dir"]))
		@templates.load(@doc.template)
		
		# Setup build
		@doc.latex_bin = Setting.plugin_redmine_doc_pu["latex_bin"]
		@doc.makeindex_bin = Setting.plugin_redmine_doc_pu["makeindex_bin"]
		@doc.work_dir = Rails.root.join("files")
		@doc.latex_template = @templates
		
		# Build document
		@error = @doc.build(@doc.filename)
		# Run makeindex
		begin
			@doc.makeindex
		rescue Errno::ENOENT => msg
			@doc.build_log += [msg]
		end
		
		# Format build log
		@log = Array.new
		@doc.build_log.each do |log_line|
			@log.push({:line => log_line, :msg => nil})
		end
		@error.error_lines.each{|num| @log[num - 1][:msg] = "error" }
		@error.warning_lines.each{|num| @log[num - 1][:msg] = "warning"}
		@error.bad_box_lines.each{|num| @log[num - 1][:msg] = "bad_box"}
		
		render :partial => "log"
	end
	
	def clean_remote
		@doc = DocPuDocument.new
		@doc.work_dir = Rails.root.join("files")
		@error = @doc.clean
		@log = Array.new
		@doc.build_log.each do |log_line|
			@log.push({:line => log_line, :msg => nil})
		end
		render :partial => "log"
	end

	# Delete document
	def delete
		@doc = DocPuDocument.find(params[:id])
		@doc.destroy
		flash[:notice] = t(:flash_document_deleted)
		redirect_to :action => :index, :project_id => @project
	end

	# @project variable must be set before calling the authorize filter
	def find_project
		@project = Project.find(params[:project_id])
	end

	# Convert checkbox value to boolean
		def checkbox_to_boolean(param)
		ModuleLatexFlags::FLAGS.each do |m, v|
			param[m.to_s] = (param[m.to_s] == "1")
		end
		return param
	end
end
