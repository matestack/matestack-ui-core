module Matestack::Ui::Core::Collection

  CollectionConfig = Struct.new(:id, :init_offset, :init_limit, :filtered_count, :base_count, :data, :filter, :context) do

    def paginated_data
      data
        .offset(get_collection_offset)
        .limit(get_collection_limit)
    end

    def get_collection_offset
      (context[:params]["#{id}-offset".to_sym] ||= init_offset).to_i
    end

    def get_collection_limit
      (context[:params]["#{id}-limit".to_sym] ||= init_limit).to_i
    end

    def pages
      offset = get_collection_offset
      limit = get_collection_limit
      count = filtered_count
      page_count = count/limit
      page_count += 1 if count%limit > 0
      return (1..page_count).to_a
    end

    def from
      get_collection_offset + 1
    end

    def to
      current_to = get_collection_offset + get_collection_limit
      if current_to > filtered_count
        return filtered_count
      else
        return current_to
      end
    end

    def config
      self.to_h.except(:context)
    end

  end


  module Helper

    def get_collection_filter collection_id, key=nil
      filter_hash = {}
      context[:params].each do |param_key, param_value|
        if param_key.start_with?("#{collection_id}-filter-")
          param_key.gsub("#{collection_id}-filter-", "")
          filter_hash[param_key.gsub("#{collection_id}-filter-", "").to_sym] = param_value
        end
      end
      if key.nil?
        return filter_hash
      else
        return filter_hash[key]
      end
    end

    def get_collection_order collection_id, key=nil
      order_hash = {}
      context[:params].each do |param_key, param_value|
        if param_key.start_with?("#{collection_id}-order-")
          param_key.gsub("#{collection_id}-order-", "")
          order_hash[param_key.gsub("#{collection_id}-order-", "").to_sym] = param_value
        end
      end
      if key.nil?
        return order_hash
      else
        return order_hash[key]
      end
    end

    def set_collection id: nil, init_offset: 0, init_limit: 10, base_count: nil, filtered_count: nil, data: nil
      @collections = {} if @collections.nil?

      collection_config = CollectionConfig.new(
        id,
        init_offset,
        init_limit,
        filtered_count,
        base_count,
        data,
        get_collection_filter(id),
        context
      )

      @collections[id.to_sym] = collection_config

      return collection_config
    end

  end
end
