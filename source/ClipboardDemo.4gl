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
   DEFINE resultStatus BOOLEAN
   DEFINE clipboardText STRING
   DEFINE outputText STRING

   CASE cbAction
      WHEN "cbAdd"
         IF inputText IS NULL THEN
            ERROR "Enter text in the Input field first"
            RETURN
         END IF
         CALL ui.Interface.frontCall(
            "standard", "cbAdd",
            [inputText], [resultStatus]
         )
         LET outputText = IIF(resultStatus,
            "Text added to clipboard",
            "Failed to add text to clipboard")

      WHEN "cbClear"
         CALL ui.Interface.frontCall(
            "standard", "cbClear",
            [], [resultStatus]
         )
         LET outputText = IIF(resultStatus,
            "Clipboard cleared",
            "Failed to clear clipboard")

      WHEN "cbGet"
         CALL ui.Interface.frontCall(
            "standard", "cbGet",
            [], [clipboardText]
         )
         IF clipboardText IS NOT NULL THEN
            LET outputText = clipboardText
         ELSE
            LET outputText = "(clipboard is empty)"
         END IF

      WHEN "cbPaste"
         CALL ui.Interface.frontCall(
            "standard", "cbPaste",
            [], [resultStatus]
         )
         LET outputText = IIF(resultStatus,
            "Pasted into current field",
            "Failed to paste from clipboard")

      WHEN "cbSet"
         IF inputText IS NULL THEN
            ERROR "Enter text in the Input field first"
            RETURN
         END IF
         CALL ui.Interface.frontCall(
            "standard", "cbSet",
            [inputText], [resultStatus]
         )
         LET outputText = IIF(resultStatus,
            "Clipboard content set",
            "Failed to set clipboard content")

   END CASE

   DISPLAY outputText TO formonly.outputText

END FUNCTION #executeAction
