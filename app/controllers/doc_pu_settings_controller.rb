require 'latex_doc'

class DocPuSettingsController < ApplicationController
	unloadable

	def test_latex
		flash = "error"
		begin
			version = LatexDoc.new(params[:file]).version
			flash = "notice"
		rescue Errno::ENOENT => msg 
			version = msg
		end
		render :text => "<div id=\"test-result\" class=\"flash #{flash}\">#{version}</div>"
	end
	
	def test_makeindex
		flash = "error"
		begin
			version = LatexDoc.new("", Rails.root.join("files"), params[:file]).version_makeindex
			flash = "notice"
		rescue Errno::ENOENT => msg 
			version = msg
		end
		render :text => "<div id=\"test-result\" class=\"flash #{flash}\">#{version}</div>"
	end
	
	def test_template
		flash = "error"
		begin
			dirs = DocPuTemplates.new(Rails.root.join(params[:file])).list.join(", ")
			flash = "notice"
			if dirs == ""
				dirs = t(:text_no_template_found)
				flash = "warning"
			else
				dirs = t(:text_templates_found) + dirs
			end
		rescue Errno::ENOENT => msg 
			dirs = msg
		end
		render :text => "<div id=\"test-result\" class=\"flash #{flash}\">#{dirs}</div>"
	end
end
