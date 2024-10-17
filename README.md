
# Install macOS update with Standard accounts on Silicon CPU Devices

The script grants temporary admin rights to standard users for 30 minutes / or until a restart to perform updates.

After the device is restarted, the user's admin rights are automatically deleted.

If you don't have JAMF Connect app on target devices, you can disable line 42.

Why do we need authchanger -reset -jamfconnect command ? 

When the device is restarted with the update, JAMF connect may occasionally experience problems. This is because the JAMF Connect logs in the TMP folder are affected. To prevent this, we reset this file before the update. The reset process does not harm the user profile and data.

## Authors

- [@euydu](https://www.github.com/euydu)
- emreuydu@gmail.com 

