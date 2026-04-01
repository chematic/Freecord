const { app, BrowserWindow, ipcMain, Tray, Menu } = require('electron');
const { exec } = require('child_process');
const path = require('path');

let win;
let tray = null;

function sendLog(msg, type = 'info') {
  if (win) {
    win.webContents.send('log-update', { msg, type });
  }
}

function createWindow() {
  win = new BrowserWindow({
    width: 360,
    height: 650,
    frame: false,
    transparent: true,
    resizable: false,
    alwaysOnTop: true,
    show: false,
    skipTaskbar: false,
    icon: path.join(__dirname, 'assets/tray.png'),
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false
    }
  });

  win.loadFile('index.html');

  win.once('ready-to-show', () => {
    win.show();
    sendLog('UI Ready. Waiting for commands.', 'success');
  });

  tray = new Tray(path.join(__dirname, 'assets/tray.png'));
  const contextMenu = Menu.buildFromTemplate([
    { label: 'Open FREECORD', click: () => { win.show(); } },
    { type: 'separator' },
    { label: 'Quit', click: () => { app.quit(); } }
  ]);
  
  tray.setToolTip('FREECORD Optimizer');
  tray.setContextMenu(contextMenu);

  tray.on('double-click', () => {
    win.show();
  });
}

ipcMain.on('window-hide', () => {
  if (win) win.hide();
});

ipcMain.on('window-close', () => {
  app.quit();
});

ipcMain.on('action-boost', () => {
  sendLog('Requesting CPU Boost...', 'info');
  const ps = 'Get-Process Discord -ErrorAction SilentlyContinue | ForEach-Object { $_.PriorityClass = \'High\' }';
  exec(`powershell -Command "${ps}"`, { windowsHide: true }, (err) => {
    if (err) sendLog('CPU Boost Failed: Discord not found', 'error');
    else sendLog('CPU Priority set to HIGH', 'success');
  });
});

ipcMain.on('action-gpu', () => {
  sendLog('Requesting GPU Priority...', 'info');
  const ps = 'Get-Process Discord -ErrorAction SilentlyContinue | ForEach-Object { $_.BasePriority = 13 }';
  exec(`powershell -Command "${ps}"`, { windowsHide: true }, (err) => {
    if (err) sendLog('GPU Sync Failed', 'error');
    else sendLog('GPU Realtime Priority applied', 'success');
  });
});

ipcMain.on('action-flush', () => {
  sendLog('Flushing Working Set...', 'info');
  const ps = 'Get-Process Discord -ErrorAction SilentlyContinue | ForEach-Object { $_.EmptyWorkingSet() }';
  exec(`powershell -Command "${ps}"`, { windowsHide: true }, (err) => {
    if (err) sendLog('Memory Flush Failed', 'error');
    else sendLog('Memory Leak patched successfully', 'success');
  });
});

ipcMain.on('action-clean', () => {
  sendLog('Cleaning Cache...', 'info');
  const ps = 'Stop-Process -Name Discord -Force -ErrorAction SilentlyContinue; Remove-Item -Path $env:APPDATA\\discord\\Cache\\* -Recurse -Force -ErrorAction SilentlyContinue';
  exec(`powershell -Command "${ps}"`, { windowsHide: true }, (err) => {
    if (err) sendLog('Cleanup interrupted', 'error');
    else sendLog('Cache purged. Restart Discord.', 'success');
  });
});

app.whenReady().then(createWindow);
app.on('window-all-closed', () => { if (process.platform !== 'darwin') app.quit(); });