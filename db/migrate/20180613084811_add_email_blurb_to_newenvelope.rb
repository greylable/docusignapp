class AddEmailBlurbToNewenvelope < ActiveRecord::Migration[5.2]
  def change
    add_column :newenvelopes, :email_blurb, :string
  end
end
