IMPORT FGL com.fourjs.fclib.ClipboardLib
IMPORT FGL com.fourjs.fclib.FrontCallLib

MAIN
   DEFINE cbAction STRING
   DEFINE inputText STRING

   OPEN WINDOW w WITH FORM "ClipboardDemo"
      ATTRIBUTES(TEXT="Clipboard Frontcall Demo")
   CLOSE WINDOW SCREEN

   INPUT cbAction, inputText WITHOUT DEFAULTS
      FROM formonly.cbAction, formonly.inputText
      ATTRIBUTES(UNBUFFERED, accept=FALSE)
      BEFORE INPUT
         DISPLAY "Select a clipboard action, enter text if needed, and press Execute"
            TO formonly.fieldLabel
         CALL setupActionCombo()
      ON ACTION execute ATTRIBUTES(TEXT="Execute", IMAGE="fa-play")
         ACCEPT INPUT
      ON ACTION CANCEL
         EXIT INPUT
      AFTER INPUT
         IF cbAction IS NULL THEN
            ERROR "Select an action first"
            CONTINUE INPUT
         END IF
         CALL executeAction(cbAction, inputText)
         CONTINUE INPUT
   END INPUT

   CLOSE WINDOW w

END MAIN

PRIVATE FUNCTION setupActionCombo() RETURNS ()
   DEFINE combo ui.ComboBox

   LET combo = ui.ComboBox.forName("formonly.cbAction")
   IF combo IS NOT NULL THEN
      CALL combo.addItem("cbAdd", "Add to Clipboard")
      CALL combo.addItem("cbClear", "Clear Clipboard")
      CALL combo.addItem("cbGet", "Get Clipboard")
      CALL combo.addItem("cbPaste", "Paste from Clipboard")
      CALL combo.addItem("cbSet", "Set Clipboard")
   END IF

END FUNCTION #setupActionCombo

PRIVATE FUNCTION executeAction(cbAction STRING, inputText STRING) RETURNS ()
   DEFINE r FrontCallLib.t_result
   DEFINE getR ClipboardLib.t_cbGetResult
   DEFINE outputText STRING

   CASE cbAction
      WHEN "cbAdd"
         IF inputText IS NULL THEN
            ERROR "Enter text in the Input field first"
            RETURN
         END IF
         LET r = ClipboardLib.add(inputText)
         LET outputText = r.message

      WHEN "cbClear"
         LET r = ClipboardLib.clear()
         LET outputText = r.message

      WHEN "cbGet"
         LET getR = ClipboardLib.get()
         IF getR.success THEN
            IF getR.text IS NOT NULL THEN
               LET outputText = getR.text
            ELSE
               LET outputText = "(clipboard is empty)"
            END IF
         ELSE
            LET outputText = getR.message
         END IF

      WHEN "cbPaste"
         LET r = ClipboardLib.paste()
         LET outputText = r.message

      WHEN "cbSet"
         IF inputText IS NULL THEN
            ERROR "Enter text in the Input field first"
            RETURN
         END IF
         LET r = ClipboardLib.set(inputText)
         LET outputText = r.message

   END CASE

   DISPLAY outputText TO formonly.outputText

END FUNCTION #executeAction
