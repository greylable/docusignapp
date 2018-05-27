class RemoveDriverLicenceNoFromNewenvelope < ActiveRecord::Migration[5.2]
  def change
    remove_column :newenvelopes, :driver_licence_no, :string
  end
end
