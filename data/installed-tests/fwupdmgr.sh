#!/bin/bash

exec 2>&1
dirname=`dirname $0`

# ---
echo "Getting the list of remotes..."
fwupdmgr get-remotes
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

# ---
echo "Enabling fwupd-tests remote..."
fwupdmgr enable-remote fwupd-tests
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

# ---
echo "Update the device hash database..."
fwupdmgr verify-update
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

# ---
echo "Getting devices (should be one)..."
fwupdmgr get-devices --no-unreported-check
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

# ---
echo "Testing the verification of firmware..."
fwupdmgr verify
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

# ---
echo "Getting updates (should be one)..."
fwupdmgr --no-unreported-check --no-metadata-check get-updates
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

# ---
echo "Installing test firmware..."
fwupdmgr install ${dirname}/fakedevice124.cab
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

# ---
echo "Getting updates (should be none)..."
fwupdmgr --no-unreported-check --no-metadata-check get-updates
rc=$?; if [[ $rc != 2 ]]; then exit $rc; fi

# ---
echo "Testing the verification of firmware (again)..."
fwupdmgr verify
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

# ---
echo "Downgrading to older release (requires network access)"
fwupdmgr downgrade
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

# ---
echo "Downgrading to older release (should be none)"
fwupdmgr downgrade
rc=$?; if [[ $rc != 2 ]]; then exit $rc; fi

# ---
echo "Updating all devices to latest release (requires network access)"
fwupdmgr --no-unreported-check --no-metadata-check --no-reboot-check update
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

# ---
echo "Getting updates (should be none)..."
fwupdmgr --no-unreported-check --no-metadata-check get-updates
rc=$?; if [[ $rc != 2 ]]; then exit $rc; fi

# ---
echo "Refreshing from the LVFS (requires network access)..."
fwupdmgr refresh
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

# ---
echo "Flashing actual devices (requires specific hardware)"
${dirname}/hardware.py
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

# success!
exit 0
