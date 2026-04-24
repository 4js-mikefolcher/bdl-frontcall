IMPORT util
IMPORT FGL com.fourjs.fclib.OSLib
IMPORT FGL com.fourjs.fclib.FrontCallLib

#
# FileDemo.4gl
#
# Standalone demo for file handling frontcalls via OSLib — no inline
# ui.Interface.frontCall in this module.
#

MAIN
   DEFINE action    STRING
   DEFINE inputText STRING

   OPEN WINDOW w WITH FORM "FileDemo"
      ATTRIBUTES(TEXT="File Handling Frontcall Demo")
   CLOSE WINDOW SCREEN

   INPUT action, inputText WITHOUT DEFAULTS
      FROM formonly.action, formonly.inputText
      ATTRIBUTES(UNBUFFERED, accept=FALSE)

      BEFORE INPUT
         CALL setupCombo()
         CALL showHint(NULL)

      ON CHANGE action
         CALL showHint(action)
         CASE action
            WHEN "openFile"
               LET inputText = "*.* *.txt *.pdf *.jpg *.png"
            WHEN "openFiles"
               LET inputText = "*.* *.txt *.pdf *.jpg *.png"
            WHEN "saveFile"
               LET inputText = "*.txt"
            WHEN "playSound"
               LET inputText = "*.mp3 *.wav *.ogg *.aac"
            OTHERWISE
               LET inputText = ""
         END CASE

      ON ACTION execute ATTRIBUTES(TEXT="Execute", IMAGE="fa-play")
         ACCEPT INPUT

      ON ACTION CANCEL
         EXIT INPUT

      AFTER INPUT
         IF action IS NULL THEN
            ERROR "Select an action first"
            CONTINUE INPUT
         END IF
         CALL executeAction(action, inputText)
         CONTINUE INPUT

   END INPUT

   CLOSE WINDOW w

END MAIN

PRIVATE FUNCTION setupCombo() RETURNS ()
   DEFINE combo ui.ComboBox
   LET combo = ui.ComboBox.forName("formonly.action")
   IF combo IS NOT NULL THEN
      CALL combo.addItem("openDir",   "standard.openDir")
      CALL combo.addItem("openFile",  "standard.openFile")
      CALL combo.addItem("openFiles", "standard.openFiles")
      CALL combo.addItem("saveFile",  "standard.saveFile")
      CALL combo.addItem("playSound", "standard.playSound")
   END IF
END FUNCTION

PRIVATE FUNCTION showHint(action STRING) RETURNS ()
   DEFINE hint STRING
   CASE action
      WHEN "openDir"
         LET hint = "Press Execute to open a directory picker dialog (no wildcards needed)"
      WHEN "openFile"
         LET hint = "Wildcards: space-separated extensions (e.g. *.jpg *.png) — press Execute to pick a file"
      WHEN "openFiles"
         LET hint = "Wildcards: space-separated extensions — press Execute to pick multiple files"
      WHEN "saveFile"
         LET hint = "Wildcards: file type to save (e.g. *.txt) — press Execute to open save dialog"
      WHEN "playSound"
         LET hint = "Wildcards: audio extensions — press Execute to pick and play a sound file"
      OTHERWISE
         LET hint = "Select a file handling action and press Execute"
   END CASE
   DISPLAY hint TO formonly.fieldLabel
END FUNCTION

PRIVATE FUNCTION executeAction(action STRING, inputText STRING) RETURNS ()
   DEFINE r FrontCallLib.t_result
   DEFINE sR OSLib.t_osStringResult
   DEFINE fR OSLib.t_osFilesResult
   DEFINE result STRING
   DEFINE files DYNAMIC ARRAY OF STRING
   DEFINE idx INTEGER
   DEFINE wildcards STRING

   LET wildcards = IIF(inputText IS NULL OR inputText.trimRight() = "", "*.*", inputText)

   CASE action

      WHEN "openDir"
         LET sR = OSLib.openDir("", "Select a Directory")
         LET result = sR.message

      WHEN "openFile"
         LET sR = OSLib.openFile("", "Files", wildcards, "Select a File")
         LET result = sR.message

      WHEN "openFiles"
         LET fR = OSLib.openFiles("", "Files", wildcards, "Select Files")
         IF NOT fR.success OR fR.files IS NULL OR fR.files = "[]" THEN
            LET result = fR.message
         ELSE
            TRY
               CALL util.JSON.parse(fR.files, files)
               LET result = SFMT("Selected %1 file(s):\n", files.getLength())
               FOR idx = 1 TO files.getLength()
                  LET result = result, SFMT("  [%1] %2\n", idx, files[idx])
               END FOR
            CATCH
               LET result = SFMT("Files (raw):\n%1", fR.files)
            END TRY
         END IF

      WHEN "saveFile"
         LET sR = OSLib.saveFile("", "Files", wildcards, "Save File As")
         LET result = sR.message

      WHEN "playSound"
         LET sR = OSLib.openFile("", "Audio files", wildcards, "Select a Sound File")
         IF NOT sR.success OR sR.value IS NULL THEN
            LET result = sR.message
         ELSE
            LET r = OSLib.playSound(sR.value, TRUE)
            LET result = SFMT("%1\n%2", sR.message, r.message)
         END IF

      OTHERWISE
         LET result = SFMT("Unknown action: %1", action)

   END CASE

   DISPLAY result TO formonly.result
   MESSAGE SFMT("[%1] => done", action)

END FUNCTION
