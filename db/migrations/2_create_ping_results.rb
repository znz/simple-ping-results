# frozen_string_literal: true
Sequel.migration do
  transaction
  change do
    create_table :ping_results do
      primary_key :id
      DateTime :created_at, null: false
      String :range, size: 15, null: false
      Integer :min, null: false
      Integer :max, null: false
      String :results, size: 256, null: false
    end
  end
end
