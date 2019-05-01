module Utils

  def stripped(html_string)
    html_string.gsub(/>\s+</, "><").gsub("\n", "").gsub(/\s+/, "")
  end

end
