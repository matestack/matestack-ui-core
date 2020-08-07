module XSS
  EVIL_SCRIPT = "<script>alert('hello');</script>"
  ESCAPED_EVIL_SCRIPT = "&lt;script&gt;alert('hello');&lt;/script&gt;"
end
