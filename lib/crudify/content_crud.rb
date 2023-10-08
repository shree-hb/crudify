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

    def child_relations(*cols)
      define_singleton_method(:child_relations) { cols }
    end

    def parent_relations(*cols)
      define_singleton_method(:parent_relations) { cols }
    end
   
    def is_child_crud(flag=nil)
      if flag.nil?
        false
      else
        define_singleton_method(:is_child_crud) { flag }
      end
    end

    def content_identifier(*cols)
      define_singleton_method(:content_identifier) { cols }
    end
    
    def skip_relation(*cols)
      define_singleton_method(:skip_relation) { cols }
    end

    def get_relation_class(*args, &block)
      if block_given?
        # If a block is provided, define the method using that block.
        define_method(:get_relation_class, &block)
      else
        # If no block is provided, define the method to return the argument.
        define_method(:get_relation_class) { args }
      end
    end

  end
end

ActiveRecord::Base.extend Crudify::ContentCrud