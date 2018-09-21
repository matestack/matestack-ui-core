module Shared::Utils::ToCell

  def to_cell(key, component_name, config, argument, children)
    request_uri = context[:request].env["REQUEST_URI"]
    query_string = context[:request].env["QUERY_STRING"]

    config.merge!(component_key: key)
    config.merge!(children: children)
    config.merge!(origin_url: request_uri.gsub("?" + query_string, ""))
    config.merge!(url_params: context[:params])

    name = component_name
    if name.include?("/")
      name = "#{name.split("/")[0]}/cell/#{name.split("/")[1]}"
    else
      name = "#{name}/cell/#{name}"
    end

    concept(name, argument, config)
  end

end
