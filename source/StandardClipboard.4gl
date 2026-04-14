PUBLIC FUNCTION clipboardAdd() RETURNS ()
   DEFINE cbText STRING
   DEFINE resultStatus BOOLEAN

   CALL openWindow("Add to Clipboard")

   INPUT cbText WITHOUT DEFAULTS FROM formonly.cbText
      ATTRIBUTES(UNBUFFERED)
      BEFORE INPUT
         DISPLAY "Enter text and press OK to add it to the clipboard" TO formonly.cbMessage
      ON ACTION CANCEL
         EXIT INPUT
      AFTER INPUT
         IF cbText IS NULL THEN
            ERROR "You need to enter text to copy to the clipboard"
            CONTINUE INPUT
         END IF
         CALL ui.Interface.frontCall(
            "standard",
            "cbAdd",
            [cbText],
            [resultStatus]
         )
         IF resultStatus THEN
            MESSAGE "Text has been added to the clipboard"
         ELSE
            ERROR "Add to clipboard failed"
            CONTINUE INPUT
         END IF
   END INPUT

   LET int_flag = FALSE
   CALL closeWindow()

END FUNCTION #clipboardAdd

PUBLIC FUNCTION clipboardClear() RETURNS ()
   DEFINE resultStatus BOOLEAN
   DEFINE messageText STRING

   CALL ui.Interface.frontCall(
      "standard",
      "cbClear",
      [],
      [resultStatus]
   )

   IF resultStatus THEN
      LET messageText = "The clipboard has been cleared"
   ELSE
      LET messageText = "The clipboard could NOT be cleared"
   END IF

   MENU "Clipboard Clear"
      ATTRIBUTES(STYLE="dialog", COMMENT=messageText)
      COMMAND "Okay"
         EXIT MENU
   END MENU

END FUNCTION #clipboardClear

PUBLIC FUNCTION clipboardGet() RETURNS ()
   DEFINE cbText STRING

   CALL openWindow("Get Clipboard Content")

   CALL ui.Interface.frontCall(
      "standard",
      "cbGet",
      [],
      [cbText]
   )

   DISPLAY "Below is the text in the clipboard" TO formonly.cbMessage
   DISPLAY cbText TO formonly.cbText

   MENU
      COMMAND "OK"
         EXIT MENU
   END MENU

   CALL closeWindow()

END FUNCTION #clipboardGet

PUBLIC FUNCTION clipboardPaste() RETURNS ()
   DEFINE cbText STRING
   DEFINE resultStatus BOOLEAN

   CALL openWindow("Paste from Clipboard")

   INPUT cbText WITHOUT DEFAULTS FROM formonly.cbText
      ATTRIBUTES(UNBUFFERED)
      BEFORE INPUT
         DISPLAY "Press the paste button to paste the clipboard into the field" TO formonly.cbMessage
      ON ACTION CANCEL
         EXIT INPUT
      ON ACTION paste ATTRIBUTES (TEXT="Paste")
         CALL ui.Interface.frontCall(
            "standard",
            "cbPaste",
            [],
            [resultStatus]
         )
         IF resultStatus THEN
            MESSAGE "Text pasted successfully"
         ELSE
            ERROR "An error occurred attempting to paste the clipboard contents"
         END IF
   END INPUT

   LET int_flag = FALSE
   CALL closeWindow()

END FUNCTION #clipboardPaste

PUBLIC FUNCTION clipboardSet() RETURNS ()
   DEFINE cbText STRING
   DEFINE resultStatus BOOLEAN

   CALL openWindow("Set Clipboard Content")

   INPUT cbText WITHOUT DEFAULTS FROM formonly.cbText
      ATTRIBUTES(UNBUFFERED)
      BEFORE INPUT
         DISPLAY "Enter text and press OK to set clipboard content" TO formonly.cbMessage
      ON ACTION CANCEL
         EXIT INPUT
      AFTER INPUT
         IF cbText IS NULL THEN
            ERROR "You need to enter text to copy to the clipboard"
            CONTINUE INPUT
         END IF
         CALL ui.Interface.frontCall(
            "standard",
            "cbSet",
            [cbText],
            [resultStatus]
         )
         IF resultStatus THEN
            MESSAGE "Text has been copied to the clipboard"
         ELSE
            ERROR "Copy to clipboard failed"
            CONTINUE INPUT
         END IF
   END INPUT

   LET int_flag = FALSE
   CALL closeWindow()

END FUNCTION #clipboardSet

PRIVATE FUNCTION openWindow(windowTitle STRING) RETURNS ()

   OPEN WINDOW cbWindow WITH FORM "Clipboard"
      ATTRIBUTES(TEXT=windowTitle)

END FUNCTION #openWindow

PRIVATE FUNCTION closeWindow() RETURNS ()

   TRY
      CLOSE WINDOW cbWindow
   CATCH
      #suppress error
   END TRY

END FUNCTION #closeWindow
