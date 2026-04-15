#
# StandardMiscDemo.4gl
#
# Standalone demo for standard miscellaneous frontcalls:
#   standard.connectivity   - check network status
#   standard.isForeground   - is app in foreground
#   standard.getGeolocation - get device latitude/longitude
#   standard.clearFileCache - clear GDC file cache
#   standard.storeSize      - store current window size
#   standard.restoreSize    - restore previously stored window size
#   standard.hardCopy       - print the current form
#   standard.composeMail    - open mail app with pre-filled fields
#
# Input 1 usage: To (composeMail) | Delay ms (restoreSize)
# Input 2 usage: Subject (composeMail)
#

MAIN
   DEFINE action     STRING
   DEFINE inputText1 STRING
   DEFINE inputText2 STRING

   OPEN WINDOW w WITH FORM "StandardMiscDemo"
      ATTRIBUTES(TEXT="Standard Misc Frontcall Demo")
   CLOSE WINDOW SCREEN

   INPUT action, inputText1, inputText2 WITHOUT DEFAULTS
      FROM formonly.action, formonly.inputText1, formonly.inputText2
      ATTRIBUTES(UNBUFFERED, accept=FALSE)

      BEFORE INPUT
         CALL setupCombo()
         CALL showHint(NULL)

      ON CHANGE action
         CALL showHint(action)

      ON ACTION execute ATTRIBUTES(TEXT="Execute", IMAGE="fa-play")
         ACCEPT INPUT

      ON ACTION CANCEL
         EXIT INPUT

      AFTER INPUT
         IF action IS NULL THEN
            ERROR "Select an action first"
            CONTINUE INPUT
         END IF
         CALL executeAction(action, inputText1, inputText2)
         CONTINUE INPUT

   END INPUT

   CLOSE WINDOW w

END MAIN

# ---------------------------------------------------------------------------
PRIVATE FUNCTION setupCombo() RETURNS ()
   DEFINE combo ui.ComboBox
   LET combo = ui.ComboBox.forName("formonly.action")
   IF combo IS NOT NULL THEN
      CALL combo.addItem("connectivity",   "standard.connectivity")
      CALL combo.addItem("isForeground",   "standard.isForeground")
      CALL combo.addItem("getGeolocation", "standard.getGeolocation")
      CALL combo.addItem("clearFileCache", "standard.clearFileCache")
      CALL combo.addItem("storeSize",      "standard.storeSize")
      CALL combo.addItem("restoreSize",    "standard.restoreSize")
      CALL combo.addItem("hardCopy",       "standard.hardCopy")
      CALL combo.addItem("composeMail",    "standard.composeMail")
   END IF
END FUNCTION

# ---------------------------------------------------------------------------
PRIVATE FUNCTION showHint(action STRING) RETURNS ()
   DEFINE hint STRING
   CASE action
      WHEN "connectivity"
         LET hint = "No input needed — press Execute to check network connectivity status"
      WHEN "isForeground"
         LET hint = "No input needed — press Execute to check if the app is in the foreground"
      WHEN "getGeolocation"
         LET hint = "No input needed — press Execute to get device latitude and longitude"
      WHEN "clearFileCache"
         LET hint = "No input needed — press Execute to clear the GDC file cache (GDC only)"
      WHEN "storeSize"
         LET hint = "No input needed — press Execute to save the current window size (GDC only)"
      WHEN "restoreSize"
         LET hint = "Input 1: delay in milliseconds (e.g. 500) — then Execute to restore size (GDC only)"
      WHEN "hardCopy"
         LET hint = "No input needed — press Execute to print the current form"
      WHEN "composeMail"
         LET hint = "Input 1: To address   Input 2: Subject — then Execute to open mail app"
      OTHERWISE
         LET hint = "Select a standard misc frontcall action and press Execute"
   END CASE
   DISPLAY hint TO formonly.fieldLabel
END FUNCTION

# ---------------------------------------------------------------------------
PRIVATE FUNCTION executeAction(action STRING, inputText1 STRING, inputText2 STRING) RETURNS ()
   DEFINE result    STRING
   DEFINE bResult   BOOLEAN
   DEFINE status    STRING
   DEFINE latitude  FLOAT
   DEFINE longitude FLOAT
   DEFINE delay     INTEGER
   DEFINE feName    STRING

   TRY
      CASE action

         WHEN "connectivity"
            CALL ui.Interface.frontCall(
               "standard", "connectivity",
               [], [result]
            )
            LET result = SFMT("Network connectivity: %1", result)

         WHEN "isForeground"
            CALL ui.Interface.frontCall(
               "standard", "isForeground",
               [], [bResult]
            )
            LET result = SFMT("Application is in foreground: %1",
               IIF(bResult, "TRUE", "FALSE"))

         WHEN "getGeolocation"
            CALL ui.Interface.frontCall(
               "standard", "getGeolocation",
               [], [status, latitude, longitude]
            )
            IF status = "ok" THEN
               LET result = SFMT("Latitude:  %1\nLongitude: %2", latitude, longitude)
            ELSE
               LET result = SFMT("getGeolocation status: %1", status)
            END IF

         WHEN "clearFileCache"
            CALL ui.Interface.frontCall(
               "standard", "clearFileCache",
               [], [bResult]
            )
            LET result = IIF(bResult,
               "File cache cleared successfully (GDC only)",
               "clearFileCache returned FALSE (GDC only)")

         WHEN "storeSize"
            CALL ui.Interface.frontCall(
               "standard", "storeSize",
               [], [bResult]
            )
            LET result = IIF(bResult,
               "Window size stored. Resize the window, then use restoreSize.",
               "storeSize returned FALSE (GDC only)")

         WHEN "restoreSize"
            LET delay = 500
            IF inputText1 IS NOT NULL AND inputText1.trimRight() != "" THEN
               LET delay = inputText1
            END IF
            CALL ui.Interface.frontCall(
               "standard", "restoreSize",
               [delay], [bResult]
            )
            LET result = IIF(bResult,
               SFMT("Window size restored (delay=%1 ms)", delay),
               "restoreSize returned FALSE (requires prior storeSize, GDC only)")

         WHEN "hardCopy"
            CALL ui.Interface.frontCall(
               "standard", "feInfo",
               ["feName"], [feName]
            )
            IF feName = "Genero Desktop Client" THEN
               CALL ui.Interface.frontCall(
                  "standard", "hardCopy",
                  [1], [bResult]
               )
               LET result = IIF(bResult,
                  "Hardcopy generated successfully",
                  "hardCopy returned FALSE")
            ELSE
               LET result = "hardCopy is only supported in GDC"
            END IF

         WHEN "composeMail"
            IF inputText1 IS NULL OR inputText1.trimRight() = "" THEN
               ERROR "Enter a To address in Input 1"
               RETURN
            END IF
            CALL ui.Interface.frontCall(
               "standard", "composeMail",
               [inputText1, inputText2, "", "", ""],
               [result]
            )
            IF result = "ok" THEN
               LET result = "Mail application opened successfully"
            ELSE
               LET result = SFMT("composeMail returned: %1", result)
            END IF

         OTHERWISE
            LET result = SFMT("Unknown action: %1", action)

      END CASE
   CATCH
      LET result = SFMT("Error %1: %2", STATUS, err_get(STATUS))
   END TRY

   DISPLAY result TO formonly.result
   MESSAGE SFMT("[%1] => %2", action, result)

END FUNCTION
