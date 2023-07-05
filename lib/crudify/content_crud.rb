module Crudify
  module ContentCrud

    def content_attr
      self.class.column_names.select{ |col|  self.class.crud_columns.include?(col.to_sym)  } 
    end

    def relational_display_col(col)
      define_singleton_method(:relational_display_col) { col }
    end

    def crud_col_hash(**columns)
      define_singleton_method(:crud_col_hash) { columns }
    end

    def crud_columns(*columns)
      define_singleton_method(:crud_columns) { columns }
    end

  end
end

ActiveRecord::Base.extend Crudify::ContentCrud