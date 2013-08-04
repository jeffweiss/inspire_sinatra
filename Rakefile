namespace :db do
  task :migrate do
    require 'sequel'
    DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://local.db')
    Sequel.extension :migration
    Sequel::Migrator.run(DB, 'db/migrations')
  end
end
