# Liquid filter for Jekyll which takes a name and returns the initials
module Jekyll
  module InitialsFilter
    def initials(input)
      if input.nil? || input.empty?
        return input
      end

      input.split(' ').map { |n| n[0] }.join.upcase
    end
  end

  Liquid::Template.register_filter(InitialsFilter)
end
