module Matestack::Ui::Core
  class ComponentNode

    def self.build(component_instance, included_config, &block)
      node = ComponentNode.new(component_instance, included_config)
      node.instance_eval(&block)
      node.hash
    end

    attr_reader :hash

    def initialize(component_instance, included_config)
      @hash = {}
      @node_start_id = 0
      @component_instance = component_instance
      component_instance.instance_variables.each do |component_instance_var_key|
        self.instance_variable_set(component_instance_var_key, component_instance.instance_variable_get(component_instance_var_key))
      end
      @included_config = included_config
    end

    def method_missing meth, *args, &block
      begin
        if (result = @component_instance.send(meth, *args, &block)).kind_of? ActiveSupport::SafeBuffer
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
        @hash[current_node]["argument"] = nil
        @hash[current_node]["included_config"] = @included_config

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
          raise("isolate > only works on page level currently. component support is comming soon!")
        end

        if meth == :partial
          @hash[current_node]["components"] = @component_instance.send(args.first, *args.drop(1))
        elsif meth == :yield_components
          @hash[current_node]["component_name"] = "partial"
          @hash[current_node]["components"] = @component_instance.send(:get_children)
        else
          if args.first.is_a?(Hash)
            @hash[current_node]["config"] = args.first unless meth == :slot
          else
            @hash[current_node]["argument"] = args.first
          end

          # if args.second == :include
          #   included = args.first
          # else
          #   unless @included_config.nil?
          #     included = @included_config
          #   else
          #     included = nil
          #   end
          # end

          if block_given?
            @hash[current_node]["components"] = ComponentNode.build(@component_instance, included, &block)
          elsif meth == :slot
            # @hash[current_node]["components"] = ComponentNode.build(@component_instance, included, &args.first)
            @hash[current_node]["components"] =  args.first
          end
        end
      end

    end

  end
end
