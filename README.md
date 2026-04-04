<div align="center">
  <h1>📱 Claude Code Android (Termux) Auto-Installer</h1>
  <p><strong>Run Anthropic's leaked Claude Code globally using 100% Free OpenRouter API LLMs on Android (Termux) & Windows.</strong></p>
  
  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
  [![Platform: Android | Windows](https://img.shields.io/badge/Platform-Android%20%7C%20Windows-blue.svg)]()
  [![OpenRouter API](https://img.shields.io/badge/Powered%20By-OpenRouter-white.svg)]()
</div>

<br/>

## 📖 About The Project

Anthropic's heavily guarded **Claude Code** agentic terminal environment was leaked and made open-source through an npm source map exposure. The community quickly ported it via [OpenClaude](https://gitlawb.com/node/repos/z6MkqDnb/openclaude) to bypass Anthropic's proprietary API locks, allowing the deployment of *any* Large Language Model underneath the hood.

This repository provides **1-Click / 1-Line Setup Scripts** to instantly configure this incredibly powerful AI agent on both **Windows** and **Android (Termux) environments** utilizing entirely free models. Give it access to your file system, and watch it code full applications completely autonomously.

---

## ✨ Key Features

- **Dynamic Free Models:** Both installers directly ping the live OpenRouter API on startup to instantly fetch, parse, and list every 100% Free model actively available on the internet (like Qwen 3.6 Plus or Gemini Flash 2.0). 
- **Zero File Clutter:** Installs everything into non-invasive execution scripts so your global system variables remain untouched and clean.
- **True Portability:** Allows you to autonomously code, debug, and navigate projects natively within the Android file system without requiring a rooted device.
- **Interactive Prompts:** The terminal scripts walk you through applying your API keys and selecting a model, preventing syntax errors in manual variable injection.

---

## 🚀 Installation & Usage

Choose your platform below. Make sure you have previously grabbed a **[Free OpenRouter API Key](https://openrouter.ai/)**.

### 📱 Android (Termux)

**Prerequisites:** You must install **Termux** from [F-Droid](https://f-droid.org/en/packages/com.termux/). *(Do not use the deprecated Google Play Store version!)*

1. Open Termux and grant it local storage permissions:
   ```bash
   termux-setup-storage
   ```
2. Paste this 1-line command into your terminal to pull down the auto-installer:
   ```bash
   bash <(curl -s https://raw.githubusercontent.com/jarvesusaram99/open-claude-code-termux/main/termux_setup.sh)
   ```
3. **Follow the prompts:** The script will ask for your OpenRouter Key, scrape the internet for the best free models for you to choose from, and then automatically download Node.js and globally install the `openclaude` packages in the background while you set your phone down.
4. **Boot it up:** Whenever you want to launch it, just type:
   ```bash
   ./start.sh
   ```

### 💻 Windows

The Windows setup leverages a customized interactive batch script to seamlessly execute OpenClaude without touching your registry or system environment settings.

1. **Prerequisites:** Ensure you have [Node.js](https://nodejs.org/) installed.
2. Initialize an empty workspace folder anywhere on your computer.
3. Download `windows_setup.bat` into that folder and simply double-click it.
4. **Follow the prompts:** Just like Android, the Windows script will ask for your OpenRouter Key, ping the live database for free models, dynamically let you choose one, and execute the installation.
5. **Boot it up:** A dedicated `start.bat` file will be generated for you. Double-click it anytime to launch your AI assistant!

---

## ❓ FAQ

**Q: Do I need a rooted Android device for the Termux script?**
A: **No.** It works completely natively within the Android subsystem permissions by leveraging Node.js environment paths.

**Q: OpenClaude says "Auth conflict: Using ANTHROPIC_API_KEY". What do I do?**
A: Our automated `start.sh` and `start.bat` scripts actually contain built-in fixes for this. They suppress the `ANTHROPIC_API_KEY` globally so you don't receive these warnings. Just launch using our scripts instead of calling `openclaude` blindly.

**Q: Can I use paid models like GPT-4o or Claude 3.5 Sonnet?**
A: **Yes.** In either installer, when prompted to pick a free model, an option at the bottom is provided to type a **"Custom"** endpoint manually. Just paste in the exact identifier of any paid OpenRouter model (e.g. `anthropic/claude-3-opus`).

---

## ⚖️ Legal & Disclaimer

*This repository simply provides shell configuration installers for educational and localized environment orchestration. It is not affiliated with Anthropic, nor does it host proprietary source code.*
