class CreateDocPuWikiPages < ActiveRecord::Migration
	def self.up
		create_table :doc_pu_wiki_pages do |t|
			t.references :wiki_page
			t.column :wiki_page_version, :integer
			t.column :flags, :text
			t.column :use_doc_flags, :boolean
			t.column :wiki_page_order, :integer
			t.references :doc_pu_document
			t.column :chapter_name, :string
		end
	end

	def self.down
		drop_table :doc_pu_wiki_pages
	end
end
