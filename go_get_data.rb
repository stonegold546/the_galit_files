require 'open-uri'
require 'nokogiri'

SITE = 'http://web.metro.taipei/RidershipCounts/E/'
CLOSE = 'e.htm'
YEARS = ('85'..'105').to_a
FIRST_YEAR_MONTHS = ('03'..'12').to_a
LAST_YEAR_MONTHS = ('01'..'03').to_a
REGULAR_MONTHS = ('01'..'12').to_a
DELETE_COMMA = [',', '']
REMOVE_DOTS_IN_DATES = '.'
THE_YEAR_THE_WORLD_BEGAN = 1911

result = "year,month,date,day_of_week,count\n"

YEARS.each do |year|
  months =
  if year == '85' then FIRST_YEAR_MONTHS
  elsif year == '105' then LAST_YEAR_MONTHS
  else REGULAR_MONTHS
  end
  months.each do |month|
    url = SITE + year + month + CLOSE
    doc = open(url).read
    doc = Nokogiri::HTML doc
    data = doc.css('tr').map { |row| row.css('td').map(&:text).map(&:strip) }
    data.each do |day|
      next unless day.length == 3
      count = day[2].tr(*DELETE_COMMA).to_i
      next if count == 0
      year_english = year.to_i + THE_YEAR_THE_WORLD_BEGAN
      month_date = day[0].split REMOVE_DOTS_IN_DATES
      my_month, date = month_date
      my_month = Date::ABBR_MONTHNAMES.find_index my_month
      dow = day[1].strip
      result << "#{year_english},#{my_month},#{date},#{dow},#{count}\n"
    end
  end
end

f = File.new('metro_data_by_day.csv', 'w+')
f.write result
f.close
