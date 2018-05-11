class CreateVoidEnvs < ActiveRecord::Migration[5.2]
  def change
    create_table :void_envs do |t|
      t.string :name
      t.string :envelope_id
      t.string :void_reason

      t.timestamps
    end
  end
end
