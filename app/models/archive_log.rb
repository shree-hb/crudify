
  class ArchiveLog < ActiveRecord::Base
    EXCLUDE_COLS = ['id', 'created_at', 'updated_at']
    serialize :payload

    scope :non_archived, -> { where("is_exported = false") }
     
     # Logging for Update action
     def self.track_log(obj, action)
      class_id = obj.id
      attrs = {action: action, class_id: class_id, class_type: obj.class, is_exported: false } 
      payload = obj.as_json.delete_if{ |col| EXCLUDE_COLS.include?(col) }       

      record = self.find_or_initialize_by(attrs)
      class_identifier = obj.class.content_identifier
      record_identifier =  obj.send("#{class_identifier}_was")
      
      payload.merge!(content_identifier: obj.class.content_identifier || nil)
      payload.merge!(row_identifier: record_identifier || nil)
      attrs[:payload] = payload
      record.update(attrs)
     end
    
     # Logging for Delete action
     def self.track_delete_log(record_objs)
       return if record_objs.blank?
       action = 'delete'
       record_objs.each do |obj|
         class_id, class_type = obj.split('|')
         attrs = { action: action, class_id: class_id, class_type: class_type, is_exported: false }
         record = self.find_or_initialize_by(attrs)
         record.update(attrs)
       end
     end

     # Logging for Create action
     def self.track_create_log(obj)     
      payload = obj.as_json.delete_if{ |col| EXCLUDE_COLS.include?(col) }
      attrs = {payload: payload, class_type: obj.class.name, is_exported: false, action: 'create' } 
      self.create(attrs)
    end

 end