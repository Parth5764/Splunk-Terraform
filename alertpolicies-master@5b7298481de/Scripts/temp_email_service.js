/*
    Summary:
        Script to get a temporary email address and click on Citrix Cloud email.
    Requirements:
        * Script can only be injected in a NewRelic Scripted Browser monitor.
        * Script expects 'utility.js' and 'scriptedbrowser_prerequisites.js' to be already injected.
    Usage:
        * getTempEmailAddress(keepNewTabOpen = false) => Navigates to temporary email service, returns temporary email address and,
            when keepNewTabOpen = false, navigates browser back to where it was before function was called.
            Note: You may loose the email address if you clean the browser's cookies after you call this function.
        * clickOnJoinCitrixCloudEmail(email) => Access temp email service, find Citrix Cloud email, click on the link to join, create user and
            navigates browser back to where it was before function was called.
*/

var tempEmailServiceUrl = "https://www.sharklasers.com/";

function getTempEmailAddress(keepNewTabOpen = false) {
    var tempEmail = ""
    var thisStep = 1;

    return $browser.getTitle()

    .then(function (title) {
        console.log("Current window title: " + title)
        log(thisStep++, 'getTempEmailAddress: Create new tab');
        return $browser.executeScript("window.open();");
    })
    
    .then(function () {
        log(thisStep++, 'getTempEmailAddress: Go to new tab');
        return $browser.getAllWindowHandles()
        .then(function(tabs) {
            return $browser.switchTo().window(tabs[tabs.length - 1]);
        })
    })

    .then(function () {
        log(thisStep++, 'getTempEmailAddress: Navigate to ' + tempEmailServiceUrl);
        return $browser.get(tempEmailServiceUrl);
    })

    .then(function () {
        log(thisStep++, 'getTempEmailAddress: Scroll down');
        return $browser.executeScript("window.scrollTo(0, document.body.scrollHeight / 2);");
    })

    .then(function () {
        return $browser.getTitle().then(function(title) {
            console.log("Current window title: " + title)
            if (title.includes("502 Bad Gateway")) {
                console.log("502 detected! Trying to go to " + tempEmailServiceUrl + " again")
                $browser.sleep(2000);
                return $browser.get(tempEmailServiceUrl);
            }
        })
    })
    
    .then(function () {
        $browser.getTitle().then(function(title) { console.log("Current window title: " + title) } )
        log(thisStep++, 'getTempEmailAddress: Find email address');
        return $browser.waitForAndFindElement(By.xpath("//*[@id='email-widget']"), defaultTimeout);
    })
    .then(function (emailElement) {
        log(thisStep++, 'getTempEmailAddress: Get email address');
        return emailElement.getText().then(function (text) {
            tempEmail = text;
        })
    })

    .then(function () {
        if (!keepNewTabOpen) {
            log(thisStep++, 'getTempEmailAddress: Navigate to first tab');
            return $browser.getAllWindowHandles()
            .then(function(tabs) {
                return $browser.switchTo().window(tabs[0]);
            })
        }
    })

    .then(function () {
        $browser.getTitle().then(function(title) { console.log("Current window title: " + title) } )
        log(thisStep++, 'getTempEmailAddress: Return temporary email (' + tempEmail + ')');
        return tempEmail;
    }, function (err) {
        console.log('getTempEmailAddress FAILED.');
        throw('getTempEmailAddress FAILED. Error: ' + err);
    })
}

function clickOnJoinCitrixCloudEmail(email) {
    var firstName = "myfirstname";
    var lastName = "mylastname";
    var password = "A928jc88223jds$"; // Potentially use NewRelic Secret Store
    var thisStep = 1;

    // Navigate to email service and check if current email address is the same
    log(thisStep++, 'clickOnJoinCitrixCloudEmail: Access email service');

    getTempEmailAddress(true)

    .then(function (currentEmail) {
        log(thisStep++, 'clickOnJoinCitrixCloudEmail: Check if using the same email');
        if (currentEmail != email) {
            throw("Email is now different. Email requested is '" + email + "' but found '" + currentEmail + "'. Aborting.");
        }
        log(thisStep++, 'clickOnJoinCitrixCloudEmail: Look for Citrix Cloud email');
        return $browser.wait(function() {
          return $browser.findElements(By.xpath("//*[contains(text(), 'Join Citrix Cloud') or contains(text(), 'Citrix Cloud Government')]/.."))
          .then(function (elements) {
              console.log("Number of emails found: " + elements.length)
                return elements.length > 0;
            });
        }, defaultTimeout);
    })

    .then(function () {
        return $browser.findElements(By.xpath("//*[contains(text(), 'Join Citrix Cloud') or contains(text(), 'Citrix Cloud Government')]/.."))
    })

    .then(function (emailElements) {
        log(thisStep++, 'clickOnJoinCitrixCloudEmail: Open Citrix Cloud email');
        emailElements[0].click();
        return $browser.wait(function() {
            return $browser.findElements(By.xpath("//a[text()='Sign In']"))
            .then(function (elements) {
                if (elements.length > 0)
                    return true;
                console.log("Trying to open email again")
                emailElements[0].click();
                return false;
            });
        }, defaultTimeout);
    })

    .then(function () {
        log(thisStep++, 'clickOnJoinCitrixCloudEmail: Find email link');
        return $browser.waitForAndFindElement(By.xpath("//a[text()='Sign In']"), defaultTimeout);
    })

    .then(function (emailLink) {
        return emailLink.getAttribute("href")
        .then(function(link) {
            log(thisStep++, 'clickOnJoinCitrixCloudEmail: Navigate to email link: ' + link);
            return $browser.get(link);
        })
    })

    .then(function() {
        log(thisStep++, 'clickOnJoinCitrixCloudEmail: Wait for tab to be named "Citrix Cloud"');
        return $browser.wait($driver.until.titleIs('Citrix Cloud'), defaultTimeout);
    })

    // Handle any errors up to this point
    .then(function () {}, function(error) {
        $browser.takeScreenshot();
        throw("clickOnJoinCitrixCloudEmail failed before user creation steps. Error: " + error)
    })

    .then(function () {
        log(thisStep++, 'clickOnJoinCitrixCloudEmail: Wait for Citrix Cloud page to load');
        return $browser.wait(function() {
            return $browser.findElement(By.xpath("//input[@name='firstName']")).isDisplayed();
        }, defaultTimeout);
    })

    .then(function () {
        return $browser.getTitle().then(function(title) { console.log("Current window title: " + title) });
    })

    // Fill in Citrix Cloud new user form
    .then(function () {
        log(thisStep++, 'clickOnJoinCitrixCloudEmail: Fill first name');
        return $browser.waitForAndFindElement(By.xpath("//input[@name='firstName']"), defaultTimeout);
    })
    .then(function (el) {
        el.clear();
        el.sendKeys(firstName);
    })
    .then(function () {
        log(thisStep++, 'clickOnJoinCitrixCloudEmail: Fill last name');
        return $browser.waitForAndFindElement(By.xpath("//input[@name='lastName']"), defaultTimeout);
    })
    .then(function (el) {
        el.clear();
        el.sendKeys(lastName);
    })
    .then(function () {
        log(thisStep++, 'clickOnJoinCitrixCloudEmail: Fill password');
        return $browser.waitForAndFindElement(By.xpath("//input[@placeholder='Password']"), defaultTimeout);
    })
    .then(function (el) {
        el.clear();
        el.sendKeys(password);
    })
    .then(function () {
        log(thisStep++, 'clickOnJoinCitrixCloudEmail: Fill confirm password');
        return $browser.waitForAndFindElement(By.xpath("//input[@placeholder='Confirm Password']"), defaultTimeout);
    })
    .then(function (el) {
        el.clear();
        el.sendKeys(password);
    })
    .then(function () {
        log(thisStep++, 'clickOnJoinCitrixCloudEmail: Accept terms');
        return $browser.waitForAndFindElement(By.xpath("//div[@class='tos-check-box']/label"), defaultTimeout);
    })
    .then(function (el) {
        el.click();
    })
    .then(function () {
        log(thisStep++, 'clickOnJoinCitrixCloudEmail: Send form');
        return $browser.waitForAndFindElement(By.xpath("//button[normalize-space(text())='Continue']"), defaultTimeout);
    })
    .then(function (el) {
        el.click();
    })

    .then(function () {
        log(thisStep++, 'clickOnJoinCitrixCloudEmail: Confirm user was created');
        return $browser.wait(function() {
            return $browser.findElement(By.xpath("//button[normalize-space(text())='Sign In']")).isDisplayed();
        }, defaultTimeout);
    })

    .then(function () {
        log(thisStep++, 'clickOnJoinCitrixCloudEmail: Navigate to first tab so user can continue from where it left off');
        return $browser.getAllWindowHandles()
        .then(function(tabs) {
            return $browser.switchTo().window(tabs[0])
        });
    }, function(error) {
        if (typeof error !== 'string' || (typeof error === 'string' && !error.includes("clickOnJoinCitrixCloudEmail"))) {
            $browser.takeScreenshot();
            throw("Citrix Cloud user creation failed with: " + error);
        }
        throw(error);
    })

    .then(function () {
        $browser.getCurrentUrl().then(function(url) { console.log("Current URL: " + url) } )
    }, function (err) {
        console.log('clickOnJoinCitrixCloudEmail FAILED.');
        throw('clickOnJoinCitrixCloudEmail FAILED. Error: ' + err);
    })
}