#!/system/bin/sh

# Displaying a message regarding TSupport and Shamiko support
echo "TSupport | Shamiko Support"

# Define the path to the Shamiko configuration directory
PATH="/data/adb/shamiko"

[ ! -d /data/adb/modules/zygisk_shamiko ] && rm -rf $PATH

# Check if the whitelist file exists
if [ -d $PATH ] && [ -f $PATH/whitelist ]; then
    echo "> Shamiko Mode : Whitelist"  # Notify that Shamiko is in the whitelist
    sleep 1.5  # Pause for 1 second
    echo "> Change to Blacklist"  # Notify the user about changing to blacklist
    rm -rf $PATH/whitelist  # Remove the whitelist file

# Check if the blacklist file exists (assuming this was meant)
elif [ -d $PATH ] && [ ! -f $PATH/whitelist ]; then
    echo "> Shamiko Mode : Blacklist"  # Notify that Shamiko is not whitelisted
    sleep 1.5  # Pause for 1 second
    echo "> Change to Whitelist"  # Notify the user about changing to whitelist
    touch $PATH/whitelist  # Create the whitelist file

# If Shamiko is neither whitelisted nor blacklisted
else
    echo "! Shamiko not detected"  # Notify that Shamiko is not detected
fi

# Sleep for 1 seconds and print result then sleep 1.3 second before exiting the script
sleep 1 && echo "> Done" && sleep 1.3 && exit