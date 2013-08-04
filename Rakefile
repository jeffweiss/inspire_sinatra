namespace :db do
  task :migrate do
    require 'sequel'
    DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://local.db')
    Sequel.extension :migration
    Sequel::Migrator.run(DB, 'db/migrations')
  end
  task :seed do
    require 'sequel'
    DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://local.db')
    require File.join(File.dirname(__FILE__), 'lib/message')
    File.open('message_seed', 'r') do |f|
      f.each_line do |line|
        if line.strip.length > 0
          m = Message.new
          m.message = line
          m.save
        end
      end
    end
  end
end
