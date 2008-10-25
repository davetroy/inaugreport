# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 1) do

  create_table "filters", :options=>'ENGINE=MyISAM', :force => true do |t|
    t.column "name", :string, :limit => 80
    t.column "aliases", :string
    t.column "title", :string, :limit => 80
    t.column "center_location_id", :integer
    t.column "radius", :integer
    t.column "conditions", :text
    t.column "zoom_level", :integer
    t.column "state", :string, :limit => 2
    t.column "country_code", :string, :limit => 2
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  create_table "invalid_locations", :options=>'ENGINE=MyISAM', :force => true do |t|
    t.column "text", :string, :limit => 80
    t.column "unknown", :boolean
  end

  add_index "invalid_locations", ["text"], :name => "index_invalid_locations_on_text", :unique => true

  create_table "location_aliases", :options=>'ENGINE=MyISAM', :force => true do |t|
    t.column "text", :string, :limit => 80
    t.column "location_id", :integer
  end

  add_index "location_aliases", ["text"], :name => "index_location_aliases_on_text", :unique => true
  add_index "location_aliases", ["location_id"], :name => "index_location_aliases_on_location_id"

  create_table "locations", :options=>'ENGINE=MyISAM', :force => true do |t|
    t.column "address", :string
    t.column "country_code", :string, :limit => 10
    t.column "administrative_area", :string, :limit => 80
    t.column "sub_administrative_area", :string, :limit => 80
    t.column "locality", :string, :limit => 80
    t.column "thoroughfare", :string, :limit => 80
    t.column "postal_code", :string, :limit => 25
    t.column "point", :point, :null => false
    t.column "geo_source_id", :integer
    t.column "filter_list", :string
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  add_index "locations", ["point"], :name => "index_locations_on_point", :spatial=> true 

end
