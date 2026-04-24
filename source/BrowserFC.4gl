IMPORT FGL com.fourjs.fclib.BrowserLib
IMPORT FGL com.fourjs.fclib.FrontCallLib

PUBLIC FUNCTION setApplicationState() RETURNS ()
   DEFINE anchor STRING
   DEFINE r FrontCallLib.t_result

   CALL openWindow("BrowserState", "Set Application State")

   INPUT anchor WITHOUT DEFAULTS FROM formonly.anchorValue
      ATTRIBUTES(UNBUFFERED)
      BEFORE INPUT
         DISPLAY "Enter an anchor value to set in the browser URL (GBC only)" TO formonly.fieldLabel
      ON ACTION CANCEL
         EXIT INPUT
      AFTER INPUT
         IF anchor IS NULL THEN
            ERROR "Anchor value is required"
            CONTINUE INPUT
         END IF
         LET r = BrowserLib.setAppState(anchor)
         IF r.success THEN
            MESSAGE r.message
         ELSE
            ERROR r.message
         END IF
         CONTINUE INPUT
   END INPUT

   LET int_flag = FALSE
   CALL closeWindow()

END FUNCTION #setApplicationState

PUBLIC FUNCTION getApplicationState() RETURNS ()
   DEFINE r BrowserLib.t_bwGetResult

   LET r = BrowserLib.getAppState()

   MENU "Browser Application State"
      ATTRIBUTES(STYLE="dialog", COMMENT=r.message)
      COMMAND "OK"
         EXIT MENU
   END MENU

END FUNCTION #getApplicationState

PRIVATE FUNCTION openWindow(formName STRING, formTitle STRING) RETURNS ()

   OPEN WINDOW browserWindow WITH FORM formName
      ATTRIBUTES(TEXT=formTitle)

END FUNCTION #openWindow

PRIVATE FUNCTION closeWindow() RETURNS ()

   TRY
      CLOSE WINDOW browserWindow
   CATCH
      #suppress error
   END TRY

END FUNCTION #closeWindow
