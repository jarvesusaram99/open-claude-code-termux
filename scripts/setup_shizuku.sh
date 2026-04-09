#!/data/data/com.termux/files/usr/bin/bash

echo -e "\033[1;36m🤖 Official Shizuku Integration Setup for Termux\033[0m"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Setup Termux storage access if needed
if [ ! -d "$HOME/storage" ]; then
    echo "Requesting storage permission... tap 'Allow' on the popup."
    termux-setup-storage
    sleep 3
fi

SHIZUKU_DIR="$HOME/storage/shared/Shizuku"

# Check if the official exported files exist
if [ ! -f "$SHIZUKU_DIR/rish" ] || [ ! -f "$SHIZUKU_DIR/rish_shizuku.dex" ]; then
    echo -e "\033[1;31m❌ ERROR: Official 'rish' files not found in $SHIZUKU_DIR!\033[0m"
    echo ""
    echo "To fix this:"
    echo "1. Open the 'Shizuku' Android app."
    echo "2. Ensure Shizuku is running."
    echo "3. Scroll to 'Use Shizuku in terminal apps' -> Tap 'Export files'."
    echo "4. Save them directly in the 'Shizuku' folder in your internal storage."
    echo "5. Run this setup script again."
    exit 1
fi

BIN="/data/data/com.termux/files/usr/bin"

echo "Copying Official Shizuku binaries directly into Termux..."

# We must copy BOTH files into the bin directory so they see each other
cp -f "$SHIZUKU_DIR/rish" "${BIN}/rish"
cp -f "$SHIZUKU_DIR/rish_shizuku.dex" "${BIN}/rish_shizuku.dex"

# Fix potential Windows/FAT32 carriage return issues
sed -i 's/\r$//' "${BIN}/rish"

# Inject the application ID requirement for Termux
sed -i '2i export RISH_APPLICATION_ID="com.termux"' "${BIN}/rish"

# Set proper permissions
chmod +x "${BIN}/rish"
chmod -w "${BIN}/rish_shizuku.dex" # Must be non-writable for security/loading

echo -e "\033[1;32m✅ Shizuku setup complete! Termux natively recognizes the UI wrapper.\033[0m"
echo "Test it by running: rish -c whoami"
