Sequel.migration do
  change do
    create_table(:messages) do
      primary_key :id
      String :message, :null => false
    end
  end
end
