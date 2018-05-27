class AddNoteToNewenvelope < ActiveRecord::Migration[5.2]
  def change
    add_column :newenvelopes, :note, :string
  end
end
