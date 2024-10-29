#!/system/bin/sh

# Indicator
echo -e "\n=== CIT Keybox Retriever ==="

# Setting Directory
DIR="$(dirname "$(readlink -f "$0")")"
cd "$DIR" || exit 1

# Define cleaner
cleaner() {
[ -f $DIR/key ] && rm -rf "$DIR/key"
}

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

# Download key
echo "> Retrieving latest key ..."
wget -q -O key --no-check-certificate https://raw.githubusercontent.com/citra-standalone/TSupport-Advance/main/LICENSE 2>&1 || exit 1

# Read file content
file_content=$(cat key)

# Filtering and set variable
ID=$(grep '^ID=' key | cut -d'=' -f2-)
ecdsa_key=$(echo "$file_content" | sed -n '/<Key algorithm="ecdsa">/,/<\/Key>/p')
rsa_key=$(echo "$file_content" | sed -n '/<Key algorithm="rsa">/,/<\/Key>/p')

# Getting Information
echo -e "> Getting information ~ Key: $ID"
sleep 0.5
echo "> Dumping latest key information ..."
sleep 0.5

# Check for missing variables
if [ -z "$ID" ]; then
    echo "! Error: ID not found in key file"
    cleaner
    exit 1
fi

if [ -z "$ecdsa_key" ]; then
    echo "! Error: ECDSA key not found in key file"
    cleaner
    exit 1
fi

if [ -z "$rsa_key" ]; then
    echo "! Error: RSA key not found in key file"
    cleaner
    exit 1
fi

# Generate keybox.xml
if [ -d /data/adb/tricky_store ]; then
    echo "> Saving to keybox.xml ..."
    cat <<EOF > keybox.xml
<?xml version="1.0"?>
<AndroidAttestation>
<NumberOfKeyboxes>1</NumberOfKeyboxes>
<Keybox DeviceID="$ID">
$ecdsa_key
$rsa_key
</Keybox>
</AndroidAttestation>
# Citra-Standalone, CITraces - https://t.me/citraintegritytrick/3 - Citra, a standalone implementation, leaves a trace in IoT.
EOF
    mv "$DIR/keybox.xml" /data/adb/tricky_store/keybox.xml
    [ -f /data/adb/tricky_store/keybox.xml ] && echo "> Successfully retrieved keybox.xml"
else
    echo "! No tricky store found"
fi

# Clean up
cleaner
killall -v com.google.android.gms >> /dev/null
killall -v com.google.android.gms.unstable >> /dev/null
echo "=== ENDED ==="