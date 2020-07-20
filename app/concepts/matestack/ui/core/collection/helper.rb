module Matestack::Ui::Core::Collection

  CollectionConfig = Struct.new(:id, :init_offset, :init_limit, :filtered_count, :base_count, :data, :params) do

    def paginated_data
      resulting_data = data
      resulting_data = resulting_data.offset(get_collection_offset) unless get_collection_offset == 0
      resulting_data = resulting_data.limit(get_collection_limit) unless get_collection_limit == 0

      return resulting_data
    end

    def get_collection_offset
      (params["#{id}-offset".to_sym] ||= init_offset).to_i
    end

    def get_collection_limit
      (params["#{id}-limit".to_sym] ||= init_limit).to_i
    end

    def pages
      offset = get_collection_offset
      limit = get_collection_limit
      if filtered_count.present?
        count = filtered_count
      else
        count = base_count
      end
      page_count = count/limit
      page_count += 1 if count%limit > 0
      return (1..page_count).to_a
    end

    def from
      return get_collection_offset + 1 if to > 0
      return 0 if to == 0
    end

    def to
      current_to = get_collection_offset + get_collection_limit
      if filtered_count.present?
        if current_to > filtered_count
          return filtered_count
        else
          return current_to
        end
      else
        if current_to > base_count
          return base_count
        else
          return current_to
        end
      end
    end

    def config
      self.to_h.except(:context)
    end

  end

  module Helper

    def get_collection_filter collection_id, key=nil
      filter_hash = {}
      controller_params.each do |param_key, param_value|
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
      controller_params.each do |param_key, param_value|
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

    def set_collection id: nil, init_offset: 0, init_limit: nil, base_count: nil, filtered_count: nil, data: nil
      @collections = {} if @collections.nil?

      collection_config = CollectionConfig.new(
        id,
        init_offset,
        init_limit,
        filtered_count,
        base_count,
        data,
        controller_params,
      )

      @collections[id.to_sym] = collection_config

      return collection_config
    end

    # try to get params from either controller params, when called in a rails legacy view or
    # from cells context when called in a matestack app/page/component
    def controller_params
      return params.to_unsafe_h if defined? params
      return context[:params] if defined? context
      raise 'collection component is missing access to params or context'
    end

  end
end
