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
    
    def polymorphic_content(*models)
      define_singleton_method(:polymorphic_content) { models }
    end

    def content_identifier(*cols)
      define_singleton_method(:content_identifier) { cols }
    end
    
    def skip_relation(*cols)
      define_singleton_method(:skip_relation) { cols }
    end

  end
end

ActiveRecord::Base.extend Crudify::ContentCrud