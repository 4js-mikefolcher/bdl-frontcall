PUBLIC FUNCTION monitorUpdate() RETURNS ()
   DEFINE updatePath STRING
   DEFINE warningText STRING
   DEFINE result STRING

   CALL openWindow("MonitorUpdate", "GDC Monitor Update")

   INPUT updatePath, warningText WITHOUT DEFAULTS
      FROM formonly.updatePath, formonly.warningText
      ATTRIBUTES(UNBUFFERED)
      BEFORE INPUT
         DISPLAY "Enter the path to the GDC update file (GDC only)" TO formonly.fieldLabel
      ON ACTION CANCEL
         EXIT INPUT
      ON ACTION zoom
         CALL getUpdateFile() RETURNING updatePath
      AFTER INPUT
         IF updatePath IS NULL THEN
            ERROR "Update file path is required"
            CONTINUE INPUT
         END IF
         TRY
            CALL ui.Interface.frontCall(
               "monitor",
               "update",
               [updatePath, warningText],
               [result]
            )
            MESSAGE SFMT("monitor.update result: %1", result)
         CATCH
            ERROR SFMT("Error: %1", err_get(status))
         END TRY
         CONTINUE INPUT
   END INPUT

   LET int_flag = FALSE
   CALL closeWindow()

END FUNCTION #monitorUpdate

PRIVATE FUNCTION getUpdateFile() RETURNS STRING
   DEFINE filePath STRING

   CALL ui.Interface.frontCall(
      "standard",
      "openFile",
      ["", "Update File", "*.*", "Select GDC Update File"],
      [filePath]
   )

   RETURN filePath

END FUNCTION #getUpdateFile

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
