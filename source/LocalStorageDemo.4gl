#
# LocalStorageDemo.4gl
#
# Standalone demo for localStorage frontcalls (GBC only):
#   localStorage.setItem    - store a key/value pair
#   localStorage.getItem    - retrieve value by key
#   localStorage.keys       - list all stored keys
#   localStorage.removeItem - delete a key
#   localStorage.clear      - wipe all stored data
#

IMPORT FGL com.fourjs.fclib.LocalStorageLib
IMPORT FGL com.fourjs.fclib.FrontCallLib

MAIN
   DEFINE action       STRING
   DEFINE storageKey   STRING
   DEFINE storageValue STRING

   OPEN WINDOW w WITH FORM "LocalStorageDemo"
      ATTRIBUTES(TEXT="LocalStorage Frontcall Demo")
   CLOSE WINDOW SCREEN

   INPUT action, storageKey, storageValue WITHOUT DEFAULTS
      FROM formonly.action, formonly.storageKey, formonly.storageValue
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
         CALL executeAction(action, storageKey, storageValue)
         CONTINUE INPUT

   END INPUT

   CLOSE WINDOW w

END MAIN

PRIVATE FUNCTION setupCombo() RETURNS ()
   DEFINE combo ui.ComboBox
   LET combo = ui.ComboBox.forName("formonly.action")
   IF combo IS NOT NULL THEN
      CALL combo.addItem("setItem",    "localStorage.setItem")
      CALL combo.addItem("getItem",    "localStorage.getItem")
      CALL combo.addItem("keys",       "localStorage.keys")
      CALL combo.addItem("removeItem", "localStorage.removeItem")
      CALL combo.addItem("clear",      "localStorage.clear")
   END IF
END FUNCTION

PRIVATE FUNCTION showHint(action STRING) RETURNS ()
   DEFINE hint STRING
   CASE action
      WHEN "setItem"
         LET hint = "Enter Key and Value, then press Execute to store the pair (GBC only)"
      WHEN "getItem"
         LET hint = "Enter Key, press Execute to retrieve its stored value (GBC only)"
      WHEN "keys"
         LET hint = "Press Execute to list all keys currently in localStorage (GBC only)"
      WHEN "removeItem"
         LET hint = "Enter Key, press Execute to delete that key from localStorage (GBC only)"
      WHEN "clear"
         LET hint = "Press Execute to wipe ALL key/value pairs from localStorage (GBC only)"
      OTHERWISE
         LET hint = "Select a localStorage frontcall action and press Execute"
   END CASE
   DISPLAY hint TO formonly.fieldLabel
END FUNCTION

PRIVATE FUNCTION executeAction(action STRING, storageKey STRING, storageValue STRING) RETURNS ()
   DEFINE r FrontCallLib.t_result
   DEFINE getR LocalStorageLib.t_lsGetResult
   DEFINE keysR LocalStorageLib.t_lsKeysResult
   DEFINE result STRING

   CASE action

      WHEN "setItem"
         IF storageKey IS NULL OR storageKey.trimRight() = "" THEN
            ERROR "Enter a Key first"
            RETURN
         END IF
         LET r = LocalStorageLib.setItem(storageKey, storageValue)
         LET result = r.message

      WHEN "getItem"
         IF storageKey IS NULL OR storageKey.trimRight() = "" THEN
            ERROR "Enter a Key first"
            RETURN
         END IF
         LET getR = LocalStorageLib.getItem(storageKey)
         LET result = getR.message
         IF getR.success AND getR.value IS NOT NULL THEN
            DISPLAY getR.value TO formonly.storageValue
         END IF

      WHEN "keys"
         LET keysR = LocalStorageLib.keys()
         IF keysR.success AND keysR.keys IS NOT NULL AND keysR.keys.getLength() > 0 THEN
            LET result = SFMT("Stored keys:\n%1", keysR.keys)
         ELSE
            LET result = keysR.message
         END IF

      WHEN "removeItem"
         IF storageKey IS NULL OR storageKey.trimRight() = "" THEN
            ERROR "Enter a Key first"
            RETURN
         END IF
         LET r = LocalStorageLib.removeItem(storageKey)
         LET result = r.message

      WHEN "clear"
         LET r = LocalStorageLib.clear()
         LET result = r.message

      OTHERWISE
         LET result = SFMT("Unknown action: %1", action)

   END CASE

   DISPLAY result TO formonly.result
   MESSAGE SFMT("[%1] => %2", action, result)

END FUNCTION
