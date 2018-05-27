class RemoveEnvelopeIdFromNewenvelope < ActiveRecord::Migration[5.2]
  def change
    remove_column :newenvelopes, :envelope_id, :string
  end
end
