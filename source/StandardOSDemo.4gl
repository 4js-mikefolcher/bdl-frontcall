#
# StandardOSDemo.4gl
#
# Standalone demo for standard OS/file frontcalls:
#   standard.launchURL  - open URL in system browser
#   standard.feInfo     - query a frontend property
#   standard.getEnv     - read a frontend environment variable
#   standard.openDir    - frontend directory picker dialog
#   standard.openFile   - frontend single-file picker dialog
#   standard.openFiles  - frontend multi-file picker dialog
#   standard.saveFile   - frontend save-file dialog
#   standard.playSound  - play an audio file on the frontend
#   standard.execute    - run a program on the frontend (GDC only)
#   standard.shellExec  - open a file with its associated program (GDC only)
#

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

# ---------------------------------------------------------------------------
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

# ---------------------------------------------------------------------------
PRIVATE FUNCTION showHint(action STRING) RETURNS ()
   DEFINE hint STRING
   CASE action
      WHEN "launchURL"
         LET hint = "Input: URL (e.g. https://fourjs.com) — press Execute to open in browser"
      WHEN "feInfo"
         LET hint = "Input: property name (browserName | osType | osVersion | screenResolution | feName | ip | windowSize | target | ppi | numScreens | userPreferredLang | colorScheme | deviceId | deviceModel | fePath | dataDirectory | freeStorageSpace) — press Execute"
      WHEN "getEnv"
         LET hint = "Input: frontend environment variable name (e.g. PATH, HOME) — press Execute"
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

# ---------------------------------------------------------------------------
PRIVATE FUNCTION executeAction(action STRING, inputText STRING) RETURNS ()
   DEFINE result    STRING
   DEFINE bResult   BOOLEAN
   DEFINE wildcards DYNAMIC ARRAY OF STRING

   CALL wildcards.clear()
   LET wildcards[1] = "*.*"

   TRY
      CASE action

         WHEN "launchURL"
            IF inputText IS NULL OR inputText.trimRight() = "" THEN
               ERROR "Enter a URL in the Input field"
               RETURN
            END IF
            CALL ui.Interface.frontCall(
               "standard", "launchURL",
               [inputText], []
            )
            LET result = SFMT("Launched URL: %1", inputText)

         WHEN "feInfo"
            IF inputText IS NULL OR inputText.trimRight() = "" THEN
               ERROR "Enter a frontend property name in the Input field"
               RETURN
            END IF
            CALL ui.Interface.frontCall(
               "standard", "feInfo",
               [inputText], [result]
            )
            LET result = SFMT("%1 = %2", inputText, result)

         WHEN "getEnv"
            IF inputText IS NULL OR inputText.trimRight() = "" THEN
               ERROR "Enter an environment variable name in the Input field"
               RETURN
            END IF
            CALL ui.Interface.frontCall(
               "standard", "getEnv",
               [inputText], [result]
            )
            LET result = SFMT("%1 = %2", inputText, IIF(result IS NULL, "(not set)", result))

         WHEN "openDir"
            CALL ui.Interface.frontCall(
               "standard", "openDir",
               ["", "Select a Directory"],
               [result]
            )
            IF result IS NULL THEN LET result = "(cancelled)" END IF

         WHEN "openFile"
            CALL ui.Interface.frontCall(
               "standard", "openFile",
               ["", "File", "*.*", "Select a File"],
               [result]
            )
            IF result IS NULL THEN LET result = "(cancelled)" END IF

         WHEN "openFiles"
            CALL ui.Interface.frontCall(
               "standard", "openFiles",
               ["", "File", "*.*", "Select Files"],
               [result]
            )
            IF result IS NULL THEN LET result = "(cancelled)" END IF

         WHEN "saveFile"
            CALL ui.Interface.frontCall(
               "standard", "saveFile",
               ["", "File", "*.*", "Save File As"],
               [result]
            )
            IF result IS NULL THEN LET result = "(cancelled)" END IF

         WHEN "playSound"
            IF inputText IS NULL OR inputText.trimRight() = "" THEN
               ERROR "Enter the path to an audio file in the Input field"
               RETURN
            END IF
            CALL ui.Interface.frontCall(
               "standard", "playSound",
               [inputText], []
            )
            LET result = SFMT("Playing: %1", inputText)

         WHEN "execute"
            IF inputText IS NULL OR inputText.trimRight() = "" THEN
               ERROR "Enter the program path in the Input field (GDC only)"
               RETURN
            END IF
            CALL ui.Interface.frontCall(
               "standard", "execute",
               [inputText, TRUE],
               [bResult]
            )
            LET result = IIF(bResult,
               SFMT("Executed: %1", inputText),
               SFMT("execute returned FALSE for: %1", inputText))

         WHEN "shellExec"
            IF inputText IS NULL OR inputText.trimRight() = "" THEN
               ERROR "Enter the file path in the Input field (GDC only)"
               RETURN
            END IF
            CALL ui.Interface.frontCall(
               "standard", "shellExec",
               [inputText], [bResult]
            )
            LET result = IIF(bResult,
               SFMT("shellExec: %1", inputText),
               SFMT("shellExec returned FALSE for: %1", inputText))

         OTHERWISE
            LET result = SFMT("Unknown action: %1", action)

      END CASE
   CATCH
      LET result = SFMT("Error %1: %2", STATUS, err_get(STATUS))
   END TRY

   DISPLAY result TO formonly.result
   MESSAGE SFMT("[%1] => %2", action, result)

END FUNCTION
