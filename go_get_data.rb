require 'open-uri'
require 'nokogiri'

SITE = 'http://web.metro.taipei/RidershipCounts/E/'
CLOSE = 'e.htm'
YEARS = ('85'..'105').to_a
FIRST_YEAR_MONTHS = ('03'..'12').to_a
LAST_YEAR_MONTHS = ('01'..'03').to_a
MONTHS = ('01'..'12').to_a

result = "year,month,date,day_of_week,count\n"

YEARS.each do |year|
  months =
  if year == '85' then FIRST_YEAR_MONTHS
  elsif year == '105' then LAST_YEAR_MONTHS
  else MONTHS
  end
  months.each do |month|
    url = SITE + year + month + CLOSE
    doc = open(url).read
    doc = Nokogiri::HTML doc
    data = doc.css('tr').map do |row|
      row.css('td').map(&:text).map(&:strip)
    end
    data.each do |day|
      next unless day.length == 3
      count = day[2].tr(',', '').to_i
      next if count == 0
      # ap day
      year_english = year.to_i + 1911
      month_date = day[0].split('.')
      my_month, date = month_date
      dow = day[1].strip
      result << "#{year_english},#{my_month},#{date},#{dow},#{count}\n"
    end
  end
end

f = File.new('metro_data_by_day.csv', 'w+')
f.write result
f.close
