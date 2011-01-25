require_dependency 'wiki_page'

# Patches Redmine's WikiPage dynamically. Adds a relationship
module WikiPagePatch
	def self.included(base)
		# Same as typing in the class
		base.class_eval do
			unloadable # Send unloadable so it will not be unloaded in development
			has_many :doc_pu_wiki_pages, :dependent => :destroy
		end
	end
end

# Add module to WikiPage
WikiPage.send(:include, WikiPagePatch)
