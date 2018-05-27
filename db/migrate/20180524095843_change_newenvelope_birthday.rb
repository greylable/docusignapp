class ChangeNewenvelopeBirthday < ActiveRecord::Migration[5.2]
  def change
    change_column :newenvelopes, :birthday, :date
  end
end
