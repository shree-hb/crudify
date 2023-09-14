namespace :archive do
  desc "This will import the delta generated via Crudify into the database on which this task is being performed"
  task :delta_import, [:file_name] => :environment do |t, args|
    print "\n ------ Importing content delta STARTED ------ \n"
    file_name = args[:file_name]
    EXCLUDE_COLS = ['content_identifier', 'row_identifier']
    abort("--- ABORTING RAKE :: Please pass the Delta JSON file imported via Crudify to proceed ---") if file_name.blank?
    
    file_content = File.read("#{Rails.root}/db/content/#{file_name}")
    records = JSON.parse(file_content)
    record_ids = records.map{|s| s["id"] }
    
    #{} unarchived_records = ArchiveLog.where(id: record_ids, is_exported: false)
    #{}abort("--- ABORTING RAKE :: This JSON has already been processed ---") if unarchived_records.blank?
    records.each do |record|
      
      model = record["class_type"].constantize
      obj_id = record["class_id"]
      action = record["action"]
      payload = record["payload"]
      identifier = payload["content_identifier"]
      record_identifier = payload["row_identifier"]
      record = model.where("#{identifier}": record_identifier)
      
      payload.delete_if{ |col| EXCLUDE_COLS.include?(col)}
        binding.pry
      if action.eql?("update")
        record.update(payload)
      elsif action.eql?('create')
         model.create(payload)
      elfif action.eql?('delete')
        record.destroy
      end
      #{}ArchiveLog.update(record["id"], is_exported:true)
    end
    print "\n ------ Importing content delta COMPLETED -----\n"
  end
end