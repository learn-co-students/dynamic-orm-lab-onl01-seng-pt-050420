require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

    def self.table_name
       self.to_s.downcase.pluralize 
    end

    def self.column_names
        columns = []
        DB[:conn].execute("PRAGMA table_info(#{table_name})").each do |col|
            columns << col["name"] unless col["name"] == nil
        end
        columns
    end
end