require 'selenium-webdriver'
require 'moji'
require_relative 'zen_to_han'

module GNF
  class JPX
    def initialize(driver: :phantomjs)
      @driver = Selenium::WebDriver.for driver
    end

    def info(code:)
      @driver.navigate.to 'http://www2.tse.or.jp/tseHpFront/JJK010010Action.do'
      @driver.find_element(:name, 'eqMgrCd').send_key(code)
      @driver.find_element(:name, 'searchButton').click
      sleep(0.2)
      @driver.find_element(:name, 'detail_button').click
      sleep(0.1)
      name = @driver.find_element(:xpath, '//div[@class="boxOptListed05"]/h3').text
      name = name.zen_to_han.gsub('（株）', '').gsub(/ホールディングス$/, '')
      code = @driver.find_element(:xpath, '//th[text()="コード"]/../following-sibling::tr/td[1]').text[0..3].to_i
      isin = @driver.find_element(:xpath, '//th[text()="ISINコード"]/../following-sibling::tr/td[2]').text
      isin.strip
      {code: code, name: name, isin: isin}
    rescue => e
      p e
      return
    end
  end
end