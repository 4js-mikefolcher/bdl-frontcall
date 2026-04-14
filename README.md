# bdl-frontcall

A Genero BDL application that demonstrates all built-in frontcalls available from `ui.Interface.frontCall()`. The application detects the current front-end at startup and filters the list to only show frontcalls compatible with that front-end.

## Programs

### FrontcallExamples

The main application. Presents a scrollable list of all 42 built-in frontcalls organized by namespace. Each entry shows the frontcall name and which front-ends support it. Select an entry and press OK to execute the frontcall in a dedicated screen.

### ClipboardDemo

A standalone single-screen program that demonstrates all 5 clipboard frontcalls (Add, Clear, Get, Paste, Set) with an input/output textedit layout and an action combobox.

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
| hardCopy | All | Print screenshot of current window |
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
| listThemes | GBC, GDC-UR | List available themes |
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

## Project Structure

```
bdl-frontcall/
  Makefile                    Build system
  FrontcallExamples.xcf       GAS deployment config (main app)
  ClipboardDemo.xcf           GAS deployment config (clipboard demo)
  source/
    FrontcallExamples.4gl     Main entry point and routing
    StandardClipboard.4gl     Clipboard frontcalls (cb*)
    StandardOS.4gl            File/execute/browse/feInfo/getEnv
    StandardNotification.4gl  Notification frontcalls
    StandardMisc.4gl          composeMail, connectivity, geolocation, etc.
    ThemeFC.4gl               Theme frontcalls
    LocalStorageFC.4gl        localStorage frontcalls
    BrowserFC.4gl             Browser state frontcalls
    TableFC.4gl               Table column frontcalls
    WebComponentFC.4gl        Web component frontcalls
    MonitorFC.4gl             GDC monitor update
    ClipboardDemo.4gl         Standalone clipboard demo
    *.per                     Form definitions
  webcomponents/
    wcdemo/wcdemo.html        Demo web component for webcomponent.call
```

## Building

Requires the Genero BDL compiler toolchain (`fglcomp`, `fglform`).

```sh
make              # Compile all modules and forms
make clean        # Remove compiled artifacts
make run          # Build and run FrontcallExamples
make run-clipboard # Build and run ClipboardDemo
```

## Running via GAS/GBC

Copy the XCF files to your GAS application directory and update the paths inside them:

```sh
cp FrontcallExamples.xcf $FGLASDIR/appdata/app/
cp ClipboardDemo.xcf $FGLASDIR/appdata/app/
```

Then access via browser:
- `http://<host>:6394/ua/r/FrontcallExamples`
- `http://<host>:6394/ua/r/ClipboardDemo`

## License

MIT
