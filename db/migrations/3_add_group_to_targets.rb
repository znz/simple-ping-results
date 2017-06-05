# frozen_string_literal: true
Sequel.migration do
  transaction
  change do
    add_column :targets, :group, String, null: false, default: 'Default'
  end
end
