# frozen_string_literal: true
Sequel.migration do
  transaction
  change do
    add_index :ping_results, [:range, :min, :max, :created_at], unique: true
  end
end
