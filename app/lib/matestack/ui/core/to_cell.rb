module Matestack::Ui::Core::ToCell

  def to_cell(key, component_name, config, argument, children, included_config, cached_params=nil)
    # p cached_params
    request_uri = context[:request].env["REQUEST_URI"]
    query_string = context[:request].env["QUERY_STRING"]

    config.merge!(component_key: key)
    config.merge!(children: children)
    config.merge!(origin_url: request_uri.gsub("?" + query_string, ""))
    config.merge!(url_params: context[:params])
    config.merge!(included_config: included_config)
    config.merge!(cached_params: cached_params)

    if component_name.start_with?("custom")
      return resolve_custom_component(component_name, argument, config)
    else
      return resolve_core_component(component_name, argument, config)
    end

  end

  private

  def resolve_custom_component(component_name, argument, config)
    name = component_name.gsub("_", "/")

    path = name.split("/")[1..-1]
    path_camelized = path.map { |x| x.camelize }

    if path_camelized.count == 1
      class_name = "#{path_camelized[0]}"
      rewritten_path = [path[0]]
    else
      class_name = path_camelized.join("::")
      rewritten_path = path
    end

    custom_component_class_name = "Components::" + class_name

    begin
      begin
        component_class = Object.const_get(custom_component_class_name, false)
      rescue => e
        raise "#{e.message.nil? ? '': 'Got Error: '+e.message}. \
              Make sure to define your custom component class correctly \
              in \"matestack/components/#{rewritten_path.join('/')}.rb\""
      end
      if component_class.is_a?(Class)
        return cell(component_class, argument, config)
      else
        raise "Given component #{component_class} is not a class. \
        You might forget to add the component name to your component call"
      end
    rescue => e
      raise "#{component_name} > #{e.message}"
    end

  end

  def resolve_core_component(component_name, argument, config)
    name = component_name.gsub("_", "/")

    unless name.include?("/")
      name = "#{name}/#{name}"
    end

    path = name.split("/")
    path_camelized = path.map { |x| x.camelize }
    class_name = path_camelized.join("::")

    core_component_class_name = "Matestack::Ui::Core::" + class_name
    begin
      begin
        component_class = Object.const_get(core_component_class_name, false)
        unless component_class.is_a?(Class)
          core_component_class_name = core_component_class_name + "::#{name.split("/").last.camelize}"
          component_class = Object.const_get(core_component_class_name, false)
        end
      rescue => e
        begin
          return resolve_namespaced_component(component_name, argument, config)
        rescue => e
          raise "#{e.message.nil? ? '': 'Got Error: '+e.message}. \
          Component '#{component_name}' not found. Looking for Class '#{core_component_class_name}'. \
          Make sure to prefix a custom component with 'custom_'"
        end
      end
      return cell(component_class, argument, config)
    rescue => e
      raise "#{component_name} > #{e.message}"
    end

  end

  def resolve_namespaced_component(component_name, argument, config)
    name = component_name.gsub("_", "/")

    path = name.split("/")[1..-1]
    namespace = name.split("/")[0].camelize
    path_camelized = path.map { |x| x.camelize }

    if path_camelized.count == 1
      class_name = "#{path_camelized[0]}::#{path_camelized[0]}"
      rewritten_path = [path[0], path[0]]
    else
      class_name = path_camelized[0..-1].join("::")
      rewritten_path = path[0..-1]
    end

    namespaced_class_name = "Matestack::Ui::" + namespace + "::" + class_name

    begin
      begin
        component_class = Object.const_get(namespaced_class_name, false)
        unless component_class.is_a?(Class)
          namespaced_class_name = namespaced_class_name + "::#{name.split("/").last.camelize}"
          component_class = Object.const_get(namespaced_class_name, false)
        end
      rescue => e
        raise "#{e.message}"
      end
      return cell(component_class, argument, config)
    rescue => e
      raise "#{e.message}"
    end
  end

end
