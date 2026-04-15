IMPORT util

#
# FileDemo.4gl
#
# Standalone demo for file handling frontcalls:
#   standard.openDir   - directory picker dialog
#   standard.openFile  - single file picker dialog
#   standard.openFiles - multi-file picker dialog
#   standard.saveFile  - save-file dialog
#   standard.playSound - play an audio file on the frontend
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
         # Set sensible default wildcards for the selected action
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

# ---------------------------------------------------------------------------
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

# ---------------------------------------------------------------------------
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

# ---------------------------------------------------------------------------
PRIVATE FUNCTION executeAction(action STRING, inputText STRING) RETURNS ()
   DEFINE result    STRING
   DEFINE soundFile STRING
   DEFINE files     DYNAMIC ARRAY OF STRING
   DEFINE idx       INTEGER
   DEFINE wildcards STRING

   LET wildcards = IIF(inputText IS NULL OR inputText.trimRight() = "", "*.*", inputText)

   TRY
      CASE action

         WHEN "openDir"
            CALL ui.Interface.frontCall(
               "standard", "openDir",
               ["", "Select a Directory"],
               [result]
            )
            IF result IS NULL THEN
               LET result = "(cancelled)"
            ELSE
               LET result = SFMT("Directory selected:\n%1", result)
            END IF

         WHEN "openFile"
            CALL ui.Interface.frontCall(
               "standard", "openFile",
               ["", "Files", wildcards, "Select a File"],
               [result]
            )
            IF result IS NULL THEN
               LET result = "(cancelled)"
            ELSE
               LET result = SFMT("File selected:\n%1", result)
            END IF

         WHEN "openFiles"
            CALL ui.Interface.frontCall(
               "standard", "openFiles",
               ["", "Files", wildcards, "Select Files"],
               [result]
            )
            IF result IS NULL OR result = "[]" THEN
               LET result = "(cancelled or no files selected)"
            ELSE
               # Parse the JSON array of file paths
               TRY
                  CALL util.JSON.parse(result, files)
                  LET result = SFMT("Selected %1 file(s):\n", files.getLength())
                  FOR idx = 1 TO files.getLength()
                     LET result = result, SFMT("  [%1] %2\n", idx, files[idx])
                  END FOR
               CATCH
                  LET result = SFMT("Files (raw):\n%1", result)
               END TRY
            END IF

         WHEN "saveFile"
            CALL ui.Interface.frontCall(
               "standard", "saveFile",
               ["", "Files", wildcards, "Save File As"],
               [result]
            )
            IF result IS NULL THEN
               LET result = "(cancelled)"
            ELSE
               LET result = SFMT("Save path selected:\n%1", result)
            END IF

         WHEN "playSound"
            # First let the user pick a sound file, then play it
            CALL ui.Interface.frontCall(
               "standard", "openFile",
               ["", "Audio files", wildcards, "Select a Sound File"],
               [soundFile]
            )
            IF soundFile IS NULL THEN
               LET result = "(cancelled — no sound file selected)"
            ELSE
               CALL ui.Interface.frontCall(
                  "standard", "playSound",
                  [soundFile, TRUE], []
               )
               LET result = SFMT("Played sound file:\n%1", soundFile)
            END IF

         OTHERWISE
            LET result = SFMT("Unknown action: %1", action)

      END CASE
   CATCH
      LET result = SFMT("Error %1: %2", STATUS, err_get(STATUS))
   END TRY

   DISPLAY result TO formonly.result
   MESSAGE SFMT("[%1] => done", action)

END FUNCTION
