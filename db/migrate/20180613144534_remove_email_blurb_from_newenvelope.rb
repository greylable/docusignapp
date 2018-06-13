class RemoveEmailBlurbFromNewenvelope < ActiveRecord::Migration[5.2]
  def change
    remove_column :newenvelopes, :email_blurb, :string
  end
end
