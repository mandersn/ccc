require "selenium/webdriver"
require "yaml"

credentials = YAML.load_file('config/sauce.yml')

caps = {
  :platform => "Linux",
  :browserName => "Firefox",
  :version => "45.0",
  :name => "Header Color Test"
}

driver = Selenium::WebDriver.for(:remote,
	:url => "https://#{credentials['username']}:#{credentials['access_key']}@ondemand.saucelabs.com:443/wd/hub",
	:desired_capabilities => caps)

driver.get('http://creditcards.com/')

controlhash = Hash.new
#controlhash["CardMatch™"] = []
#controlhash["Card Category"] = [
#  "Best Credit Cards","Rewards","Sign Up Bonuses","Cash Back",
#  "Balance Transfer","0% APR","No Annual Fee","Low Interest",
#  "Travel","Airline","Hotel","No Foreign Transaction Fee",
#  "Business","Student","Gas"]
#controlhash["Card Issuer"] = [
#  "American Express","Bank of America","Capital One","Chase",
#  "Citi","Discover","HSBC","Wells Fargo",
#  "Visa","Mastercard"]
#controlhash["Credit Range"] = [
#  "Excellent Credit","Good Credit","Fair Credit","Bad Credit",
#  "Secured Credit Cards","Limited or No Credit History","Debit & Prepaid Cards"]
#controlhash["Resources"] = [
#  "News & Advice","Reviews","Glossary","Calculators","CardMatch™"]

menu = driver.find_element(:xpath,"//header[@class='boxy__menu transparent-nav']")
menulist = menu.find_elements(:class,'menu__item')

menulist.each do |menuitem|
  menuitemtext = menuitem.text #this is getting lost in the find_elements call
  controlhash[menuitemtext] = Array.new
  driver.action.move_to(menuitem).perform
  submenulist = menuitem.find_elements(:class,'menu__link')
  submenulist.each do |submenuitem|
    controlhash[menuitemtext].push submenuitem.text
  end
end

# Move the screen so that the menu goes blue
culink = driver.find_element(:link,"Contact Us")
culink.location_once_scrolled_into_view

bluemenu = driver.find_element(:xpath,"//header[@class='boxy__menu']")
bluemenulist = bluemenu.find_elements(:class,'menu__item')

if bluemenulist.length != controlhash.length
  controlhash.keys.each do |menuitem|
    begin
      bluemenu.find_element(:link,menuitem)
    rescue Selenium::WebDriver::Error::NoSuchElementError
      puts "#{menuitem} menu in transparent menu bar, but not in blue menu bar"
      # If we are missing a menu, that's going to cause other problems later
      driver.quit
      exit
    end
  end

  bluemenulist.each do |menuitem|
    controlhash.fetch(menuitem.text) { |key|
      puts "#{key} menu in blue menu bar, but not in transparent menu bar"
      #when I tested this against set controlhash, this actually caused errors later
      driver.quit
      exit
    }
  end
end

bluemenulist.each do |bluemenulistitem|
  bluesubmenulist = bluemenulistitem.find_elements(:class,'menu__link')
  if bluesubmenulist.length > controlhash[bluemenulistitem.text].length
    #there should be a way to determine what the extra menuitem is
    puts "#{bluemenulistitem.text} menu had an unexpected option in the blue menu bar"
  end

  driver.action.move_to(bluemenulistitem).perform

  controlhash[bluemenulistitem.text].each do |bluesubmenuitem|
    begin
      bluemenulistitem.find_element(:link_text,bluesubmenuitem)
    rescue Selenium::WebDriver::Error::NoSuchElementError
      puts "#{bluesubmenuitem} is in the transparent #{bluemenulistitem.text} menu, but not the blue one"
    end
  end
end

driver.quit
