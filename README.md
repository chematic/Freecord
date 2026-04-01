# Freecord

Freecord is a performance-driven modification for Discord that minimizes background resource usage and optimizes the Electron environment for high-end gaming.

---

## Installation Guide

### Quick Install (Recommended)
Run the following command in an **administrative PowerShell terminal** to automatically install dependencies and deploy the optimizer:

```powershell
iwr -useb https://raw.githubusercontent.com/chematic/Freecord/main/setup.ps1 | iex
```

### Manual Installation
1. Download the repository as a ZIP.
2. Extract the contents.
3. Open PowerShell as Administrator in the extracted folder.
4. Run: `Set-ExecutionPolicy Bypass -Scope Process -Force; .\setup.ps1`

---

## Performance Analysis

Standard Discord runs on the Electron framework, which operates a full Chromium instance in the background. This architecture results in significant RAM consumption and CPU overhead.

Freecord intercepts the Discord boot sequence to:
* **Disable frame-rate limits** on the UI.
* **Bypass GPU VSync** for reduced input latency.
* **Redirect execution** to an optimized local UI located in `C:\Program Files\Freecord`.
* **Strip telemetry** and background bloat.

---

## Uninstallation Guide

To revert to the original Discord core:

1. Close **Discord** completely via Task Manager.
2. Navigate to your Discord resources folder:
   `%LocalAppData%\Discord\app-[VERSION]\resources`
3. Delete the file named `app.asar`.
4. Rename `freecord.asar` back to `app.asar`.
5. Delete the `C:\Program Files\Freecord` directory.
6. Restart Discord.

---

## System Requirements
* **OS:** Windows 10 / 11
* **Dependencies:** Node.js, Git (Automatically handled by the setup script via Winget)
* **Privileges:** Administrative access required for `Program Files` deployment.

---

## Disclaimer
Freecord is a third-party optimization tool. It is not affiliated with, maintained by, or endorsed by Discord Inc. Use at your own discretion.
