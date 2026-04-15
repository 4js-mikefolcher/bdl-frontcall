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

# ---------------------------------------------------------------------------
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

# ---------------------------------------------------------------------------
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

# ---------------------------------------------------------------------------
PRIVATE FUNCTION executeAction(action STRING, storageKey STRING, storageValue STRING) RETURNS ()
   DEFINE result    STRING
   DEFINE retValue  STRING

   TRY
      CASE action

         WHEN "setItem"
            IF storageKey IS NULL OR storageKey.trimRight() = "" THEN
               ERROR "Enter a Key first"
               RETURN
            END IF
            CALL ui.Interface.frontCall(
               "localStorage", "setItem",
               [storageKey, storageValue], []
            )
            LET result = SFMT("Stored: '%1' = '%2'", storageKey, storageValue)

         WHEN "getItem"
            IF storageKey IS NULL OR storageKey.trimRight() = "" THEN
               ERROR "Enter a Key first"
               RETURN
            END IF
            CALL ui.Interface.frontCall(
               "localStorage", "getItem",
               [storageKey], [retValue]
            )
            IF retValue IS NULL THEN
               LET result = SFMT("No value found for key '%1'", storageKey)
            ELSE
               LET result = SFMT("'%1' = '%2'", storageKey, retValue)
               DISPLAY retValue TO formonly.storageValue
            END IF

         WHEN "keys"
            CALL ui.Interface.frontCall(
               "localStorage", "keys",
               [], [result]
            )
            IF result IS NULL OR result.getLength() = 0 THEN
               LET result = "(localStorage is empty)"
            ELSE
               LET result = SFMT("Stored keys:\n%1", result)
            END IF

         WHEN "removeItem"
            IF storageKey IS NULL OR storageKey.trimRight() = "" THEN
               ERROR "Enter a Key first"
               RETURN
            END IF
            CALL ui.Interface.frontCall(
               "localStorage", "removeItem",
               [storageKey], []
            )
            LET result = SFMT("Key '%1' removed from localStorage", storageKey)

         WHEN "clear"
            CALL ui.Interface.frontCall(
               "localStorage", "clear",
               [], []
            )
            LET result = "All localStorage data cleared"

         OTHERWISE
            LET result = SFMT("Unknown action: %1", action)

      END CASE
   CATCH
      LET result = SFMT("Error %1: %2", STATUS, err_get(STATUS))
   END TRY

   DISPLAY result TO formonly.result
   MESSAGE SFMT("[%1] => %2", action, result)

END FUNCTION
