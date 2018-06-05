class ChangeNewenvelopeBirthday1 < ActiveRecord::Migration[5.2]
  def change
    change_column :newenvelopes, :birthday, :string
  end
end
