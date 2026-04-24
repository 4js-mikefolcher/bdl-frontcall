#
# StandardOSDemo.4gl
#
# Standalone demo for standard OS/file frontcalls, all going through
# OSLib now — this module contains no inline ui.Interface.frontCall.
#

IMPORT FGL com.fourjs.fclib.OSLib
IMPORT FGL com.fourjs.fclib.FrontCallLib

MAIN
   DEFINE action    STRING
   DEFINE inputText STRING

   OPEN WINDOW w WITH FORM "StandardOSDemo"
      ATTRIBUTES(TEXT="Standard OS Frontcall Demo")
   CLOSE WINDOW SCREEN

   INPUT action, inputText WITHOUT DEFAULTS
      FROM formonly.action, formonly.inputText
      ATTRIBUTES(UNBUFFERED, accept=FALSE)

      BEFORE INPUT
         CALL setupCombo()
         CALL showHint(NULL)

      ON CHANGE action
         CALL showHint(action)
         IF action = "launchURL" AND (inputText IS NULL OR inputText.trimRight() = "") THEN
            LET inputText = "https://www.4js.com"
         END IF

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
      CALL combo.addItem("launchURL",  "standard.launchURL")
      CALL combo.addItem("feInfo",     "standard.feInfo")
      CALL combo.addItem("getEnv",     "standard.getEnv")
      CALL combo.addItem("openDir",    "standard.openDir")
      CALL combo.addItem("openFile",   "standard.openFile")
      CALL combo.addItem("openFiles",  "standard.openFiles")
      CALL combo.addItem("saveFile",   "standard.saveFile")
      CALL combo.addItem("playSound",  "standard.playSound")
      CALL combo.addItem("execute",    "standard.execute")
      CALL combo.addItem("shellExec",  "standard.shellExec")
   END IF
END FUNCTION

PRIVATE FUNCTION showHint(action STRING) RETURNS ()
   DEFINE hint STRING
   CASE action
      WHEN "launchURL"
         LET hint = "Input: URL (e.g. https://fourjs.com) — press Execute to open in browser"
      WHEN "feInfo"
         LET hint = "Input: property name (browserName | osType | osVersion | screenResolution | feName | ip | windowSize | target | ppi | numScreens | userPreferredLang | colorScheme | deviceId | deviceModel | fePath | dataDirectory | freeStorageSpace) — press Execute"
      WHEN "getEnv"
         LET hint = "Input: frontend environment variable name (e.g. PATH, HOME) — press Execute (GDC only)"
      WHEN "openDir"
         LET hint = "No input needed — press Execute to open a directory picker dialog"
      WHEN "openFile"
         LET hint = "No input needed — press Execute to open a file picker dialog"
      WHEN "openFiles"
         LET hint = "No input needed — press Execute to open a multi-file picker dialog"
      WHEN "saveFile"
         LET hint = "No input needed — press Execute to open a save-file dialog"
      WHEN "playSound"
         LET hint = "Input: path to an audio file (.mp3/.wav) — press Execute to play it"
      WHEN "execute"
         LET hint = "Input: path to a program to execute on the frontend (GDC only) — press Execute"
      WHEN "shellExec"
         LET hint = "Input: path to a file to open with its associated program (GDC only) — press Execute"
      OTHERWISE
         LET hint = "Select a standard OS frontcall action and press Execute"
   END CASE
   DISPLAY hint TO formonly.fieldLabel
END FUNCTION

PRIVATE FUNCTION executeAction(action STRING, inputText STRING) RETURNS ()
   DEFINE r FrontCallLib.t_result
   DEFINE sR OSLib.t_osStringResult
   DEFINE fR OSLib.t_osFilesResult
   DEFINE result STRING

   CASE action

      WHEN "launchURL"
         IF inputText IS NULL OR inputText.trimRight() = "" THEN
            ERROR "Enter a URL in the Input field"
            RETURN
         END IF
         LET r = OSLib.launchURL(inputText)
         LET result = r.message

      WHEN "feInfo"
         IF inputText IS NULL OR inputText.trimRight() = "" THEN
            ERROR "Enter a frontend property name in the Input field"
            RETURN
         END IF
         LET sR = OSLib.feInfo(inputText)
         LET result = sR.message

      WHEN "getEnv"
         IF inputText IS NULL OR inputText.trimRight() = "" THEN
            ERROR "Enter an environment variable name in the Input field"
            RETURN
         END IF
         LET sR = OSLib.getEnv(inputText)
         LET result = sR.message

      WHEN "openDir"
         LET sR = OSLib.openDir("", "Select a Directory")
         LET result = sR.message

      WHEN "openFile"
         LET sR = OSLib.openFile("", "File", "*.*", "Select a File")
         LET result = sR.message

      WHEN "openFiles"
         LET fR = OSLib.openFiles("", "File", "*.*", "Select Files")
         LET result = IIF(fR.success AND fR.files IS NOT NULL AND fR.files != "[]",
            SFMT("Files (raw JSON):\n%1", fR.files), fR.message)

      WHEN "saveFile"
         LET sR = OSLib.saveFile("", "File", "*.*", "Save File As")
         LET result = sR.message

      WHEN "playSound"
         IF inputText IS NULL OR inputText.trimRight() = "" THEN
            ERROR "Enter the path to an audio file in the Input field"
            RETURN
         END IF
         LET r = OSLib.playSound(inputText, FALSE)
         LET result = r.message

      WHEN "execute"
         IF inputText IS NULL OR inputText.trimRight() = "" THEN
            ERROR "Enter the program path in the Input field (GDC only)"
            RETURN
         END IF
         LET r = OSLib.execute(inputText, TRUE)
         LET result = r.message

      WHEN "shellExec"
         IF inputText IS NULL OR inputText.trimRight() = "" THEN
            ERROR "Enter the file path in the Input field (GDC only)"
            RETURN
         END IF
         LET r = OSLib.shellExec(inputText)
         LET result = r.message

      OTHERWISE
         LET result = SFMT("Unknown action: %1", action)

   END CASE

   DISPLAY result TO formonly.result
   MESSAGE SFMT("[%1] => %2", action, result)

END FUNCTION
