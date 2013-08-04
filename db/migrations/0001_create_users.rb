Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id
      String :twitter_id, :null => false
      String :name, :null => false
    end
    add_index :users, :twitter_id
  end
end
