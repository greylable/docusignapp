class RemoveBranchCodeFromNewenvelope < ActiveRecord::Migration[5.2]
  def change
    remove_column :newenvelopes, :branch_code, :string
  end
end
