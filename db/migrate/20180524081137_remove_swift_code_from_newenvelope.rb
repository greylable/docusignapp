class RemoveSwiftCodeFromNewenvelope < ActiveRecord::Migration[5.2]
  def change
    remove_column :newenvelopes, :swift_code, :string
  end
end
