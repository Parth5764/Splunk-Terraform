/*
    Summary:
        Script to delete administrators in Citrix Cloud Console using a XPATH query.
    Requirements:
        * Script can only be injected in a NewRelic Scripted Browser monitor.
        * Script expects 'utility.js' and 'scriptedbrowser_prerequisites.js' to be already injected.
        * Script expects browser to be already in the Citrix Cloud Console Admin page.
    Usage:
        * deleteAdminsBulk() => Find all administrators that were created due to past synthetics monitor run. Specifically with display 
            name as 'myfirstname mylastname', or with email that contains '@sharklasers.com' along with status 'Invite Sent'.
            If the number of qualified adminstrators are more than 1, use bulk delete action to clean up, otherwise skip.
        * deleteAdminsWithQuery(menuXpathQuery, deleteXpathQuery) => Get all administrators contexts menus with 'menuXpathQuery' and
            the delete menu with 'deleteXpathQuery' in order to delete each administrator.
*/

async function deleteAdminsBulk() {
    var thisStep = 1;
    var rowIndexesToSelect = [];
    log(thisStep++, "deleteAdminsBulk: Find admins to be removed");
    var gridCells = await getGridCells();
    for (var i = 0; i < gridCells.length; ++i) {
        var row = parseInt(i / 8, 10);
        var column = i % 8;

        // Check if display name column
        if (column == 2) {
            var displayName = await gridCells[i].getText();
            if (displayName.includes("myfirstname mylastname")) {
                rowIndexesToSelect.push(row);
            }
        }

        // Check if email column
        if (column == 3) {
            var email = await gridCells[i].getText();
            var status = await gridCells[i+1].getText();
            if (email.includes("@sharklasers.com") && status.includes("Invite Sent")) {
                rowIndexesToSelect.push(row);
            }
        }
    }

    if (rowIndexesToSelect.length < 2) {
        console.log("Less than 2 admins to be cleaned up. Skipping bulk deletion.");
        return;
    }

    log(thisStep++, "deleteAdminsBulk: Start deletion of " + rowIndexesToSelect.length + " admin(s)");
    for (var i = 0; i < rowIndexesToSelect.length; ++i) {
        await selectRow(rowIndexesToSelect[i]);
        await $browser.sleep(1000);
    }
    await bulkDelete();
}

function getGridCells() {
    return $browser.findElements(By.xpath("//ctx-static-grid/ctx-static-grid-cell[not(contains(@class,'table-header'))]"));
}

async function selectRow(rowIndex) {
    var index = rowIndex * 8;
    // Arrays in XPATH starts with 1
    var checkBox = await $browser.findElement(By.xpath("//ctx-static-grid/ctx-static-grid-cell[not(contains(@class,'table-header'))][" + (index + 1) + "]/ctx-checkbox"));
    return checkBox.click();
}

function deleteAdminsWithQuery(menuXpathQuery, deleteXpathQuery) {
    var thisStep = 1;
    log(thisStep++, 'deleteAdminsWithQuery: Get all administrators using XPATH query: ' + menuXpathQuery);
    return $browser.wait(function () {
        return $browser.findElements(By.xpath(menuXpathQuery))
            .then(async function (contextMenuElements) {
                console.log("contextMenuElements.length=" + contextMenuElements.length);
                if (contextMenuElements.length == 0)
                    return true;
                var isContextMenuBtnDisplayed = await contextMenuElements[0].isDisplayed();
                if (!isContextMenuBtnDisplayed) {
                    console.log("Context menu button element not displayed. Retrying.");
                    return false;
                }
                log(thisStep++, 'deleteAdminsWithQuery: Click on context menu');
                contextMenuElements[0].click();

                log(thisStep++, 'deleteAdminsWithQuery: Look for "Delete Administrator" menu');
                return $browser.waitForAndFindElement(By.xpath(deleteXpathQuery), defaultTimeout)
                    .then(function (deleteAdminMenu) {
                        log(thisStep++, 'deleteAdminsWithQuery: Click on "Delete Administrator" menu');
                        deleteAdminMenu.click();
                    })
                    .then(function () {
                        log(thisStep++, 'deleteAdminsWithQuery: Look for confirm button');
                        return $browser.waitForAndFindElement(By.css('ctx-button.primary'), defaultTimeout);
                    })
                    .then(function (confirmBtn) {
                        log(thisStep++, 'deleteAdminsWithQuery: Click on confirm button');
                        confirmBtn.click();
                    })
                    .then(function () {
                        log(thisStep++, 'deleteAdminsWithQuery: Refresh list of administrators');
                        return $browser.waitForAndFindElement(By.xpath("//span[text()='Refresh']"), defaultTimeout);
                    })
                    .then(function (refreshBtn) {
                        log(thisStep++, 'deleteAdminsWithQuery: Click to refresh');
                        refreshBtn.click();
                    })
                    .then(function () {
                        return $browser.sleep(2000);
                    })
                    .then(function () {
                        log(thisStep++, 'deleteAdminsWithQuery: Wait for refresh to finish');
                        return $browser.waitForAndFindElement(By.xpath("//span[text()='Refresh']"), defaultTimeout);
                    })
                    .then(function () {
                        console.log("Checking for any other administrator to be removed")
                        return false;
                    }, function (error) {
                        console.log("Retrying as step failed with: " + error)
                        return false;
                    })
            });
    }, defaultTimeout);
}

async function bulkDelete() {
    var thisStep = 1;
    log(thisStep++, 'bulkDelete: Find bulk actions dropdown');
    var bulkDropdown = await $browser.waitForAndFindElement(By.xpath("//div[text()[contains(.,'Bulk Actions')]]/../../.."), defaultTimeout);
    log(thisStep++, 'bulkDelete: Click on dropdown');
    bulkDropdown.click();
    log(thisStep++, 'bulkDelete: Find "Delete Administrators" menu');
    var deleteAdminMenu = await $browser.waitForAndFindElement(By.xpath("//ctx-dropdown-menu-item/div[contains(.,'Delete Administrators')]"), defaultTimeout);
    log(thisStep++, 'bulkDelete: Click on "Delete Administrators" menu');
    deleteAdminMenu.click();
    log(thisStep++, 'bulkDelete: Find confirm deletion button');
    var deleteButton = await $browser.waitForAndFindElement(By.css('ctx-button.primary'), defaultTimeout);
    log(thisStep++, 'bulkDelete: Click on deletion button');
    deleteButton.click();
    await $browser.sleep(2000);
    log(thisStep++, 'bulkDelete: Find refresh button');
    var refreshButton = await $browser.waitForAndFindElement(By.xpath("//span[text()='Refresh']"), defaultTimeout);
    log(thisStep++, 'bulkDelete: Click on refresh button');
    refreshButton.click();
    log(thisStep++, 'bulkDelete: Sleep');
    await $browser.sleep(2000);
    log(thisStep++, 'bulkDelete: Wait refresh button to go back to normal');
    await $browser.waitForAndFindElement(By.xpath("//span[text()='Refresh']"), defaultTimeout);
}

async function selectAdminsWithQuery(xpathQuery) {
    var thisStep = 1;
    var selectedElements = [];
    log(thisStep++, 'selectAdminsWithQuery: Find elements with query');
    await $browser.wait(async function () {
        var elements = await $browser.findElements(By.xpath(xpathQuery));
        console.log("selectAdminsWithQuery elements.length = " + elements.length)
        if (elements.length == 0)
            return true;
        log(thisStep++, 'selectAdminsWithQuery: Click on checkbox');
        elements[0].click();
        selectedElements.push(elements[0]);
        return false;
    }, defaultTimeout);
    console.log("Selected elements = " + selectedElements.length)
    return selectedElements;
}


