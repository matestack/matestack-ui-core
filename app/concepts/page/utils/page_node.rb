module Page::Utils
  class PageNode

    def self.build(page_instance, &block)
      node = PageNode.new(page_instance)
      node.instance_eval(&block)
      node.hash
    end

    attr_reader :hash

    def initialize(page_instance)
      @hash = {}
      @node_start_id = 0
      @page_instance = page_instance
      page_instance.instance_variables.each do |page_instance_var_key|
        self.instance_variable_set(page_instance_var_key, page_instance.instance_variable_get(page_instance_var_key))
      end
    end

    def method_missing meth, *args, &block
      begin
        @page_instance.send(meth, *args, &block)
      rescue
        node_id = @node_start_id + 1
        @node_start_id = node_id
        current_node = "#{meth}_#{@node_start_id}"
        @hash[current_node] = {}
        @hash[current_node]["component_name"] = meth.to_s
        @hash[current_node]["config"] = {}
        @hash[current_node]["argument"] = nil

        if meth == :partial
          @hash[current_node]["components"] = @page_instance.send(args.first, *args.drop(1))
        else
          if args.first.is_a?(Hash)
            @hash[current_node]["config"] = args.first
          else
            @hash[current_node]["argument"] = args.first
          end

          if block_given?
            @hash[current_node]["components"] = PageNode.build(@page_instance, &block)
          end
        end
      end

    end

  end
end
