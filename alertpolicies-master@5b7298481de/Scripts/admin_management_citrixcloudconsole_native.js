/*
Synthetics script to simulate administrator management through Citrix Cloud console through TOTP login  
*/
var totpLoginUrl = "{{SiteUrl}}";
var totpUsername = {{Username}};
var totpPassword = {{Password}};
var totp = {{Totp}};
var codeGenerator = $secure.ATHENA_TOTP_FUNCTION_CODE;
var totpUrl = `https://twostepsauthenticator.azurewebsites.net/api/CodeGenerator?code=${codeGenerator}&secret=${totp}`;
var emailToInvite = "";

var urllib = require('urllib');

var thisStep = 1;

/** HELPER VARIABLES AND FUNCTIONS **/

{{PrerequisitesScript}}

{{UtilityScript}}

{{TempEmailServiceScript}}

{{AdminTotpLoginScript}}

{{DeleteAdminsHelperScript}}

// Login
adminTotpLogin(totpLoginUrl, totpUsername, totpPassword, totpUrl)
.then(() => {
    $browser.wait(() => {
        log(thisStep++, 'Open menu');
        return $browser.findElement(By.css('.navigation-dropdown>div:first-of-type'), defaultTimeout)
        .then(function (el) { el.click(); })
        .then(function () {
            log(thisStep++, 'Open "Identity and Access Management"');
            return $browser.findElement(By.xpath("//span[text()=\'Identity and Access Management\']"), defaultTimeout);
        })
        .then(function (el) { el.click(); })
        .then(function () {
            log(thisStep++, 'Open "Administrators" tab');
            return $browser.findElement(By.xpath("//span[text()=\'Administrators\']"), defaultTimeout);
        })
        .then(function (el) { el.click(); })
        .then(() => {
            return $browser.findElement(By.xpath("//span[contains(@class, 'ctx-administrators-toolbar')]"))
        })
        .then(() => {
            return true;
        })
        .catch(err => {
            console.log("tab navigation fails, retrying...");
            return false;
        })
    }) 
})
// Clean up
.then(function () {
    log(thisStep++, 'Clean up admins');
    return deleteAdminsBulk();
})

// Send invite
.then(function () {
    log(thisStep++, 'Click on "Select an identity provider"');
    return $browser.waitForAndFindElement(By.xpath("//*[contains(text(), 'Add administrators from...')]"), defaultTimeout);
})

.then(function (el) {
    el.click();
    $browser.sleep(2000); // Wait for animation
    return $browser.wait(function () {
        return $browser.findElement(By.xpath("//div[contains(@class,'ctx-menu-item')][text()[contains(.,'Citrix Identity')] or text()[contains(.,'Citrix Cloud Government Identity')]]")).isDisplayed()
        .then(function (displayed) {
            if (!displayed) {
                console.log("Trying to open identity provider dropdown again")
                el.click();
                $browser.sleep(2000); // Wait for animation
            }
            return displayed;
        });
    });
})

.then(function () {
    log(thisStep++, 'Select "Citrix Identity"');
    return $browser.findElement(By.xpath("//div[contains(@class,'ctx-menu-item')][text()[contains(.,'Citrix Identity')] or text()[contains(.,'Citrix Cloud Government Identity')]]")).click();
})

.then(function () {
    log(thisStep++, 'Wait for email field to show up');
    return $browser.waitForAndFindElement(By.css('input.ctx-administrators-citrix-invite-form-input'), defaultTimeout);
})

.then(function () {
    return getTempEmailAddress()
    .then(function (email) {
        emailToInvite = email;
    });
})

.then(function () {
    log(thisStep++, 'Find "Email Address" field');
    return $browser.waitForAndFindElement(By.css('input.ctx-administrators-citrix-invite-form-input'), defaultTimeout);
})

.then(function (el) {
    el.clear();
    el.sendKeys(emailToInvite);
})

.then(function () {
    log(thisStep++, 'Click on "Invite"');
    return $browser.waitForAndFindElement(By.css('ctx-button.ctx-administrators-citrix-invite-form-invite-button'), defaultTimeout);
})

.then(function (el) {
    el.click();
    $browser.sleep(2000); // Wait for animation
})

.then(function () {
    log(thisStep++, 'Click on "Send Invite"');
    return $browser.waitForAndFindElement(By.css('ctx-button.ctx-modal-content-buttons-button.primary'), defaultTimeout);
})

.then(function (el) {
    el.click();
    $browser.sleep(1000); // Wait for animation
    return $browser.wait(function () {
        return $browser.findElements(By.css('ctx-button.ctx-modal-content-buttons-button.primary'))
        .then(function (elements) {
            if (elements.length == 0)
                return true;
            console.log("Trying to click on 'Send Invite' again")
            el.click();
            $browser.sleep(1000); // Wait for animation
            return false;
        });
    });
})

.then(function () {
    log(thisStep++, 'Wait for "Invite sent"');
    return $browser.waitForAndFindElement(By.xpath(`//ctx-static-grid-cell[normalize-space(text()) = '${emailToInvite}']//following-sibling::ctx-static-grid-cell/span/span[normalize-space(text()) = 'Invite Sent']`), defaultTimeout);
})

.then(function () {
    log(thisStep++, 'Call clickOnJoinCitrixCloudEmail to click on Citrix Cloud email');
    return clickOnJoinCitrixCloudEmail(emailToInvite);
})

// Refresh
.then(function () {
    log(thisStep++, 'Refresh list of administrators');
    return $browser.waitForAndFindElement(By.xpath("//span[text()='Refresh']"), defaultTimeout);
})

.then(function (el) {
    el.click();
    $browser.sleep(2000);
})

.then(function () {
    log(thisStep++, 'Wait for refresh to complete');
    return $browser.waitForAndFindElement(By.xpath("//span[text()='Refresh']"), defaultTimeout);
})

// Edit user's permission
.then(function () {
    log(thisStep++, 'Click on context menu');
    return $browser.waitForAndFindElement(By.xpath(`//ctx-static-grid-cell[normalize-space(text()) = '${emailToInvite}']//following-sibling::ctx-static-grid-cell//ctx-context-menu`), defaultTimeout);
})

.then(function (contextMenu) {
    contextMenu.click();
    return $browser.wait(function () {
        return $browser.findElements(By.xpath(`//ctx-static-grid-cell[normalize-space(text()) = '${emailToInvite}']//following-sibling::ctx-static-grid-cell//ctx-dropdown-menu-item/div[text()[contains(.,'Edit Access')]]`))
        .then(async function (elements) {
            var isDisplayed = await elements[0].isDisplayed();
            if (elements.length > 0 && isDisplayed)
                return true;
            console.log("Trying to open context menu again")
            contextMenu.click();
            return false;
        });
    }, defaultTimeout);
})

.then(function () {
    log(thisStep++, 'Click on "Edit Access"');
    return $browser.waitForAndFindElement(By.xpath(`//ctx-static-grid-cell[normalize-space(text()) = '${emailToInvite}']//following-sibling::ctx-static-grid-cell//ctx-dropdown-menu-item/div[text()[contains(.,'Edit Access')]]`), defaultTimeout);
})

.then(function (el) {
    el.click();
    $browser.sleep(2000);
})

.then(function () {
    log(thisStep++, 'Select "Custom Access"');
    return $browser.waitForAndFindElement(By.xpath("//div[text()='Custom access']//preceding-sibling::ctx-radio-button"), defaultTimeout);
})

.then(function (el) { el.click(); })

.then(function () {
    log(thisStep++, 'Select "General Management"');
    return $browser.waitForAndFindElement(By.xpath("//div[normalize-space(text())='General Management']//preceding-sibling::ctx-checkbox"), defaultTimeout);
})

.then(function (el) { el.click(); })

.then(function () {
    log(thisStep++, 'Click on "Save"');
    return $browser.waitForAndFindElement(By.xpath("//ctx-edit-access//ctx-button[contains(@class,'primary')]"), defaultTimeout);
})

.then(function (el) { el.click(); })

.then(function () {
    log(thisStep++, 'Wait for "Admin access successfully updated." to show up');
    return $browser.waitForAndFindElement(By.xpath("//span[text()='Admin access successfully updated.']"), defaultTimeout);
})

.then(function () {
    log(thisStep++, 'Click on "go back"');
    return $browser.waitForAndFindElement(By.css('ctxicon.shell-back-button'), defaultTimeout);
})

.then(function (el) { el.click(); })

// Delete the invited admin
.then(function () {
    log(thisStep++, 'Click on context menu');
    return $browser.waitForAndFindElement(By.xpath(
        `//ctx-static-grid-cell[normalize-space(text()) = '${emailToInvite}']//following-sibling::ctx-static-grid-cell//ctx-context-menu`),
        defaultTimeout);
})

.then(function (contextMenu) {
    contextMenu.click();
    return $browser.wait(function() {
        return $browser.findElements(By.xpath(`//ctx-static-grid-cell[normalize-space(text()) = '${emailToInvite}']//following-sibling::ctx-static-grid-cell//ctx-dropdown-menu-item/div[text()[contains(.,'Delete Administrator')]]`))
        .then(async function (elements) {
            var isDisplayed = await elements[0].isDisplayed();
            if (elements.length > 0 && isDisplayed)
                return true;
            console.log("Trying to open context menu again")
            contextMenu.click();
            return false;
        });
    }, defaultTimeout);
})

.then(function () {
    log(thisStep++, 'Click on "Delete Administrator"');
    return $browser.waitForAndFindElement(By.xpath(`//ctx-static-grid-cell[normalize-space(text()) = '${emailToInvite}']//following-sibling::ctx-static-grid-cell//ctx-dropdown-menu-item/div[text()[contains(.,'Delete Administrator')]]`), defaultTimeout);
})

.then(function (deleteAdminElement) {
    deleteAdminElement.click();
    log(thisStep++, 'Click on "Delete"');
    return $browser.wait(function () {
        return $browser.findElements(By.css('ctx-button.primary'))
        .then(async function (confirmElements) {
            var isDisplayed = await confirmElements[0].isDisplayed();
            if (confirmElements.length == 0 || !isDisplayed) {
                console.log("Trying to click on 'Delete Administrator' again");
                deleteAdminElement.click();
                return false;
            }
            return true;
        });
    }, defaultTimeout);
})

.then(function () {
    log(thisStep++, 'Confirm administrator removal');
    return $browser.findElement(By.css('ctx-button.primary')).click();
})

.then(function () {
    log(thisStep++, 'Wait for admin to be removed');
    return $browser.wait(function () {
        return $browser.findElements(By.xpath(`//ctx-static-grid-cell[normalize-space(text()) = '${emailToInvite}']`))
        .then(function (elements) {
            return elements.length == 0;
        });
    }, defaultTimeout);
})

.then(function () {
    log(lastStep, '');
    $browser.takeScreenshot();
    console.log('Browser script execution SUCCEEDED.');
}, function (err) {
    if (typeof err === 'string' && (err.includes("getTempEmailAddress") || err.includes("clickOnJoinCitrixCloudEmail")) && !err.includes("Citrix Cloud")) {
        console.log("Email script failed. Considering this a false-positive. Error: " + err);
        return;
    } else if (err instanceof TotpLoginError) {
        console.log('Browser script execution BYPASSED due to persistent totp login errors. Error:' + err);
        return;
    }
    console.log('Browser script execution FAILED.');
    throw (err);
});