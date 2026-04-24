IMPORT FGL com.fourjs.fclib.MonitorLib
IMPORT FGL com.fourjs.fclib.OSLib
IMPORT FGL com.fourjs.fclib.FrontCallLib

PUBLIC FUNCTION monitorUpdate() RETURNS ()
   DEFINE updatePath STRING
   DEFINE warningText STRING
   DEFINE r FrontCallLib.t_result

   CALL openWindow("MonitorUpdate", "GDC Monitor Update")

   INPUT updatePath, warningText WITHOUT DEFAULTS
      FROM formonly.updatePath, formonly.warningText
      ATTRIBUTES(UNBUFFERED)
      BEFORE INPUT
         DISPLAY "Enter the path to the GDC update file (GDC only)" TO formonly.fieldLabel
      ON ACTION CANCEL
         EXIT INPUT
      ON ACTION zoom
         CALL pickFile() RETURNING updatePath
      AFTER INPUT
         IF updatePath IS NULL THEN
            ERROR "Update file path is required"
            CONTINUE INPUT
         END IF
         LET r = MonitorLib.update(updatePath, warningText, FALSE)
         IF r.success THEN
            MESSAGE r.message
         ELSE
            ERROR r.message
         END IF
         CONTINUE INPUT
   END INPUT

   LET int_flag = FALSE
   CALL closeWindow()

END FUNCTION #monitorUpdate

PRIVATE FUNCTION pickFile() RETURNS STRING
   DEFINE r OSLib.t_osStringResult

   LET r = OSLib.openFile("", "Update File", "*.*", "Select GDC Update File")
   IF NOT r.success THEN
      ERROR r.message
      RETURN NULL
   END IF
   RETURN r.value

END FUNCTION #pickFile

PRIVATE FUNCTION openWindow(formName STRING, formTitle STRING) RETURNS ()

   OPEN WINDOW monitorWindow WITH FORM formName
      ATTRIBUTES(TEXT=formTitle)

END FUNCTION #openWindow

PRIVATE FUNCTION closeWindow() RETURNS ()

   TRY
      CLOSE WINDOW monitorWindow
   CATCH
      #suppress error
   END TRY

END FUNCTION #closeWindow
