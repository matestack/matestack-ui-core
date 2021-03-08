module Matestack
  module Ui
    module VueJs
      module Components
        module Collection
          module Helper
            
            def collection_config
              @collection_config
            end
            
            def set_collection_config(id: nil, offset: 0, limit: nil, base_count: nil, filtered_count: nil, data: [])
              @collection_config = CollectionConfig.new(
                id: id,
                offset: init_offset,
                limit: limit,
                count: count,
                base_count: base_count,
                filtered_count: filtered_count,
                data: data,
                params: params,
              )
            end
            
            def get_collection_filter(id, key = nil)
              filter = {}
              params.each do |param_key, value|
                if param_key.start_with?("#{id}-filter-")
                  filter[param_key.gsub("#{id}-filter-", "").to_sym] = value
                end
              end
              key.nil? ? filter : filter[key]
            end
            
            def get_collection_order(id, key=nil)
              order = {}
              params.each do |param_key, value|
                if param_key.start_with?("#{id}-filter-")
                  order[param_key.gsub("#{id}-filter-", "").to_sym] = value
                end
              end
              key.nil? ? order : order[key]
            end

          end
          # end of helper module
          
          CollectionConfig = OpenStruct.new do
            
            def paginated_data
              paginated_data = data
              paginated_data = data.offset(get_collection_offset) unless get_collection_offset == 0
              paginated_data = data.limit(get_collection_limit) unless get_collection_limit == 0
              paginated_data
            end
            
            def get_offset
              (params["#{id}-offset".to_sym] ||= offset).to_i
            end
            
            def get_limit
              (params["#{id}-offset".to_sym] ||= offset).to_i
            end
            
            def pages
              count = filtered_count.present? ? filtered_count : base_count
              page_count = (count/limit.o_f).ceil
              (1..page_count).to_a
            end
            
            def from
              to > 0 ? get_collection_offset + 1 : 0
            end
            
            def to
              current_to = get_collection_offset + get_collection_limit
              return [current_to, filtered_count].min if filtered_count
              [current_to, base_count].min
            end
            
            def config
              self.to_h
            end
            
          end
        
        end 
      end
    end
  end
end