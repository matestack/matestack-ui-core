module App::Utils
  class AppNode

    def self.build(app_instance, &block)
      node = AppNode.new(app_instance)
      node.instance_eval(&block)
      node.hash
    end

    attr_reader :hash

    def initialize(app_instance)
      @hash = {}
      @node_start_id = 0
      @app_instance = app_instance
      app_instance.instance_variables.each do |app_instance_var_key|
        self.instance_variable_set(app_instance_var_key, app_instance.instance_variable_get(app_instance_var_key))
      end
    end

    def method_missing meth, *args, &block
      begin
        @app_instance.send(meth, *args, &block)
      rescue
        node_id = @node_start_id + 1
        @node_start_id = node_id
        current_node = "#{meth}_#{@node_start_id}"
        @hash[current_node] = {}
        @hash[current_node]["component_name"] = meth.to_s
        @hash[current_node]["config"] = {}
        @hash[current_node]["argument"] = nil

        if meth == :page_content
          @hash[current_node]["components"] = @app_instance.send(:page_nodes)
        elsif meth == :partial
          @hash[current_node]["components"] = @app_instance.send(args.first, *args.drop(1))
        else
          if args.first.is_a?(Hash)
            @hash[current_node]["config"] = args.first
          else
            @hash[current_node]["argument"] = args.first
          end

          if block_given?
            @hash[current_node]["components"] = AppNode.build(@app_instance, &block)
          end
        end
      end

    end

  end
end
