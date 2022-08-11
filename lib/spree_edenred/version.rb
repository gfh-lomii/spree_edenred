module SpreeEdenred
  VERSION = '0.0.12'.freeze

  module_function

  # Returns the version of the currently loaded SpreeEdenred as a
  # <tt>Gem::Version</tt>.
  def version
    Gem::Version.new VERSION
  end
end
