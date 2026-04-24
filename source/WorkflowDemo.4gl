#
# WorkflowDemo.4gl
#
# Standalone demo for the WorkflowLib composite workflows (GDC only):
#   WorkflowLib.getClientHome   - report the client user's home directory
#   WorkflowLib.putAndOpen      - copy a server file to the client, then
#                                 open it with the OS-associated program
#

IMPORT FGL com.fourjs.fclib.WorkflowLib

MAIN
   DEFINE action       STRING
   DEFINE serverPath   STRING
   DEFINE clientSubdir STRING

   OPEN WINDOW w WITH FORM "WorkflowDemo"
      ATTRIBUTES(TEXT="Workflow Library Demo")
   CLOSE WINDOW SCREEN

   INPUT action, serverPath, clientSubdir WITHOUT DEFAULTS
      FROM formonly.action, formonly.serverPath, formonly.clientSubdir
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
         CALL executeAction(action, serverPath, clientSubdir)
         CONTINUE INPUT

   END INPUT

   CLOSE WINDOW w

END MAIN

PRIVATE FUNCTION setupCombo() RETURNS ()
   DEFINE combo ui.ComboBox
   LET combo = ui.ComboBox.forName("formonly.action")
   IF combo IS NOT NULL THEN
      CALL combo.addItem("getClientHome", "WorkflowLib.getClientHome")
      CALL combo.addItem("putAndOpen",    "WorkflowLib.putAndOpen")
   END IF
END FUNCTION

PRIVATE FUNCTION showHint(action STRING) RETURNS ()
   DEFINE hint STRING
   CASE action
      WHEN "getClientHome"
         LET hint = "GDC only: no input needed — press Execute to read the client user's home directory"
      WHEN "putAndOpen"
         LET hint = "GDC only: enter a Server File Path and optional Client Subdir, then Execute to copy & open"
      OTHERWISE
         LET hint = "Select a WorkflowLib action and press Execute"
   END CASE
   DISPLAY hint TO formonly.fieldLabel
END FUNCTION

PRIVATE FUNCTION executeAction(
   action STRING,
   serverPath STRING,
   clientSubdir STRING
) RETURNS ()
   DEFINE r WorkflowLib.t_wfFileResult
   DEFINE result STRING

   CASE action

      WHEN "getClientHome"
         LET r = WorkflowLib.getClientHome()
         LET result = r.message

      WHEN "putAndOpen"
         IF serverPath IS NULL OR serverPath.trimRight() = "" THEN
            ERROR "Enter a Server File Path first"
            RETURN
         END IF
         LET r = WorkflowLib.putAndOpen(serverPath, clientSubdir)
         IF r.success THEN
            LET result = SFMT("%1\nClient path: %2", r.message, r.clientPath)
         ELSE
            LET result = SFMT("%1\n(target was: %2)", r.message,
               IIF(r.clientPath IS NULL, "(not determined)", r.clientPath))
         END IF

      OTHERWISE
         LET result = SFMT("Unknown action: %1", action)

   END CASE

   DISPLAY result TO formonly.result
   MESSAGE SFMT("[%1] => %2", action,
      IIF(r.success, "ok", "failed"))

END FUNCTION
