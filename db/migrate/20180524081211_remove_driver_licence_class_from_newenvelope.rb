class RemoveDriverLicenceClassFromNewenvelope < ActiveRecord::Migration[5.2]
  def change
    remove_column :newenvelopes, :driver_licence_class, :string
  end
end
