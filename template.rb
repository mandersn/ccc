require "selenium/webdriver"
require "yaml"

credentials = YAML.load_file('config/sauce.yml')

caps = {
  :platform => "Windows 7",
  :browserName => "Chrome",
  :version => "45",
  :name => "Template"
}

driver = Selenium::WebDriver.for(:remote,
	:url => "https://#{credentials['username']}:#{credentials['access_key']}@ondemand.saucelabs.com:443/wd/hub",
	:desired_capabilities => caps)

driver.get('http://creditcards.com/')

## test goes here

driver.quit()

