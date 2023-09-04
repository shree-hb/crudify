
  class ArchiveLog < ActiveRecord::Base
     EXCLUDE_COLS = ['id', 'created_at', 'updated_at']
     serialize :payload

     scope :non_archived, -> { where("is_exported = false") }

      def self.track_log(obj, action)
        class_id = obj.id
        payload = obj.as_json.delete_if{ |col| EXCLUDE_COLS.include?(col) }       
        attrs = {action: action, class_id: class_id, class_type: obj.class, is_exported: false } 
        record = self.find_or_initialize_by(attrs)
        attrs[:payload] = payload
        record.update(attrs)
      end

  end