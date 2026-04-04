#!/data/data/com.termux/files/usr/bin/bash

# Clear screen for clean UI
clear
echo "================================================="
echo "  [>>] OpenClaude Termux Auto-Installer"
echo "================================================="
echo ""
echo "  Let's get your settings first so you can set "
echo "  your phone down while it installs!"
echo "================================================="
echo ""

read -p "Enter your OpenRouter API Key (sk-or-...): " API_KEY
echo ""

echo "Fetching live list of FREE OpenRouter models..."
# Download JSON and use basic grep/sed to extract everything that looks like "provider/model:free"
MODELS=($(curl -s https://openrouter.ai/api/v1/models | grep -o 'id":"[^"]*:free"' | sed 's/id":"//g' | sed 's/"//g'))

if [ ${#MODELS[@]} -eq 0 ]; then
   echo "Failed to fetch free models. Falling back to basics..."
   MODELS=("qwen/qwen3.6-plus:free" "google/gemini-2.0-flash-lite-preview-02-05:free" "meta-llama/llama-3-8b-instruct:free")
fi

echo ""
echo "Select a Free Model:"
for i in "${!MODELS[@]}"; do
    INDEX=$((i+1))
    echo "  $INDEX) ${MODELS[$i]}"
done
CUSTOM_OPT=$(( ${#MODELS[@]} + 1 ))
echo "  $CUSTOM_OPT) Custom (Type your own endpoint)"
echo ""

read -p "Choose [1-$CUSTOM_OPT] (Default: 1): " MODEL_CHOICE

# Calculate choice
if [ -z "$MODEL_CHOICE" ]; then
    MODEL_CHOICE=1
fi

if [ "$MODEL_CHOICE" == "$CUSTOM_OPT" ]; then
    read -p "Enter custom model name: " MODEL_NAME
else
    IDX=$((MODEL_CHOICE-1))
    MODEL_NAME="${MODELS[$IDX]}"
    if [ -z "$MODEL_NAME" ]; then
        MODEL_NAME="${MODELS[0]}"
    fi
fi

echo ""
echo "[OK] You have selected: $MODEL_NAME"
echo ""
read -p "Press [Enter] to begin installation and setup, or press CTRL+C to cancel..." dummy

echo ""
echo "================================================="
echo "  [>>] Installing now... "
echo "  (You can set your phone down)"
echo "================================================="
echo ""

echo "[1/4] Upgrading packages and installing dependencies..."
pkg update -y
pkg install nodejs git curl -y

echo ""
echo "[2/4] Installing OpenClaude globally... (Please wait)"
npm install -g @gitlawb/openclaude

echo ""
echo "[3/4] Generating smart launcher script..."
cat << EOF > ~/start.sh
#!/data/data/com.termux/files/usr/bin/bash
export CLAUDE_CODE_USE_OPENAI=1
export OPENAI_API_KEY="$API_KEY"
export OPENAI_BASE_URL="https://openrouter.ai/api/v1"
export OPENAI_MODEL="$MODEL_NAME"
export ANTHROPIC_API_KEY=""

echo "Booting OpenClaude with \$OPENAI_MODEL..."
openclaude
EOF

chmod +x ~/start.sh

echo ""
echo "================================================="
echo "  [DONE] Setup Complete!"
echo ""
echo "  To run your AI assistant anytime, type:"
echo "  ./start.sh"
echo "================================================="
echo ""
