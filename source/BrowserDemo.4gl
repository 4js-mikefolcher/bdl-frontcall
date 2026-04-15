#
# BrowserDemo.4gl
#
# Standalone demo for browser frontcalls:
#   browser.setApplicationState  - set URL anchor (GBC only)
#   browser.getApplicationState  - read URL anchor (GBC only)
#

MAIN
   DEFINE action    STRING
   DEFINE inputText STRING

   OPEN WINDOW w WITH FORM "BrowserDemo"
      ATTRIBUTES(TEXT="Browser Frontcall Demo")
   CLOSE WINDOW SCREEN

   INPUT action, inputText WITHOUT DEFAULTS
      FROM formonly.action, formonly.inputText
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
         CALL executeAction(action, inputText)
         CONTINUE INPUT

   END INPUT

   CLOSE WINDOW w

END MAIN

# ---------------------------------------------------------------------------
PRIVATE FUNCTION setupCombo() RETURNS ()
   DEFINE combo ui.ComboBox
   LET combo = ui.ComboBox.forName("formonly.action")
   IF combo IS NOT NULL THEN
      CALL combo.addItem("setApplicationState", "browser.setApplicationState")
      CALL combo.addItem("getApplicationState", "browser.getApplicationState")
   END IF
END FUNCTION

# ---------------------------------------------------------------------------
PRIVATE FUNCTION showHint(action STRING) RETURNS ()
   DEFINE hint STRING
   CASE action
      WHEN "setApplicationState"
         LET hint = "Enter an anchor value and press Execute to set the browser URL anchor (GBC only)"
      WHEN "getApplicationState"
         LET hint = "Press Execute to read the current browser URL anchor (GBC only, no input needed)"
      OTHERWISE
         LET hint = "Select a browser frontcall action and press Execute"
   END CASE
   DISPLAY hint TO formonly.fieldLabel
END FUNCTION

# ---------------------------------------------------------------------------
PRIVATE FUNCTION executeAction(action STRING, inputText STRING) RETURNS ()
   DEFINE result STRING

   TRY
      CASE action

         WHEN "setApplicationState"
            IF inputText IS NULL OR inputText.trimRight() = "" THEN
               ERROR "Enter an anchor value in the Anchor Value field"
               RETURN
            END IF
            CALL ui.Interface.frontCall(
               "browser", "setApplicationState",
               [inputText], []
            )
            LET result = SFMT("Anchor set to: #%1", inputText)

         WHEN "getApplicationState"
            CALL ui.Interface.frontCall(
               "browser", "getApplicationState",
               [], [result]
            )
            IF result IS NULL THEN
               LET result = "(no anchor set)"
            ELSE
               LET result = SFMT("Current anchor: #%1", result)
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
