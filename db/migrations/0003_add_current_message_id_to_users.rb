Sequel.migration do
  change do
    add_column(:users, :current_message_id, Integer, :default => 1)
  end
end