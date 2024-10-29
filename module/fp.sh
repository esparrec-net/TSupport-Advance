#!/system/bin/sh

echo -e "\n=== CIT PIF.json Generator ( Pixel Beta ) ==="

# Setting Directory
MODPATH=${0%/*}

# Detect busybox
get_busybox() {
    BUSYBOX=""
    for potential_path in /data/adb/modules/busybox-ndk/system/*/busybox /data/adb/magisk/busybox /data/adb/ksu/bin/busybox /data/adb/ap/bin/busybox; do
        if [ -f "$potential_path" ]; then
            BUSYBOX="$potential_path"
            break  # Stop the loop after finding the first valid BusyBox
        fi
    done

    if [ -z "$BUSYBOX" ]; then
        echo "! BusyBox not found"
        exit 1  # Exit if BusyBox is not found
    fi
}

# Call the function to detect BusyBox
get_busybox

# Define wget using the detected BusyBox
wget() {
    if [ -n "$BUSYBOX" ]; then
        "$BUSYBOX" wget "$@"  # Use the found BusyBox to execute wget
    else
        echo "! BusyBox is not set. Cannot define wget."
        exit 1
    fi
}

# Download web content with information 
echo "> Getting latest Pixel Beta ..."
wget -q -O PIXEL --no-check-certificate https://developer.android.com/topic/generic-system-image/releases 2>&1 || exit 1

# Get Information Detail
BETA_REL_DATE="$(date -D '%B %e, %Y' -d "$(grep -m1 -o 'Date:.*' PIXEL | cut -d\  -f2-4)" '+%Y-%m-%d')"
echo "> Latest Release Date: $BETA_REL_DATE"

# Get Release Information
RELEASE="$(grep -m1 'corresponding Google Pixel builds' PIXEL | grep -o '/versions/.*' | cut -d\/ -f3)"
ID="$(grep -m1 -o 'Build:.*' PIXEL | cut -d\  -f2)"
INCREMENTAL="$(grep -m1 -o "$ID-.*-" PIXEL | cut -d- -f2)"

# Download additional web pages
wget -q -O GET_PIXEL --no-check-certificate https://developer.android.com$(grep -m1 'corresponding Google Pixel builds' PIXEL | grep -o 'href.*' | cut -d\" -f2) 2>&1 || exit 1
wget -q -O BETA --no-check-certificate https://developer.android.com$(grep -m1 'Factory images for Google Pixel' GET_PIXEL | grep -o 'href.*' | cut -d\" -f2) 2>&1 || exit 1

# Get Product and Model Information 
MODEL_LIST="$(grep -A1 'tr id=' BETA | grep '<td>' | sed -e 's/<[^>]*>//g' | sed 's/^[ \t]*//g' | tr -d '\r')"
PRODUCT_LIST="$(grep -o 'factory/.*_beta' BETA | cut -d\/ -f2)"

# Randomly Choose Model
select_random_model() {
    local list_count="$(echo "$MODEL_LIST" | wc -l)"
    local list_rand="$((RANDOM % list_count + 1))"
    local IFS=$'\n'
    set -- $MODEL_LIST
    MODEL="$(eval echo \${$list_rand})"
    set -- $PRODUCT_LIST
    PRODUCT="$(eval echo \${$list_rand})"
    DEVICE="$(echo "$PRODUCT" | sed 's/_beta//')"
}

select_random_model
echo "> Getting information [ $MODEL ($PRODUCT) ]"

# Clean up temporary files
cleaner() {
    [ -f $MODPATH/BETA ] && su -c "rm -rf $MODPATH/BETA"
    [ -f $MODPATH/GET_PIXEL ] && su -c "rm -rf $MODPATH/GET_PIXEL"
    [ -f $MODPATH/PIXEL ] && su -c "rm -rf $MODPATH/PIXEL"
}

# Key Listerner
key() {
    local option_name=$1
    local option1=$2
    local option2=$3
    local result_var=$4

    echo -e "\n[ VOL+ ] = [ $option1 | YES ]"
    echo "[ VOL- ] = [ $option2 | NO ]"
    echo "[ POWR ] = [ CANCEL ]"
    echo -e "\nYour selection for $option_name ?"

    local maxtouch=3  # Set the touch
    local touches=0  # Initialize elapsed time

    while true; do
        keys=$(getevent -lqc1)
        
        # Check for timeout
        if [ "$touches" -ge "$maxtouch" ]; then
            echo "Set to Default"  # Print timeout message
            return 1  # Exit the function with a timeout status
        fi

        if echo "$keys" | grep -q 'KEY_VOLUMEUP.*DOWN'; then
            echo "$option_name set to $option1"
            eval "$result_var=\"$option1\""  # Store the result in the provided variable
            return 1  # Return with success status for option1
        elif echo "$keys" | grep -q 'KEY_VOLUMEDOWN.*DOWN'; then
            echo "$option_name set to $option2"
            eval "$result_var=\"$option2\""  # Store the result in the provided variable
            return 0  # Return with success status for option2
        elif echo "$keys" | grep -q 'KEY_POWER.*DOWN'; then
            echo -e "> Power key detected! Canceling..."
            cleaner
            echo "=== ENDED ==="
            sleep 1
            exit 0  # Exit if power key is pressed
        fi
        sleep 1
        touches=$((touches + 1))  # Increment the elapsed time
    done
}

# Initialize spoof variables
P=""
spoofprops="1"
spoofprovider="0"
spoofsignature="1"

# Check for Play Integrity Fix and implement
if [ -d /data/adb/modules/playintegrityfix ]; then
    if su -c "cat /data/adb/modules/playintegrityfix/module.prop" | grep -q "Play Integrity Fork"; then
        echo "! Please Install Chiteroman PIF"     
    else
        echo "> Save to pif.json ..."
        #key spoofProps true false spoofprops
        #key spoofProvider true false spoofprovider
        #key spoofSignature true false spoofsignature
        cat <<EOF > pif.json
{
  // Citra-Standalone, CITraces - https://t.me/citraintegritytrick/3 - Citra, a standalone implementation, leaves a trace in IoT.
    
  "FINGERPRINT": "google/$PRODUCT/$DEVICE:$RELEASE/$ID/$INCREMENTAL:user/release-keys",
  "MANUFACTURER": "Google",
  "MODEL": "$MODEL",
  "SECURITY_PATCH": "2024-09-05",
  "DEVICE_INITIAL_SDK_INT": 21,
} //Citra-Standalone
EOF
        echo "> Successfully generated pif.json."
        su -c "mv $MODPATH/pif.json /data/adb/modules/playintegrityfix/pif.json"
    fi
else
    echo "! PlayIntegrityFix not found"
fi
cleaner
killall -v com.google.android.gms >> /dev/null;
killall -v com.google.android.gms.unstable >> /dev/null;
echo "=== ENDED ==="
exit 0