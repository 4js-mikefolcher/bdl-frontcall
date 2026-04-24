#
# StandardMiscDemo.4gl
#
# Standalone demo for standard miscellaneous frontcalls via MiscLib /
# OSLib — no inline ui.Interface.frontCall in this module.
#

IMPORT FGL com.fourjs.fclib.MiscLib
IMPORT FGL com.fourjs.fclib.OSLib
IMPORT FGL com.fourjs.fclib.FrontCallLib

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

PRIVATE FUNCTION showHint(action STRING) RETURNS ()
   DEFINE hint STRING
   CASE action
      WHEN "connectivity"
         LET hint = "No input needed — press Execute to check network connectivity status"
      WHEN "isForeground"
         LET hint = "No input needed — press Execute to check if the app is in the foreground"
      WHEN "getGeolocation"
         LET hint = "No input needed — press Execute to get device latitude and longitude (mobile/GBC only)"
      WHEN "clearFileCache"
         LET hint = "No input needed — press Execute to clear the GDC file cache (GDC only)"
      WHEN "storeSize"
         LET hint = "No input needed — press Execute to save the current window size (GDC only)"
      WHEN "restoreSize"
         LET hint = "Input 1: delay in milliseconds (e.g. 500) — then Execute to restore size (GDC only)"
      WHEN "hardCopy"
         LET hint = "No input needed — press Execute to print the current form (GDC only)"
      WHEN "composeMail"
         LET hint = "Input 1: To address   Input 2: Subject — then Execute to open mail app"
      OTHERWISE
         LET hint = "Select a standard misc frontcall action and press Execute"
   END CASE
   DISPLAY hint TO formonly.fieldLabel
END FUNCTION

PRIVATE FUNCTION executeAction(action STRING, inputText1 STRING, inputText2 STRING) RETURNS ()
   DEFINE r FrontCallLib.t_result
   DEFINE sR MiscLib.t_msStringResult
   DEFINE bR MiscLib.t_msBoolResult
   DEFINE gR MiscLib.t_msGeoResult
   DEFINE delay INTEGER
   DEFINE result STRING

   CASE action

      WHEN "connectivity"
         LET sR = MiscLib.connectivity()
         LET result = sR.message

      WHEN "isForeground"
         LET bR = MiscLib.isForeground()
         LET result = bR.message

      WHEN "getGeolocation"
         LET gR = MiscLib.getGeolocation()
         LET result = gR.message

      WHEN "clearFileCache"
         LET r = MiscLib.clearFileCache()
         LET result = r.message

      WHEN "storeSize"
         LET r = MiscLib.storeSize()
         LET result = r.message

      WHEN "restoreSize"
         LET delay = 500
         IF inputText1 IS NOT NULL AND inputText1.trimRight() != "" THEN
            LET delay = inputText1
         END IF
         LET r = MiscLib.restoreSize(delay)
         LET result = r.message

      WHEN "hardCopy"
         LET r = OSLib.hardCopy(1)
         LET result = r.message

      WHEN "composeMail"
         IF inputText1 IS NULL OR inputText1.trimRight() = "" THEN
            ERROR "Enter a To address in Input 1"
            RETURN
         END IF
         LET sR = MiscLib.composeMail(inputText1, inputText2, "", "", "")
         LET result = sR.message

      OTHERWISE
         LET result = SFMT("Unknown action: %1", action)

   END CASE

   DISPLAY result TO formonly.result
   MESSAGE SFMT("[%1] => %2", action, result)

END FUNCTION
