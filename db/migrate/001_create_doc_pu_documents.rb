class CreateDocPuDocuments < ActiveRecord::Migration
	def self.up
		create_table :doc_pu_documents do |t|
			t.column :name, :string
			t.references :user
			t.references :project
			t.column :built_at, :datetime
			t.column :template, :string
			t.column :doc_author, :string
			t.column :doc_title, :string
			t.column :doc_date, :string
			t.column :doc_flags, :text
			t.timestamps
		end
	end

	def self.down
		drop_table :doc_pu_documents
	end
end
