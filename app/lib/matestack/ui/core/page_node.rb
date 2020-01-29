module Matestack::Ui::Core
  class PageNode

    def self.build(page_instance, included_config, url_params, &block)
      node = PageNode.new(page_instance, included_config, url_params)
      node.instance_eval(&block)
      node.hash
    end

    attr_reader :hash

    def initialize(page_instance, included_config, url_params)
      @hash = {}
      @node_start_id = 0
      @included_config = included_config
      @url_params = url_params
      @page_instance = page_instance
      page_instance.instance_variables.each do |page_instance_var_key|
        self.instance_variable_set(page_instance_var_key, page_instance.instance_variable_get(page_instance_var_key))
      end
    end

    def method_missing meth, *args, &block
      begin
        if (result = @page_instance.send(meth, *args, &block)).kind_of? ActiveSupport::SafeBuffer
          plain result
        else
          result
        end
      rescue
        node_id = @node_start_id + 1
        @node_start_id = node_id
        current_node = "#{meth}_#{@node_start_id}"
        @hash[current_node] = {}
        @hash[current_node]["component_name"] = meth.to_s
        @hash[current_node]["config"] = {}
        @hash[current_node]["included_config"] = @included_config
        @hash[current_node]["argument"] = nil

        if args.second == :include
          included = args.first
        else
          unless @included_config.nil?
            included = @included_config
          else
            included = nil
          end
        end

        if meth == :isolate
          if args.second.present?
            if args.second.is_a? Hash
              if args.second[:cached_params].nil?
                raise "isolate > you need to pass params within a hash called 'cached_params'"
              else
                isolated_block = @page_instance.send(args.first, args.second[:cached_params])
              end
            else
              raise "isolate > you need to pass params within a hash called 'cached_params'"
            end
          else
            isolated_block = @page_instance.send(args.first)
          end
          @hash[current_node]["components"] = PageNode.build(
            @page_instance, nil, @url_params, &isolated_block
          )
          @hash[current_node]["argument"] = args.first
          @hash[current_node]["cached_params"] = args.second[:cached_params] if args.second.present?
        end

        if meth == :partial
          partial_block = @page_instance.send(args.first, *args.drop(1))
          @hash[current_node]["components"] = PageNode.build(
            @page_instance, included, @url_params, &partial_block
          )
        else
          if args.first.is_a?(Hash)
            @hash[current_node]["config"] = args.first
          else
            @hash[current_node]["argument"] = args.first
          end

          if block_given?
            if args.first.is_a?(Hash) && args.first[:defer].present?
              if @url_params.present? && @url_params[:component_key].present?
                @hash[current_node]["components"] = PageNode.build(@page_instance, included, @url_params, &block)
              else
                return
              end
            else
              @hash[current_node]["components"] = PageNode.build(@page_instance, included, @url_params, &block)
            end
          end
        end
      end

    end

  end
end
