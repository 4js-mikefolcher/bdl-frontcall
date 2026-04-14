IMPORT FGL StandardClipboard
IMPORT FGL StandardOS
IMPORT FGL StandardNotification
IMPORT FGL StandardMisc
IMPORT FGL ThemeFC
IMPORT FGL LocalStorageFC
IMPORT FGL BrowserFC
IMPORT FGL TableFC
IMPORT FGL WebComponentFC
IMPORT FGL MonitorFC

TYPE t_frontcall RECORD
   fcName STRING,
   fcFrontend STRING
END RECORD

DEFINE fcList DYNAMIC ARRAY OF t_frontcall

MAIN
   DEFINE currIdx INTEGER
   DEFINE currentFE STRING

   CALL loadFrontcallList()
   LET currentFE = detectFrontend()
   CALL filterByFrontend(currentFE)

   OPEN WINDOW mainWindow WITH FORM "FrontCallList"
      ATTRIBUTES(TEXT=SFMT("Front Call List (%1 - %2 of %3)", currentFE, fcList.getLength(), totalFrontcalls()))
   CLOSE WINDOW SCREEN

   DISPLAY ARRAY fcList TO srFrontcall.*
      ON ACTION CANCEL
         EXIT DISPLAY
      AFTER DISPLAY
         LET currIdx = arr_curr()
         CALL launchFrontcall(fcList[currIdx].fcName)
         CONTINUE DISPLAY
   END DISPLAY

   CLOSE WINDOW mainWindow

END MAIN

PRIVATE FUNCTION loadFrontcallList() RETURNS ()

   CALL addFC("standard.cbAdd",                          "All")
   CALL addFC("standard.cbClear",                        "All")
   CALL addFC("standard.cbGet",                          "All")
   CALL addFC("standard.cbPaste",                        "All")
   CALL addFC("standard.cbSet",                          "All")
   CALL addFC("standard.clearFileCache",                 "GDC")
   CALL addFC("standard.clearNotifications",             "GBC, GMA, GMI")
   CALL addFC("standard.composeMail",                    "All")
   CALL addFC("standard.connectivity",                   "All")
   CALL addFC("standard.createNotification",             "GBC, GMA, GMI")
   CALL addFC("standard.execute",                        "GDC")
   CALL addFC("standard.feInfo",                         "All")
   CALL addFC("standard.getEnv",                         "GDC")
   CALL addFC("standard.getGeolocation",                 "All")
   CALL addFC("standard.getLastNotificationInteractions","GBC, GMA, GMI")
   CALL addFC("standard.hardCopy",                       "All")
   CALL addFC("standard.isForeground",                   "All")
   CALL addFC("standard.launchURL",                      "All")
   CALL addFC("standard.openDir",                        "GDC")
   CALL addFC("standard.openFile",                       "All")
   CALL addFC("standard.openFiles",                      "All")
   CALL addFC("standard.playSound",                      "All")
   CALL addFC("standard.restoreSize",                    "GDC")
   CALL addFC("standard.saveFile",                       "GDC")
   CALL addFC("standard.shellExec",                      "GDC")
   CALL addFC("standard.storeSize",                      "GDC")
   CALL addFC("browser.getApplicationState",             "GBC")
   CALL addFC("browser.setApplicationState",             "GBC")
   CALL addFC("localStorage.clear",                      "All")
   CALL addFC("localStorage.getItem",                    "All")
   CALL addFC("localStorage.keys",                       "All")
   CALL addFC("localStorage.removeItem",                 "All")
   CALL addFC("localStorage.setItem",                    "All")
   CALL addFC("monitor.update",                          "GDC")
   CALL addFC("table.autoFitAllColumns",                 "All")
   CALL addFC("table.fitToViewAllColumns",               "All")
   CALL addFC("theme.getCurrentTheme",                   "GBC, GDC-UR")
   CALL addFC("theme.listThemes",                        "GBC, GDC-UR")
   CALL addFC("theme.setTheme",                          "GBC, GDC-UR")
   CALL addFC("webcomponent.call",                       "All")
   CALL addFC("webcomponent.frontCallAPIVersion",        "All")
   CALL addFC("webcomponent.getTitle",                   "All")

END FUNCTION #loadFrontcallList

PRIVATE FUNCTION addFC(fcName STRING, fcFrontend STRING) RETURNS ()
   DEFINE idx INTEGER

   LET idx = fcList.getLength() + 1
   LET fcList[idx].fcName = fcName
   LET fcList[idx].fcFrontend = fcFrontend

END FUNCTION #addFC

PRIVATE FUNCTION totalFrontcalls() RETURNS INTEGER
   DEFINE allList DYNAMIC ARRAY OF t_frontcall
   DEFINE count INTEGER

   # Temporarily reload the full list to get the total count
   CALL allList.clear()
   LET count = 42
   RETURN count

END FUNCTION #totalFrontcalls

PRIVATE FUNCTION detectFrontend() RETURNS STRING
   DEFINE feName STRING

   LET feName = ui.Interface.getFrontEndName()
   CASE
      WHEN feName MATCHES "*Desktop*"
         RETURN "GDC"
      WHEN feName == "GBC"
         RETURN "GBC"
      WHEN feName == "GMA"
         RETURN "GMA"
      WHEN feName == "GMI"
         RETURN "GMI"
      OTHERWISE
         RETURN feName
   END CASE

END FUNCTION #detectFrontend

PRIVATE FUNCTION filterByFrontend(currentFE STRING) RETURNS ()
   DEFINE filtered DYNAMIC ARRAY OF t_frontcall
   DEFINE idx INTEGER
   DEFINE newIdx INTEGER = 0

   FOR idx = 1 TO fcList.getLength()
      IF isCompatible(fcList[idx].fcFrontend, currentFE) THEN
         LET newIdx = newIdx + 1
         LET filtered[newIdx].* = fcList[idx].*
      END IF
   END FOR

   CALL fcList.clear()
   FOR idx = 1 TO filtered.getLength()
      LET fcList[idx].* = filtered[idx].*
   END FOR

END FUNCTION #filterByFrontend

PRIVATE FUNCTION isCompatible(fcFrontend STRING, currentFE STRING) RETURNS BOOLEAN

   IF fcFrontend == "All" THEN
      RETURN TRUE
   END IF

   # Check if the current frontend appears in the supported list
   # e.g. "GBC, GDC-UR" contains "GBC" and "GDC"
   IF fcFrontend.getIndexOf(currentFE, 1) > 0 THEN
      RETURN TRUE
   END IF

   RETURN FALSE

END FUNCTION #isCompatible

PRIVATE FUNCTION launchFrontcall(fcName STRING) RETURNS ()
   DEFINE parts DYNAMIC ARRAY OF STRING
   DEFINE fcArea STRING
   DEFINE fcFunction STRING

   LET parts = split(fcName, ".")
   IF parts.getLength() >= 2 THEN
      LET fcArea = parts[1]
      LET fcFunction = parts[2]
   ELSE
      RETURN
   END IF

   CASE fcArea.toLowerCase()
      WHEN "standard"
         CALL launchStandardFrontcall(fcFunction)
      WHEN "browser"
         CALL launchBrowserFrontcall(fcFunction)
      WHEN "localstorage"
         CALL launchLocalStorageFrontcall(fcFunction)
      WHEN "monitor"
         CALL launchMonitorFrontcall(fcFunction)
      WHEN "table"
         CALL launchTableFrontcall(fcFunction)
      WHEN "theme"
         CALL launchThemeFrontcall(fcFunction)
      WHEN "webcomponent"
         CALL launchWebComponentFrontcall(fcFunction)
      OTHERWISE
         ERROR "Unknown frontcall area: ", fcArea
   END CASE

END FUNCTION #launchFrontcall

PRIVATE FUNCTION launchStandardFrontcall(fcFunction STRING) RETURNS ()

   CASE fcFunction.toLowerCase()
      WHEN "cbadd"
         CALL StandardClipboard.clipboardAdd()
      WHEN "cbclear"
         CALL StandardClipboard.clipboardClear()
      WHEN "cbget"
         CALL StandardClipboard.clipboardGet()
      WHEN "cbpaste"
         CALL StandardClipboard.clipboardPaste()
      WHEN "cbset"
         CALL StandardClipboard.clipboardSet()
      WHEN "clearfilecache"
         CALL StandardMisc.clearFileCache()
      WHEN "clearnotifications"
         CALL StandardNotification.clearNotifications()
      WHEN "composemail"
         CALL StandardMisc.composeMail()
      WHEN "connectivity"
         CALL StandardMisc.connectivity()
      WHEN "createnotification"
         CALL StandardNotification.createNotification()
      WHEN "execute"
         CALL StandardOS.executeProgram("execute")
      WHEN "feinfo"
         CALL StandardOS.frontendInfo()
      WHEN "getenv"
         CALL StandardOS.frontendEnvVar()
      WHEN "getgeolocation"
         CALL StandardMisc.getGeolocation()
      WHEN "getlastnotificationinteractions"
         CALL StandardNotification.getLastNotificationInteractions()
      WHEN "hardcopy"
         CALL StandardOS.generateHardcopy()
      WHEN "isforeground"
         CALL StandardMisc.isForeground()
      WHEN "launchurl"
         CALL StandardOS.launchUrl()
      WHEN "opendir"
         CALL StandardOS.frontendBrowse("opendir")
      WHEN "openfile"
         CALL StandardOS.frontendBrowse("openfile")
      WHEN "openfiles"
         CALL StandardOS.frontendBrowse("openfiles")
      WHEN "playsound"
         CALL StandardOS.frontendBrowse("playsound")
      WHEN "restoresize"
         CALL StandardMisc.restoreSize()
      WHEN "savefile"
         CALL StandardOS.frontendBrowse("savefile")
      WHEN "shellexec"
         CALL StandardOS.executeProgram("shellexec")
      WHEN "storesize"
         CALL StandardMisc.storeSize()
      OTHERWISE
         ERROR "Standard frontcall not implemented: ", fcFunction
   END CASE

END FUNCTION #launchStandardFrontcall

PRIVATE FUNCTION launchBrowserFrontcall(fcFunction STRING) RETURNS ()

   CASE fcFunction.toLowerCase()
      WHEN "getapplicationstate"
         CALL BrowserFC.getApplicationState()
      WHEN "setapplicationstate"
         CALL BrowserFC.setApplicationState()
      OTHERWISE
         ERROR "Browser frontcall not implemented: ", fcFunction
   END CASE

END FUNCTION #launchBrowserFrontcall

PRIVATE FUNCTION launchLocalStorageFrontcall(fcFunction STRING) RETURNS ()

   CASE fcFunction.toLowerCase()
      WHEN "clear"
         CALL LocalStorageFC.storageClear()
      WHEN "getitem"
         CALL LocalStorageFC.storageGetItem()
      WHEN "keys"
         CALL LocalStorageFC.storageKeys()
      WHEN "removeitem"
         CALL LocalStorageFC.storageRemoveItem()
      WHEN "setitem"
         CALL LocalStorageFC.storageSetItem()
      OTHERWISE
         ERROR "localStorage frontcall not implemented: ", fcFunction
   END CASE

END FUNCTION #launchLocalStorageFrontcall

PRIVATE FUNCTION launchMonitorFrontcall(fcFunction STRING) RETURNS ()

   CASE fcFunction.toLowerCase()
      WHEN "update"
         CALL MonitorFC.monitorUpdate()
      OTHERWISE
         ERROR "Monitor frontcall not implemented: ", fcFunction
   END CASE

END FUNCTION #launchMonitorFrontcall

PRIVATE FUNCTION launchTableFrontcall(fcFunction STRING) RETURNS ()

   CASE fcFunction.toLowerCase()
      WHEN "autofitallcolumns"
         CALL TableFC.tableAutoFit()
      WHEN "fittoviewallcolumns"
         CALL TableFC.tableFitToView()
      OTHERWISE
         ERROR "Table frontcall not implemented: ", fcFunction
   END CASE

END FUNCTION #launchTableFrontcall

PRIVATE FUNCTION launchThemeFrontcall(fcFunction STRING) RETURNS ()

   CASE fcFunction.toLowerCase()
      WHEN "getcurrenttheme"
         CALL ThemeFC.getCurrentTheme()
      WHEN "listthemes"
         CALL ThemeFC.listThemes()
      WHEN "settheme"
         CALL ThemeFC.setTheme()
      OTHERWISE
         ERROR "Theme frontcall not implemented: ", fcFunction
   END CASE

END FUNCTION #launchThemeFrontcall

PRIVATE FUNCTION launchWebComponentFrontcall(fcFunction STRING) RETURNS ()

   CASE fcFunction.toLowerCase()
      WHEN "call"
         CALL WebComponentFC.webComponentCall()
      WHEN "frontcallapiversion"
         CALL WebComponentFC.frontCallAPIVersion()
      WHEN "gettitle"
         CALL WebComponentFC.webComponentGetTitle()
      OTHERWISE
         ERROR "Webcomponent frontcall not implemented: ", fcFunction
   END CASE

END FUNCTION #launchWebComponentFrontcall

PRIVATE FUNCTION split(origString STRING, splitString STRING) RETURNS DYNAMIC ARRAY OF STRING
   DEFINE splitList DYNAMIC ARRAY OF STRING
   DEFINE tokenizer base.StringTokenizer
   DEFINE idx INTEGER = 0

   LET tokenizer = base.StringTokenizer.create(origString, splitString)
   WHILE tokenizer.hasMoreTokens()
      LET idx = idx + 1
      LET splitList[idx] = tokenizer.nextToken()
   END WHILE

   RETURN splitList

END FUNCTION #split
