require 'selenium-webdriver'
require 'moji'
require_relative 'zen_to_han'

module GNF
  class JPX
    def initialize(driver: :phantomjs)
      @driver = Selenium::WebDriver.for(driver)
    end

    def search(code:)
      @driver.navigate.to 'http://www2.tse.or.jp/tseHpFront/JJK010010Action.do'
      @driver.find_element(:name, 'eqMgrCd').send_key(code)
      @driver.find_element(:name, 'searchButton').click
      sleep(0.2)
      detail_button = @driver.find_element(:name, 'detail_button')
      return if detail_button.nil?
      detail_button.click
      sleep(0.1)
    end

    def info(code:)
      search(code: code)
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

    def disclosures(code:)
      search(code: code)
      @driver.find_element(:xpath, "//a[contains(.,'適時開示情報')]").click
      sleep(0.2)
      @driver.find_element(:xpath, "//input[@value='情報を閲覧する場合はこちら']").click
      @driver.find_elements(:xpath, "//td[@class='NormalBody']/table/tbody/tr")[2..-1].map do |row|
        disclosure_row_to_hash(row)
      end
    end

    def disclosure_row_to_hash(row)
      values = row.find_elements(:xpath, 'td')
      time = Date.parse(values[0].text)
      title = values[1].text.zen_to_han
      pdf = File.basename(values[1].find_element(:xpath, 'div/div/a').attribute(:href))
      {time: time, title: title, pdf: pdf}
    end
  end
end