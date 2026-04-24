IMPORT FGL com.fourjs.fclib.ClipboardLib
IMPORT FGL com.fourjs.fclib.FrontCallLib

PUBLIC FUNCTION clipboardAdd() RETURNS ()
   DEFINE cbText STRING
   DEFINE r FrontCallLib.t_result

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
         LET r = ClipboardLib.add(cbText)
         IF r.success THEN
            MESSAGE r.message
         ELSE
            ERROR r.message
            CONTINUE INPUT
         END IF
   END INPUT

   LET int_flag = FALSE
   CALL closeWindow()

END FUNCTION #clipboardAdd

PUBLIC FUNCTION clipboardClear() RETURNS ()
   DEFINE r FrontCallLib.t_result

   LET r = ClipboardLib.clear()

   MENU "Clipboard Clear"
      ATTRIBUTES(STYLE="dialog", COMMENT=r.message)
      COMMAND "Okay"
         EXIT MENU
   END MENU

END FUNCTION #clipboardClear

PUBLIC FUNCTION clipboardGet() RETURNS ()
   DEFINE r ClipboardLib.t_cbGetResult

   CALL openWindow("Get Clipboard Content")

   LET r = ClipboardLib.get()

   IF r.success THEN
      DISPLAY "Below is the text in the clipboard" TO formonly.cbMessage
      DISPLAY r.text TO formonly.cbText
   ELSE
      DISPLAY r.message TO formonly.cbMessage
      DISPLAY "" TO formonly.cbText
   END IF

   MENU
      COMMAND "OK"
         EXIT MENU
   END MENU

   CALL closeWindow()

END FUNCTION #clipboardGet

PUBLIC FUNCTION clipboardPaste() RETURNS ()
   DEFINE cbText STRING
   DEFINE r FrontCallLib.t_result

   CALL openWindow("Paste from Clipboard")

   INPUT cbText WITHOUT DEFAULTS FROM formonly.cbText
      ATTRIBUTES(UNBUFFERED)
      BEFORE INPUT
         DISPLAY "Press the paste button to paste the clipboard into the field" TO formonly.cbMessage
      ON ACTION CANCEL
         EXIT INPUT
      ON ACTION paste ATTRIBUTES (TEXT="Paste")
         LET r = ClipboardLib.paste()
         IF r.success THEN
            MESSAGE r.message
         ELSE
            ERROR r.message
         END IF
   END INPUT

   LET int_flag = FALSE
   CALL closeWindow()

END FUNCTION #clipboardPaste

PUBLIC FUNCTION clipboardSet() RETURNS ()
   DEFINE cbText STRING
   DEFINE r FrontCallLib.t_result

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
         LET r = ClipboardLib.set(cbText)
         IF r.success THEN
            MESSAGE r.message
         ELSE
            ERROR r.message
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
