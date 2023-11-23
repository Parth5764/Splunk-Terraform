/*
    Summary:
        Script to login into Citix Cloud Console using TOTP.
    Requirements:
        * Script can only be injected in a NewRelic Scripted Browser monitor.
        * Script expects 'utility.js' and 'scriptedbrowser_prerequisites.js' to be already injected.
    Usage:
        * adminTotpLogin(loginUrl, username, password, totpUrl) => Navigates to 'loginUrl',
            login using 'username' and 'password' and get TOTP from 'totpUrl'.
*/

function TotpLoginError(message) {
    this.name = "TotpLoginError";
    this.message = message;
    this.stack = (new Error()).stack;
}
TotpLoginError.prototype = new Error;

function adminTotpLogin(loginUrl, username, password, totpUrl) {
    var thisStep = 1;
    return $browser.getCapabilities().then(function () { })
    .then(() => {
        log(thisStep++, 'adminTotpLogin: $browser.get("' + loginUrl + '")');
        if (loginUrl.indexOf(".jp") !== -1) {
            var isInternalCookie = {
                "name": "X-Cws-Idp-Env",
                "value": "1",
                "domain": ".cloud.com",
                "path": "/",
                "secure": true,
                "httpOnly": true
            }
            return $browser.get(loginUrl)
                .then(() => $browser.manage().deleteAllCookies())
                .then(() => $browser.manage().addCookie(isInternalCookie))
                .then(() => $browser.get(loginUrl))
        }
        return $browser.get(loginUrl);
    })
    .then(() => {
        return $browser.getCurrentUrl()
    })
    .then((url) => {
        console.log("Before : " + url);
    })
    .then(() => {
        log(thisStep++, 'adminTotpLogin: wait for element "username"' + username);
        return $browser.waitForAndFindElement(By.name("username"), defaultTimeout);
    })
    .then(() => {
        log(thisStep++, 'adminTotpLogin: setElementText "username" ' + username);
        return $browser.waitForAndFindElement(By.name("username"), defaultTimeout);
    })
    .then(el => {
        el.clear();
        el.sendKeys(username);
    })
    .then(() => {
        log(thisStep++, 'adminTotpLogin: setElementText "password"');
        return $browser.waitForAndFindElement(By.name("password"), defaultTimeout);
    })
    .then(el => {
        el.clear();
        el.sendKeys(password);
    })
    .then(() => {
        log(thisStep++, 'adminTotpLogin: clickElement "submit"');
        return $browser.findElement(By.xpath('//*[(@id="submit") or (@class="btn btn-default credentials-submit ")]'));
    })
    .then(el => { el.click(); })
    .then(() => {
        if (loginUrl.indexOf(".us") === -1) {
            var retryOnce = false
            return $browser.wait(() => {
                log(thisStep++, 'adminTotpLogin: setElementText "code"');
                urllib.request(totpUrl).then(code => {
                    var codeStr = code['data'].toString();
                    var j = 1;
                    var xpath = '';
                    for (var i of codeStr) {
                        xpath = '//*[@class="ctx-input-digits"]/input[' + j + ']';
                        $browser.findElement($driver.By.xpath(xpath)).sendKeys(i);
                        j++;
                    }
                })
                return $browser.findElement(By.xpath('//*[(@id="verify-totp-code") or (@class="ctx-body-continue-button")]'))
                .then(el => {
                    log(thisStep++, 'adminTotpLogin: clickElement "Verify"');
                    $browser.wait($driver.until.elementIsEnabled(el), defaultTimeout)
                    el.click();
                    log(thisStep++, 'adminTotpLogin: wait for dashboard page load');
                    $browser.waitForAndFindElement(By.className("cwc-navbar"), 20000);
                })
                .then(() => {
                    return true;
                })
                .catch (err => {
                    if (retryOnce) {
                        throw err;
                    } else {
                        console.log('TOTP code has expired or something went wrong, retrying TOTP...');
                        retryOnce = true;
                        return false;
                    }
                })
            })
        } else {
            log(thisStep++, 'adminTotpLogin: wait for dashboard page load');
            return $browser.waitForAndFindElement(By.className("cwc-navbar"), defaultTimeout);
        }
    })
    .catch(err => {
        throw new TotpLoginError(err)
    })
}