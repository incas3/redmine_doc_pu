module DocPuHelper

	# Pritty print wiki pages
	def print_wiki_pages(pages, doc)
		a = []
		pages.all.each do |p|
			if authorize_for(:doc_pu_wiki, :edit) 
				a.push(link_to(p.wiki_page.title, {:controller => :doc_pu_wiki, :action => :edit, :project_id => @project, :doc_pu_id => doc, :id => p}))
			else
				a.push(p.wiki_page.title)
			end
		end
		return "(#{pages.count}): " + a.join(", ")
	end

	# Print version number string
	def to_version(version)
		return t(:text_current_version) if version == 0
		return version.to_s
	end

	def build_icon(msg)
		img = case msg
			when "error" then image_tag("exclamation.png")
			when "warning" then image_tag("warning.png")
			when "bad_box" then image_tag("comment.png")
			else ""
		end
		return img
	end
	
	def acronym_info_tag(str)
		return "<acronym title=\"#{str}\">(?)</acronym>"
	end
	
	def flash_msg(err)
		return "" if err.nil?
		return "error" if err.error_lines.size != 0
		return "warning" if err.warning_lines.size != 0
		return "notice"
	end
	
end
