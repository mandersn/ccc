require "selenium/webdriver"
require "yaml"

credentials = YAML.load_file('config/sauce.yml')

caps = {
  :platform => "Windows 7",
  :browserName => "Chrome",
  :version => "45",
  :name => "Footer Links Test"
}

driver = Selenium::WebDriver.for(:remote,
	:url => "https://#{credentials['username']}:#{credentials['access_key']}@ondemand.saucelabs.com:443/wd/hub",
	:desired_capabilities => caps)

def check404(driver)
  found=true
  begin
    driver.find_element(:class,'page-not-found__title')
  rescue Selenium::WebDriver::Error::NoSuchElementError
    #element not found
    found=false
  end
  found
end

def result404(found,item)
  if found
    puts "Link to \'#{item}\' loaded 404 page."
  else
    puts "Link to \'#{item}\' successfully loaded page."
  end
end

driver.get('http://creditcards.com/')

footer = driver.find_element(:class,'footer__linkListWrapper')
linklist = footer.find_elements(:class,'linkList__link')
linktext = linklist.map { |link| link.text }

linktext.each do |item|
  link = driver.find_element(:link,item)
  link.click

  result404(check404(driver), item)

  driver.navigate.back
end

driver.get('http://creditcards.com/mandersn-test')
puts "Control test failed - expected 404 page does not contain expected element" unless check404(driver)

driver.quit
