class RemoveExpirationDateFromNewenvelope < ActiveRecord::Migration[5.2]
  def change
    remove_column :newenvelopes, :expiration_date, :datetime
  end
end
