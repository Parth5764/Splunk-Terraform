const request = require('request');

// Based on https://code.citrite.net/projects/WS/repos/workspace-platform-synthetics/browse/Wsp-Monitor-AD-EndUser-CVAD-App-Launch.js

{{UtilityScript}}

{{PrerequisitesScript}}

{{WsLoginScript}}

var siteUrl = "{{SiteUrl}}";
var username = {{Username}};
var password = {{Password}};
var loginType = "{{LoginType}}";

// After login, this will either be
// WS_TYPE_SFAAS for StoreFront as a Service, or
// WS_TYPE_WORKSPACE for Citrix-managed Workspace
var workspaceType;

function getToAllApps(wsType) {
    if (wsType === WS_TYPE_SFAAS) {
        log(prevStep + 1, 'Find Apps Button');
        return $browser.waitForAndFindElement(By.xpath("//a[@id='allAppsBtn']"), defaultTimeout)
            .then(function(appsButton) {
                log(prevStep + 1, 'Click Apps Button');
                appsButton.click();
            });
    }
    log(prevStep + 1, 'Navigate to "' + siteUrl + '/Citrix/StoreWeb/#/apps/all"');
    return $browser.navigate().to(siteUrl + "/Citrix/StoreWeb/#/apps/all");
}

function verifyAppsPage(wsType) {
    if (wsType === WS_TYPE_SFAAS) {
        log(prevStep + 1, 'waitForAndFindElement "store-apps-container"');
        return $browser.waitForAndFindElement(By.css("div[class^='store-apps-container']"), defaultTimeout);
    }
    log(prevStep + 1, 'waitForAndFindElement "resources"');
    return $browser.waitForAndFindElement(By.css("div[class^='resources']"), defaultTimeout);
}

function findCalculator(wsType) {
    if (wsType === WS_TYPE_SFAAS) {
        log(prevStep + 1, 'waitForAndFindElement img "Calculator"');
        return $browser.waitForAndFindElement(By.xpath("//img[contains(@alt, 'Calculator')]"), defaultTimeout);
    }
    log(prevStep + 1, 'waitForAndFindElement div "Calculator"');
    return $browser.waitForAndFindElement(By.xpath("//div[contains(@title, 'Calculator')]"), defaultTimeout);
}

// Login to workspace
wsLogin(siteUrl, username, password, loginType)
    /** BEGINNING OF WSP SPECIFIC STEPS **/

    /** Steps from Wsp-Monitor-Staging-EU-AD-EndUser-CVAD-App-Enumeration to ensure applications is listed **/
    .then(function(wsType) {
        workspaceType = wsType;
        getToAllApps(workspaceType);
    })

    .then(() => verifyAppsPage(workspaceType))

    .then(() => findCalculator(workspaceType))

    /** Launch steps start here **/

    .then(function (calculator) {
        log(prevStep + 1, 'click "Calculator"');
        return calculator.click();
    })

    .then(function () {
        log(prevStep + 1, 'wait for there to be 2 tabs');
        $browser.wait(async () => (await $browser.getAllWindowHandles()).length === 2, defaultTimeout);
    })

    .then(function () {
        log(prevStep + 1, 'switch to second tab');
        $browser.getAllWindowHandles()
            .then(function (handles) {
                return $browser.switchTo().window(handles[1]);
            })
    })

    // The below step is given a longer timeout, as the step can be quite slow.
    .then(function () {
        log(prevStep + 1, 'wait for second tab to be named "Calculator"');
        $browser.wait($driver.until.titleIs('Calculator'), defaultTimeout * 2);
    })

    .then(function () {
        log(prevStep + 1, 'waitForAndFindElement "Session Canvas"');
        return $browser.waitForAndFindElement(By.id("CitrixSuperRenderCanvas"), defaultTimeout);
    })

    /** END OF WSP SPECIFIC STEPS **/

    .then(function () {
        log(lastStep, '');
        console.log('Browser script execution SUCCEEDED.');
    }, function (err) {
        $browser.takeScreenshot();
        console.log('Browser script execution FAILED.');
        throw (err);
    });

/** END OF SCRIPT **/