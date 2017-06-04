# frozen_string_literal: true
Sequel.migration do
  transaction
  change do
    create_table :targets do
      primary_key :id
      String :range, size: 15, null: false, unique: true
      Integer :min, null: false
      Integer :max, null: false
      TrueClass :enable, null: false, default: true
    end
  end
end
