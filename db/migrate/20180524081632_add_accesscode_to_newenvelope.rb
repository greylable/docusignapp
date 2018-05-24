class AddAccesscodeToNewenvelope < ActiveRecord::Migration[5.2]
  def change
    add_column :newenvelopes, :accesscode, :string
  end
end
