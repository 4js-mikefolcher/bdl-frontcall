#
# MonitorDemo.4gl
#
# Standalone demo for the monitor frontcall (GDC only):
#   monitor.update - apply a GDC monitor configuration update file
#

IMPORT FGL com.fourjs.fclib.MonitorLib
IMPORT FGL com.fourjs.fclib.FrontCallLib

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

PRIVATE FUNCTION setupCombo() RETURNS ()
   DEFINE combo ui.ComboBox
   LET combo = ui.ComboBox.forName("formonly.action")
   IF combo IS NOT NULL THEN
      CALL combo.addItem("update", "monitor.update")
   END IF
END FUNCTION

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

PRIVATE FUNCTION executeAction(action STRING, updatePath STRING, warningText STRING) RETURNS ()
   DEFINE r FrontCallLib.t_result
   DEFINE result STRING

   CASE action

      WHEN "update"
         IF updatePath IS NULL OR updatePath.trimRight() = "" THEN
            ERROR "Enter the update file path first"
            RETURN
         END IF
         LET r = MonitorLib.update(updatePath, warningText, FALSE)
         LET result = r.message

      OTHERWISE
         LET result = SFMT("Unknown action: %1", action)

   END CASE

   DISPLAY result TO formonly.result
   MESSAGE SFMT("[%1] => %2", action, result)

END FUNCTION
