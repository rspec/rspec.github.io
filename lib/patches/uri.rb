module URI
  module_function

  # TODO: REMOVE AFTER UPGRADES
  #
  # Silences a deprecated function
  def decode(path)
    CGI.unescape(path)
  end
end
