namespace :db do
  namespace :locations do
    desc 'Initialize locations and filters tables with starting data.'
    task :init => :environment do
      conn = Location.connection
      conn.execute('TRUNCATE TABLE filters')
      conn.execute('TRUNCATE TABLE locations')
      conn.execute(File.read(File.dirname(__FILE__) + '/../../db/filters.sql'))
      conn.execute(File.read(File.dirname(__FILE__) + '/../../db/locations.sql'))
    end
  end
end