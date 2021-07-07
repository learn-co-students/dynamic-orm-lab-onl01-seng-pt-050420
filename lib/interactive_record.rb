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

    def initialize(attributes = {})
        attributes.each do |k,v|
            send("#{k}=", v)
        end
    end

    def table_name_for_insert
        self.class.table_name 
    end

    def col_names_for_insert
        self.class.column_names.delete_if{|a| a == "id"}.join(", ")
    end

    def values_for_insert
        values = []
        self.class.column_names.each do |column|
            values << "'#{send(column)}'" unless column == "id"
        end
        values.join(", ")
    end

    def save
        DB[:conn].execute("INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})")
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM #{table_name} WHERE name = ?
        SQL

        DB[:conn].execute(sql, name)
    end

    def self.find_by(attribute)
        sql = "SELECT * FROM #{table_name} WHERE #{attribute.keys[0]} = '#{attribute.values[0]}'"
        DB[:conn].execute(sql)
    end
end