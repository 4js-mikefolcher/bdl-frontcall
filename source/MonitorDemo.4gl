#
# MonitorDemo.4gl
#
# Standalone demo for the monitor frontcall (GDC only):
#   monitor.update - apply a GDC monitor configuration update file
#
# Usage: provide the path to a GDC .upd/.json update file and optional
# warning text to display to the user before the update is applied.
#

MAIN
   DEFINE action      STRING
   DEFINE updatePath  STRING
   DEFINE warningText STRING

   OPEN WINDOW w WITH FORM "MonitorDemo"
      ATTRIBUTES(TEXT="Monitor Frontcall Demo")
   CLOSE WINDOW SCREEN

   INPUT action, updatePath, warningText WITHOUT DEFAULTS
      FROM formonly.action, formonly.updatePath, formonly.warningText
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
         CALL executeAction(action, updatePath, warningText)
         CONTINUE INPUT

   END INPUT

   CLOSE WINDOW w

END MAIN

# ---------------------------------------------------------------------------
PRIVATE FUNCTION setupCombo() RETURNS ()
   DEFINE combo ui.ComboBox
   LET combo = ui.ComboBox.forName("formonly.action")
   IF combo IS NOT NULL THEN
      CALL combo.addItem("update", "monitor.update")
   END IF
END FUNCTION

# ---------------------------------------------------------------------------
PRIVATE FUNCTION showHint(action STRING) RETURNS ()
   DEFINE hint STRING
   CASE action
      WHEN "update"
         LET hint = "GDC only: enter path to update file, optional warning text, then Execute"
      OTHERWISE
         LET hint = "monitor.update applies a GDC configuration update file (GDC only)"
   END CASE
   DISPLAY hint TO formonly.fieldLabel
END FUNCTION

# ---------------------------------------------------------------------------
PRIVATE FUNCTION executeAction(action STRING, updatePath STRING, warningText STRING) RETURNS ()
   DEFINE result STRING

   TRY
      CASE action

         WHEN "update"
            IF updatePath IS NULL OR updatePath.trimRight() = "" THEN
               ERROR "Enter the update file path first"
               RETURN
            END IF
            CALL ui.Interface.frontCall(
               "monitor", "update",
               [updatePath, warningText],
               [result]
            )
            IF result IS NULL THEN
               LET result = "monitor.update completed (no return value)"
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
