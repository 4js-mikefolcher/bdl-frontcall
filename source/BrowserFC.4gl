PUBLIC FUNCTION setApplicationState() RETURNS ()
   DEFINE anchor STRING

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
         CALL ui.Interface.frontCall(
            "browser",
            "setApplicationState",
            [anchor],
            []
         )
         MESSAGE SFMT("Browser anchor set to: #%1", anchor)
         CONTINUE INPUT
   END INPUT

   LET int_flag = FALSE
   CALL closeWindow()

END FUNCTION #setApplicationState

PUBLIC FUNCTION getApplicationState() RETURNS ()
   DEFINE anchor STRING

   CALL ui.Interface.frontCall(
      "browser",
      "getApplicationState",
      [],
      [anchor]
   )

   IF anchor IS NULL THEN
      LET anchor = "(no anchor set)"
   END IF

   MENU "Browser Application State"
      ATTRIBUTES(STYLE="dialog", COMMENT=SFMT("Current URL anchor: #%1", anchor))
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
