class RenameVoidEnvsToVoidenvelopes < ActiveRecord::Migration[5.2]
  def change
    rename_table :void_envs, :voidenvelopes
  end
end
