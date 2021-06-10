# Support propper mapping of errors on existing nested models in nested forms
# https://github.com/rails/rails/issues/24390#issuecomment-703708842

module ActiveRecord
  module AutosaveAssociation
    def validate_collection_association(reflection)
      if association = association_instance_get(reflection.name)
        if records = associated_records_to_validate_or_save(association, new_record?, reflection.options[:autosave])
          all_records = association.target.find_all
          records.each do |record|
            index = all_records.find_index(record)
            association_valid?(reflection, record, index)
          end
        end
      end
    end
  end
end
