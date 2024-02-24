# Custom Liquid filter to check if a string starts with a given prefix.
#
# Usage:
#
#   {{ 'foobar' | starts_with: 'foo' }} => true
#   {{ 'foobar' | starts_with: 'bar' }} => false

module Jekyll
  module StartsWithFilter
    def starts_with(input, prefix)
      input.start_with?(prefix)
    end
  end
end

Liquid::Template.register_filter(Jekyll::StartsWithFilter)
