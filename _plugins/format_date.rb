module Jekyll
  module FormatDateFilter
    MONTHS = {
      '1' => 'jan',
      '2' => 'feb',
      '3' => 'mars',
      '4' => 'april',
      '5' => 'mai',
      '6' => 'juni',
      '7' => 'juli',
      '8' => 'aug',
      '9' => 'sep',
      '10' => 'okt',
      '11' => 'nov',
      '12' => 'des'
    }.freeze

    def format_date(date)
      day = date.strftime('%d')
      month = MONTHS[date.strftime('%-m')]
      year = date.strftime('%Y')

      "#{day}.\n#{month}\n#{year}"
    end
  end
end

Liquid::Template.register_filter(Jekyll::FormatDateFilter)
