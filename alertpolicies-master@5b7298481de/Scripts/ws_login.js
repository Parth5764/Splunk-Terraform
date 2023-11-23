/*
    Summary:
        Script to login to Workspace using a username and password.
    Requirements:
        * Script can only be injected in a NewRelic Scripted Browser monitor.
        * Script expects 'utility.js' and 'scriptedbrowser_prerequisites.js' to be already injected.
    Usage:
        * wsLogin(url, username, password, loginType) => Returns a promise that when resolved
            will have the specified user logged in to the Workspace url using the indicated password.
            It returns a string, either WS_TYPE_WORKSPACE or WS_TYPE_SFAAS to indicate what type of Workspace
            environment was logged into (Workspace of StoreFront as a Service). Valid loginType values are
            'ad', for Active Directory, or 'nsg' for Netscaler Gateway. All input parameters should be strings.
            Other functions are intended to be internal use only.
*/

const AD_LOGIN = "ad";
const NSG_LOGIN = "nsg";
const WS_TYPE_WORKSPACE = "workspace";
const WS_TYPE_SFAAS = "sfaas";
const KNOWN_ELEMENT_CLASS_WORKSPACE = 'application_d58ggt';
const KNOWN_ELEMENT_CLASS_SFAAS = "home-view-content";

function commonLogin(url, username, password, usernameField, passwordField, loginButtonId) {
    var step = 0;
    return $browser.getCapabilities()
        // Step 1
        .then(function () {
            log(++step, 'wsLogin: $browser.get("' + url + '")');
            $browser.takeScreenshot();
            return $browser.get(url);
        })

        // Step 2
        .then(function () {
            log(++step, 'wsLogin: setElementText "' + usernameField + '"');
            return $browser.waitForAndFindElement(By.name(usernameField), defaultTimeout);
        })
        .then(function (el) {
            el.clear();
            el.sendKeys(username);
        })

        // Step 3
        .then(function () {
            log(++step, 'wsLogin: setElementText "' + passwordField + '"');
            return $browser.waitForAndFindElement(By.name(passwordField), defaultTimeout);
        })
        .then(function (el) {
            el.clear();
            el.sendKeys(password);
        })

        // Step 4
        .then(function () {
            log(++step, 'wsLogin: clickElement "submit"');
            return $browser.waitForAndFindElement(By.id(loginButtonId), defaultTimeout);
        })
        .then(function (el) { el.click(); })

        // Step 5
        .then(function () {
            log(++step, 'wsLogin: wait for known element after login');
            $browser.sleep(2000); // Wait for animation
            return $browser.waitForAndFindElement(By.xpath(`//div[contains(@class, '${KNOWN_ELEMENT_CLASS_WORKSPACE}') or contains(@class, '${KNOWN_ELEMENT_CLASS_SFAAS}')]`), defaultTimeout);
        }, function (err) {
            $browser.takeScreenshot();
            log(step, 'wsLogin: Did not find expected element after login');
            throw ('wsLogin: Did not find expected element after login');
        })

        // Step 6
        .then(async function (el) {
            var className = await el.getAttribute("class");
            if (className.search(KNOWN_ELEMENT_CLASS_SFAAS) >= 0) {
                log(++step, `wsLogin: Detected Workspace type "${WS_TYPE_SFAAS}"`);
                return WS_TYPE_SFAAS;
            }
            log(++step, `wsLogin: Detected Workspace type "${WS_TYPE_WORKSPACE}"`);
            return WS_TYPE_WORKSPACE;
        });
}

function nsgLogin(url, username, password) {
    return commonLogin(url, username, password, "login", "passwd", "nsg-x1-logon-button");
}

function adLogin(url, username, password) {
    return commonLogin(url, username, password, "username", "password", "loginBtn");
};

function wsLogin(url, username, password, loginType = AD_LOGIN) {
    if (loginType.toLocaleLowerCase() === NSG_LOGIN) {
        return nsgLogin(url, username, password);
    } else {
        return adLogin(url, username, password);
    }
}
