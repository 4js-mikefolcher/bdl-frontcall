# bdl-frontcall

A Genero BDL application that demonstrates all built-in frontcalls available from `ui.Interface.frontCall()`. Includes a main application with a categorized frontcall list, plus standalone demo programs for each frontcall group.

## Programs

### FrontcallExamples (main application)

Presents a scrollable list of all 42 built-in frontcalls organized by namespace. Each entry shows the frontcall name and which front-ends support it. Select an entry and press OK to execute the frontcall in a dedicated screen.

### Standalone Demos

Each demo is an independent program focusing on a single frontcall group with its own form, combobox-driven action selection, and result display.

| Program | Run Target | Description |
|---------|-----------|-------------|
| ClipboardDemo | `make run-clipboard` | All 5 clipboard frontcalls (Add, Clear, Get, Paste, Set) |
| WebComponentDemo | `make run-webcomponent` | Web component frontcalls with function combobox and parameter enable/disable |
| BrowserDemo | `make run-browser` | Browser state frontcalls (setApplicationState, getApplicationState) |
| LocalStorageDemo | `make run-localstorage` | All localStorage frontcalls (setItem, getItem, keys, removeItem, clear) |
| MonitorDemo | `make run-monitor` | GDC monitor.update frontcall |
| NotificationDemo | `make run-notification` | Notification frontcalls (createNotification, clearNotifications, getLastNotificationInteractions) |
| ThemeDemo | `make run-theme` | Theme selection with combobox, auto-apply on change, and tree view of theme hierarchy |
| StandardMiscDemo | `make run-misc` | Misc frontcalls (connectivity, isForeground, getGeolocation, clearFileCache, storeSize, restoreSize, hardCopy, composeMail) |
| StandardOSDemo | `make run-os` | OS/file frontcalls (launchURL, feInfo, getEnv, openDir, openFile, openFiles, saveFile, playSound, execute, shellExec) |
| TableFCDemo | `make run-table` | Table column frontcalls (autoFitAllColumns, fitToViewAllColumns) |
| FileDemo | `make run-file` | File handling frontcalls (openDir, openFile, openFiles, saveFile, playSound) |

## Frontcall Coverage

### standard (26)

| Frontcall | Frontend | Description |
|-----------|----------|-------------|
| cbAdd | All | Add text to clipboard |
| cbClear | All | Clear clipboard |
| cbGet | All | Get clipboard content |
| cbPaste | All | Paste clipboard to current field |
| cbSet | All | Set clipboard content |
| clearFileCache | GDC | Clear local file cache |
| clearNotifications | GBC, GMA, GMI | Drop displayed notifications |
| composeMail | All | Open default mail application |
| connectivity | All | Check network connectivity |
| createNotification | GBC, GMA, GMI | Create a local notification |
| execute | GDC | Execute command on front-end |
| feInfo | All | Query front-end properties |
| getEnv | GDC | Get front-end environment variable |
| getGeolocation | All | Get GPS location |
| getLastNotificationInteractions | GBC, GMA, GMI | Get notification interactions |
| hardCopy | GDC | Print screenshot of current window |
| isForeground | All | Check if app is in foreground |
| launchURL | All | Open URL in default handler |
| openDir | GDC | Directory picker dialog |
| openFile | All | Single file picker dialog |
| openFiles | All | Multi-file picker dialog |
| playSound | All | Play a sound file |
| restoreSize | GDC | Restore stored window size |
| saveFile | GDC | Save file dialog |
| shellExec | GDC | Open file with associated program |
| storeSize | GDC | Store current window size |

### browser (2)

| Frontcall | Frontend | Description |
|-----------|----------|-------------|
| getApplicationState | GBC | Get URL # anchor |
| setApplicationState | GBC | Set URL # anchor |

### localStorage (5)

| Frontcall | Frontend | Description |
|-----------|----------|-------------|
| clear | All | Remove all key/value pairs |
| getItem | All | Get value by key |
| keys | All | List all stored keys |
| removeItem | All | Remove a key |
| setItem | All | Store a key/value pair |

### monitor (1)

| Frontcall | Frontend | Description |
|-----------|----------|-------------|
| update | GDC | Start GDC update |

### table (2)

| Frontcall | Frontend | Description |
|-----------|----------|-------------|
| autoFitAllColumns | All | Fit column widths to data |
| fitToViewAllColumns | All | Fit columns to window |

### theme (3)

| Frontcall | Frontend | Description |
|-----------|----------|-------------|
| getCurrentTheme | GBC, GDC-UR | Get active theme |
| listThemes | GBC, GDC-UR | List available themes (tree view) |
| setTheme | GBC, GDC-UR | Activate a theme |

### webcomponent (3)

| Frontcall | Frontend | Description |
|-----------|----------|-------------|
| call | All | Call JavaScript function |
| frontCallAPIVersion | All | Get web component API version |
| getTitle | All | Get web component HTML title |

## Front-end Key

| Code | Front-end |
|------|-----------|
| GDC | Genero Desktop Client |
| GBC | Genero Browser Client (via GAS) |
| GDC-UR | GDC with Universal Rendering |
| GMA | Genero Mobile for Android |
| GMI | Genero Mobile for iOS |
| All | All of the above |

## Not Yet Covered

Mobile-specific frontcalls (21 in the `mobile` module, 5 in `android`, 2 in `ios`, 7 in `cordova`) are not yet demonstrated. These require a GMA/GMI development environment.

## Project Structure

```
bdl-frontcall/
  Makefile                    Build system
  *.xcf                       GAS deployment configs (one per program)
  source/
    FrontcallExamples.4gl     Main entry point and routing
    StandardClipboard.4gl     Clipboard frontcalls (cb*)
    StandardOS.4gl            File/execute/browse/feInfo/getEnv/hardCopy
    StandardNotification.4gl  Notification frontcalls
    StandardMisc.4gl          composeMail, connectivity, geolocation, etc.
    ThemeFC.4gl               Theme frontcalls with tree view
    LocalStorageFC.4gl        localStorage frontcalls
    BrowserFC.4gl             Browser state frontcalls
    TableFC.4gl               Table column frontcalls
    WebComponentFC.4gl        Web component frontcalls
    MonitorFC.4gl             GDC monitor update
    ClipboardDemo.4gl         Standalone clipboard demo
    WebComponentDemo.4gl      Standalone web component demo
    BrowserDemo.4gl           Standalone browser demo
    LocalStorageDemo.4gl      Standalone localStorage demo
    MonitorDemo.4gl           Standalone monitor demo
    NotificationDemo.4gl      Standalone notification demo
    ThemeDemo.4gl             Standalone theme demo with tree view
    StandardMiscDemo.4gl      Standalone misc frontcalls demo
    StandardOSDemo.4gl        Standalone OS frontcalls demo
    TableFCDemo.4gl           Standalone table frontcalls demo
    FileDemo.4gl              Standalone file handling demo
    *.per                     Form definitions
  webcomponents/
    wcdemo/wcdemo.html        Demo web component (Genero 6.x API)
```

## Building

Requires the Genero BDL compiler toolchain (`fglcomp`, `fglform`).

```sh
make              # Compile all modules and forms
make clean        # Remove compiled artifacts
make run          # Build and run FrontcallExamples
```

See the standalone demos table above for individual run targets.

## Running via GAS/GBC

Copy the XCF files to your GAS application directory and update the paths inside them:

```sh
cp *.xcf $FGLASDIR/appdata/app/
```

Then access via browser:
- `http://<host>:6394/ua/r/FrontcallExamples`
- `http://<host>:6394/ua/r/ClipboardDemo`
- `http://<host>:6394/ua/r/WebComponentDemo`
- `http://<host>:6394/ua/r/BrowserDemo`
- `http://<host>:6394/ua/r/LocalStorageDemo`
- `http://<host>:6394/ua/r/MonitorDemo`
- `http://<host>:6394/ua/r/NotificationDemo`
- `http://<host>:6394/ua/r/ThemeDemo`
- `http://<host>:6394/ua/r/StandardMiscDemo`
- `http://<host>:6394/ua/r/StandardOSDemo`
- `http://<host>:6394/ua/r/TableFCDemo`
- `http://<host>:6394/ua/r/FileDemo`

## License

MIT
