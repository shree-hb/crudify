
  class ArchiveLog < ActiveRecord::Base
    EXCLUDE_COLS = ['id', 'created_at', 'updated_at']
    serialize :payload

    scope :non_archived, -> { where("is_exported = false") }
    
    scope :unarchived_deleted, -> (class_type) { where(class_type: class_type, action: 'delete', is_exported: false) }
     
    # Logging for Update action
    def self.track_log(obj, action, parent_identifier=nil, parent_model=nil, child_model=nil)
      class_id = obj.id
      attrs = {action: action, class_id: class_id, class_type: obj.class, is_exported: false } 
      payload = obj.as_json.delete_if{ |col| EXCLUDE_COLS.include?(col) }       
      record = self.find_or_initialize_by(attrs)
 
      if obj.class.is_child_crud
        conditions =  {
                        parent_model: parent_model,
                        parent_identifiers: parent_identifier,
                        child_model: child_model
                      }
      else
        child_identifiers_condition = {}
        #{}binding.pry
        obj.class.content_identifier.each do |ct|
          child_identifiers_condition[ct] = obj.send("#{ct}_was")
        end
        conditions =  {
          model: obj.class.name,
          identifiers: child_identifiers_condition
        }
      end
      payload[:is_child_crud] = obj.class.is_child_crud
      binding.pry
      # payload.merge!(content_identifier: obj.class.content_identifier || nil)
      # payload.merge!(row_identifier: record_identifier || nil)
      payload.merge!(conditions: conditions)
      attrs[:payload] = payload
      record.update(attrs)
    end
    
    # Logging for Delete action
    def self.track_delete_log(record_objs)
       return if record_objs.blank?
       action = 'delete'
       
       record_objs.flatten.each do |record|
       #{} binding.pry
         attrs = { action: action, class_id: record["id"], class_type: record["class_name"], is_exported: false }
         archive_obj = self.find_or_initialize_by(attrs)
         attrs[:payload] = record
         archive_obj.update(attrs) 
       end
       
       #{}class_id = rand(1000..9999)
        #  class_id, class_type = obj.split('|')
        #  payload = {}
        # binding.pry
        # attrs = { action: action, class_id: class_id, class_type: class_type, is_exported: false }
        # # obj = class_type.constantize.where(id: class_id).first
        # # class_identifier = obj.class.content_identifier
        # #  conditions= []
        # #  class_identifier.each do |ct|
        # #   conditions <<  { content_identifier: ct , row_identifier: obj.send("#{ct}_was") }
        # #  end
        # #  payload.merge!(conditions: conditions)
        #  record = self.find_or_initialize_by(attrs)
        #  attrs[:payload] = payload
        #  record.update(attrs)
      #{} end
    end

    # Logging for Create action
    def self.track_create_log(obj)     
      payload = obj.as_json.delete_if{ |col| EXCLUDE_COLS.include?(col) }
      attrs = {payload: payload, class_type: obj.class.name, is_exported: false, action: 'create' } 
      self.create(attrs)
    end

    

 end