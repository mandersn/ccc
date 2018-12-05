# ccc
This repository represents some coding practice that I am doing as I look for a job this month.

## Setup
This section describes both how I set up an environment to develop my test scripts as well as how I would expect someone to set up an environment to review my scripts.

### Environmental Setup
I wanted an environment where anyone would be able to run my code with easy instructions.  Therefore, I set up a free AWS account and created an EC2 instance (Amazon Linux AMI 2018.03.0 (HVM), SSD Volume Type - ami-023c8dbf8268fb3ca), of which only the t2.micro was Free tier eligible.  I used the default options, except for restricting access to my IP address.


First, I logged into the instance and installed some software that would be necessary, gcc to compile gems and git in order to interact with GitHub:

    $ sudo yum install gcc
    $ sudo yum install git


Next,I followed the instructions at https://rvm.io to install rvm, the third command coming from the output of the second:

    $ gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
    $ \curl -sSL https://get.rvm.io | bash -s stable
    $ source /home/ec2-user/.rvm/scripts/rvm


Installing rvm in the previous step allowed me to install the development version of ruby:

    $ rvm intall ruby-dev


I then installed the following ruby gems that would be necessary to interact with SauceLabs using Selenium Webdriver:

    $ gem install selenium-webdriver
    $ gem install sauce_whisk

I also installed the ASW sdk gem, which I doubt is necessary but include here for completeness:

    $ gem install aws-sdk

### SauceLabs Setup
In order to run these tests, you will need a trial account on SauceLabs.  They will provide the cloud-based virtual machines with various Operating Systems and Browsers that will be used.  The trial account will provide you with 100 minutes per month, which should be plenty of time to evaluate this code.

Go to [SauceLabs.com](https://saucelabs.com).  Click on the **Sign In** icon in the upper right corner, *not* the **Free Trial** icon.  Next, below the normal Sign In fields, click on the "[Login with your GitHub account]([https://saucelabs.com/oauth/login/github)" link.  I believe that this was sufficient to create a trial account login for SauceLabs, but it was a simple process for me even if it is not that simple.

Once you are signed into SauceLabs, you will find your username in the upper right-hand corner.  You will need to select "My Account" from that dropdown menu.  Midway down the page is the **Access Key** section which will copy to your clipboard if you click on it.  You will need your Access Key and username in the next section.

### Code Setup
Once you have your environment setup at AWS, you will need to clone this repository.

After cloning, go into the config directory and copy the sauce.yml.sample file to sauce.yml and edit it.  Change the second occurance of username on the first line to your actual username and change the string of *x*'s and hypens on the second line to your actual Access Key that you copied from the SauceLabs website in the previous step.  

## Test Execution
I chose not to use a framework like rSpec or Cucumber to write my tests.  Either would have provided additional structure and made them look more like tests, but also would have made the code less readable.

### Running the Tests
In order to run all of the tests, go to the top directory of the cloned repository and run:

    $ ruby *-test.rb

They can also be run individually using a similar command, such as:

    $ ruby footer-links-test.rb

### Seeing the Results
Since I did not use a framework, the results will just appear at the command-line.  In a real testing environment, they would be formatted by the framework to appear in Jenkins.

If there is a failure or you have other reason for wanting to see screenshots of the test running, log into your [SauceLabs](https://saucelabs.com) account and click on the **Archives** area in the left menu.  You will see a list of the tests that you have run (with timestamps and other identifying information like OS and browser).  If you click on the name, you can see/download the screenshots or a video, or see the selenium logs from the test.

## Test Development
Automated Functional Tests are relatively expensive.  Most things should be covered my much less expensive unit and integration tests.  I expect most common functionality to be heavily trafficed by other tests (manual and automated) and not need it's own test; An example is that I don't think that we generally need a login test unless there is a weird login functionality that neither our normal automated functional tests nor our internal testers/developers/users use on a daily basis.  When I begin working with a development team that has little automation (or none), the first question I ask is "In which areas of the code are you scared to work?" and then I begin to automate around those areas because that fear is a gut reaction to the experience of things breaking or the possibility of things breaking.  In deciding what to test on the homepage I used that first principle of ignoring the well trafficed areas that are unlikely to produce bugs, but was not in contact with the development team for interviews so I used my past experience of doing manual exploratory testing to determine areas where I thought bugs were most likely to appear.

### Footer Links
The 13 links in the footer would be subject to link rot at many companies.  Someone might move a page and fix one link to it and forget about others.  On your website, the most obvious place that this could happen is with the three links in this section that go to the same [Contact Us](https://www.creditcards.com/contact/) page.

Another place that I would explore creating a similar test or tests would be the [Site Map](https://www.creditcards.com/sitemap/).  This appears to be another collection of links that could be subject to rot over time.  I would not necessarily run a test/suite for the Site Map as often as one for the Footer, because it is not as visible, but I would still like to report if a page (toward the bottom) moved or confirm that the correct people are informed when a category being displaying has become empty. 

#### Design
- Go to the homepage
- Collect a list of the links
- Iterate over the list of the links
  - click on the link
  - confirm that it did not go to the 404 page
  - print a status message
- Go to a page that we expect to generate the 404 page
  - confirm that the test for 404 works as expected (404 page has not changed)

I had forgotten that there was not an easy way to check the HTTP response code with Selenium Webdriver when I designed this test.  I know that the solution I created in it's place is suboptimal - if the page returns a different error response code, we would probably like to be notified.  I worry that other simple solutions that I thought up would break and create maintainability headaches anytime the pages or links are changed - we don't really need to keep an oracle about these pages in our tests.

#### Things I noticed
:eyes: Did someone important in your Marketing Department leave this Summer?  Both your [Blog](https://blogs.creditcards.com/) and [Media Center](https://www.creditcards.com/media-recap/) were regularly updated into early June, but haven't been updated in more than 5 months.  This is not a bug, just an observation.  [Press Releases](https://www.creditcards.com/about-us/press-releases/) have been updated and there is apparently a [News](https://www.creditcards.com/credit-card-news/marriott-starwood-data-breach.php) area that is being updated, but I didn't find it from the footer.

:bug: In writing up this report, I looked at the [Customer Support](https://www.creditcards.com/customer-support-department/) page for links to the [Contact Us](https://www.creditcards.com/contact/) page, thinking it would be a place where a link might not get changed.  At the bottom of the page it says "Still have questions? [Contact Customer Support.]()" but the link tag has an id with no href parameter, so it goes nowhere.  I would consider this a bug, but one with low severity.

### Header Menu Bar
As you scroll down the page, the Menu Bar turns blue.  Because I don't know how this works, I don't really trust it.  The second test that I am submitting creates a structured list (hash of arrays) of the menus and items in the original, transparent, menubar.  It then scrolls down and confirms that the same menus appear with the same items on the menu with the blue background.

#### Design
- Go to the homepage
- Create a list of the menus on the menu bar
- Create a hash with the keys as the text of the menu and the value as an array of the items appearing on the menu
- Scroll down the screen
- Confirm that the same menus appear at the bottom
- For each menu, confirm that it contains the same menu items

#### Things I noticed
:black_circle: SauceLabs does not always provide the same size browser.  It's not clear to me whether that is a feature of their service or just happens.
Because of the responsive design of the website under test, that meant that the **CardMatch™** menu sometimes moved into the **Resources** menu.  This was a problem at one point when I'd had trouble developing the hash of arrays from the transparent menubar through automation and was trying to use a static oracle in my code - sometimes I'd get a browser with 5 menus and other times 4 menus and it would have been difficult to automate if I hadn't figured out how to automate the creation of the datastructure so that I am testing what I wanted.
There are likely ways to set the browser size, and it would be good to create tests for the responsive design that confirm that the menu appears as expected at various resolutions.

:black_circle: SauceLabs trial accounts via GitHub account are based on the primary address of the GitHub account.  Again, not clear if this is a feature or just happens.  After I realized that my GitHub account was tied to an email address that I no longer use and changed it to my current address, I ended up needing to create a second trial account on SauceLabs.

### Other tests
#### Header Menu Links
I started work on this test and then evolved it into the above test that compares the transparent menu bar items to the blue menu bar items.  This test would have confirmed, like the test for the footer links, that all of the links from the menus were still good links.  I felt like it would have just taken additional time and duplicated code that I was alredy submitting.

#### Credit Score Menu
I never fully developed my idea for the fourth test.  It would have been around the menus that appear when you click on your credit score.  This looks like a feature that most users would use when they first arrive at the site, but one that might not be actively under development or internal use.

#### Transparent/Blue Menu Transition
In developing the test for the menu items, it seemed that there were times where the page was scrolled and the transparent menu still appeared instead of the blue one.  I noticed it, but did not take detailed notes.  This would have been an interesting test to tackle, trying to determine if there is an existing bug here and if it is one that automation could find and isolate.  The way that most companies write automation, I generally expect it to find degradations in working functionality.

## Towards a Framework
I have not created an automated testing framework, nor have I used one.  Here are some steps that I would take to move towards a framework if I had more time to work on this project:

### Extract Common Code
The most obvious thing to me is that there is common code between my two scripts.  Examples include:
- code that pulls credentials from the .yml config file
- code that creates defines and requests the virtual machine
- code that checks for error pages (was common with code worked on but not included)
All of this common code should be maintained in a single place so that it can't diverge and is easier to maintain.  This step would likely come naturally with some of the other adjustments that I would make, but a first step could be to move it into a file that is included in each script.

### Cross-Browser/Platform Support
The SauceLabs solution has built-in support for different devices, operating systems, browsers.  The three tests that I worked on ran on three different browsers on different OS, but each test script ran statically on the same setup each time.  In extracting the common code, I would want to set up an ability to pass a parameter to the test script asking for a specific available configuration and selecting one at random if none was requested.

### Object Oriented Code and Page Objects
My code is writen as scripts, with a bit of procedural code.  To get to a framework, I would certainly want to move to Object Oriented code.  I would want to move to a Page Object paradigm, where every page in the application is represented in the code as an object that knows how to perform the actions that might be done to it.  This quickly allows a change to the coding of a page to be updated in the automation code in one and only one place - for instance, a change to the 404 page could be a change to the 404 page object and everywhere in the automation that checks for a 404 page would reference that same code.

### Existing Frameworks
I chose not to use either Cucumber or rSpec as a wrapper for my code.  This is fine for a small suite of scripts, but as the suite grows to hundreds of tests we will want to be able to run them and see the results reported easily, by an automation server like Jenkins.  Cucumber is a nice solution to this if non-technical people will want to participate in test creation or review.  rSpec is a reasonable solution otherwise.

### Retrying Failures and Faster Tests
SauceLabs takes screenshots as the tests run.  They are great for later review when tests fail, but are rarely reviewed when tests pass, and they add time to the test.  There is a parameter that allows us to turn off the screenshots when we run the tests.  As we get more tests we want to turn off the screenshots.  However, when a test fails I would have a way to immediately run it again with the screenshots turned on, providing a way to make sure that the test is really failing and giving us visibility into the failure.

### Result Tracking
As the test suite grows to thousands of tests, we want to start tracking results across test runs.  We want to know which tests never fail, both because they might be able to be run less often and because when they fail they should get immediate attention.  We want to know which tests failed their retries because they should also get attention.  Finally, we want to know which tests frequenly fail and then pass their retries because they also deserve some attention as they point to either a problem with the test or a rare problem with the system being tested and either one should be reported and fixed.

### Multiple Suites
I would need to understand deploy processes better, but it frequently is better if there are multiple test suites that may run in parallel and may be run stand alone and may not always run.  As a first order, there should be a suite of smoke tests that runs quickly after each deploy of the software to a server.  It should be hearty enough to catch common and obvious failures.  It's first purpose is to prevent us from spending time running other tests against a release that is so bad that the results will not be worth reviewing.  Once a smoke suite exists, frequenly there are requests for it to be run for other purposes such as monitoring.

