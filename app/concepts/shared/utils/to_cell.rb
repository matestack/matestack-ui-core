module Shared::Utils::ToCell

  def to_cell(key, component_name, config, argument, children, included_config)
    request_uri = context[:request].env["REQUEST_URI"]
    query_string = context[:request].env["QUERY_STRING"]

    config.merge!(component_key: key)
    config.merge!(children: children)
    config.merge!(origin_url: request_uri.gsub("?" + query_string, ""))
    config.merge!(url_params: context[:params])
    config.merge!(included_config: included_config)

    name = component_name.gsub("_", "/")
    if name.include?("/")
      name = "#{name.split("/")[0]}/cell/#{name.split("/")[1]}"
    else
      name = "#{name}/cell/#{name}"
    end

    begin
      concept(name, argument, config)
    rescue
      name = "components/" + name
      concept(name, argument, config)
    end
  end

end
