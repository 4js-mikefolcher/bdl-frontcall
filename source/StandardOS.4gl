IMPORT FGL com.fourjs.fclib.OSLib
IMPORT FGL com.fourjs.fclib.FrontCallLib

PUBLIC FUNCTION executeProgram(operation STRING) RETURNS ()
   DEFINE windowTitle STRING
   DEFINE fileName STRING
   DEFINE tmpFileName STRING
   DEFINE wildcards DYNAMIC ARRAY OF STRING = [
      "*.exe",
      "*.app",
      "*.sh",
      "*.*"
   ]
   DEFINE r FrontCallLib.t_result
   DEFINE runMode BOOLEAN

   LET windowTitle = IIF(operation == "execute", "Execute Program", "Open File with Program")
   CALL openWindow("FileExecute", windowTitle)

   INPUT fileName, runMode WITHOUT DEFAULTS
      FROM formonly.textField, formonly.runMode
      ATTRIBUTES(UNBUFFERED)
      BEFORE INPUT
         CALL setRunModeCombo()
         DISPLAY "Select run mode:" TO formonly.runLabel
         IF operation == "execute" THEN
            DISPLAY "Select a file to execute:" TO formonly.fieldLabel
         ELSE
            LET runMode = FALSE
            CALL DIALOG.setFieldActive("formonly.runMode", FALSE)
            DISPLAY "Select a file to open with a frontend program:" TO formonly.fieldLabel
         END IF
      ON ACTION CANCEL
         EXIT INPUT
      ON ACTION zoom
         LET tmpFileName = pickFrontendFile(wildcards, "Select a file to execute/open")
         IF tmpFileName IS NOT NULL THEN
            LET fileName = tmpFileName
         END IF
      AFTER INPUT
         IF fileName IS NULL OR runMode IS NULL THEN
            ERROR "Select a file and a run mode"
            CONTINUE INPUT
         END IF
         IF operation == "execute" THEN
            LET r = OSLib.execute(fileName, runMode)
         ELSE
            LET r = OSLib.shellExec(fileName)
         END IF
         IF r.success THEN
            MESSAGE r.message
         ELSE
            ERROR r.message
         END IF
         CONTINUE INPUT

   END INPUT

   LET int_flag = FALSE
   CALL closeWindow()

END FUNCTION

PUBLIC FUNCTION frontendInfo() RETURNS ()
   DEFINE feData DYNAMIC ARRAY OF RECORD
      propName  STRING,
      propValue STRING
   END RECORD
   DEFINE propList DYNAMIC ARRAY OF STRING = [
      "browserName",
      "colorScheme",
      "dataDirectory",
      "deviceId",
      "deviceModel",
      "feName",
      "fePath",
      "freeStorageSpace",
      "ip",
      "numScreens",
      "osType",
      "osVersion",
      "ppi",
      "screenResolution",
      "target",
      "userPreferredLang",
      "windowSize"
   ]

   CALL openWindow("FrontendInfo", "Frontend Information")

   CALL loadFrontendInfo(propList, feData)

   DISPLAY ARRAY feData TO srFeInfo.*

      ON ACTION refresh ATTRIBUTES(TEXT="Refresh", IMAGE="fa-refresh")
         CALL loadFrontendInfo(propList, feData)

      ON ACTION CANCEL
         EXIT DISPLAY

   END DISPLAY

   LET int_flag = FALSE
   CALL closeWindow()

END FUNCTION #frontendInfo

PUBLIC FUNCTION frontendEnvVar() RETURNS ()
   DEFINE varName STRING
   DEFINE r OSLib.t_osStringResult

   CALL openWindow("FrontendEnv", "Frontend Environment Variable")

   INPUT varName WITHOUT DEFAULTS FROM formonly.feVariable
      ATTRIBUTES(UNBUFFERED)
      BEFORE INPUT
         DISPLAY "Enter a Frontend Variable:" TO formonly.fieldLabel
      ON ACTION CANCEL
         EXIT INPUT
      AFTER INPUT
         IF varName IS NULL THEN
            ERROR "Select a environment variable to display"
         ELSE
            LET r = OSLib.getEnv(varName)
            IF r.success THEN
               DISPLAY r.value TO formonly.feValue
            ELSE
               DISPLAY "" TO formonly.feValue
               ERROR r.message
            END IF
         END IF
         CONTINUE INPUT
   END INPUT

   LET int_flag = FALSE
   CALL closeWindow()

END FUNCTION #frontendEnvVar

PUBLIC FUNCTION generateHardcopy() RETURNS ()
   DEFINE r FrontCallLib.t_result

   LET r = OSLib.hardCopy(1)
   IF r.success THEN
      MESSAGE r.message
   ELSE
      ERROR r.message
   END IF

END FUNCTION #generateHardcopy

PUBLIC FUNCTION launchUrl() RETURNS ()
   DEFINE webUrl STRING
   DEFINE r FrontCallLib.t_result

   CALL openWindow("WebsiteLauncher", "Open URL")

   LET webUrl = "https://www.4js.com"
   INPUT webUrl WITHOUT DEFAULTS FROM formonly.webUrl
      ATTRIBUTES(UNBUFFERED)
      BEFORE INPUT
         DISPLAY "In the field below, enter a URL and press OK" TO formonly.fieldLabel
      ON ACTION CANCEL
         EXIT INPUT
      AFTER INPUT
         IF webUrl IS NULL THEN
            ERROR "URL value is missing"
         ELSE
            LET r = OSLib.launchURL(webUrl)
            IF r.success THEN
               MESSAGE r.message
            ELSE
               ERROR r.message
            END IF
         END IF
         CONTINUE INPUT
   END INPUT

   LET int_flag = FALSE
   CALL closeWindow()

END FUNCTION #launchUrl

PUBLIC FUNCTION frontendBrowse(operation STRING) RETURNS ()
   DEFINE browseValue STRING
   DEFINE tmpValue STRING
   DEFINE wildcards DYNAMIC ARRAY OF STRING = ["*.*"]
   DEFINE r FrontCallLib.t_result

   CALL openWindow("FileBrowse", "Frontend Browse")

   INPUT browseValue WITHOUT DEFAULTS FROM formonly.textField
      ATTRIBUTES(UNBUFFERED)
      BEFORE INPUT
         CASE operation
            WHEN "opendir"
               DISPLAY "Select a directory:" TO formonly.fieldLabel
            WHEN "openfile"
               DISPLAY "Select a file:" TO formonly.fieldLabel
            WHEN "openfiles"
               DISPLAY "Select one or more files:" TO formonly.fieldLabel
            WHEN "playsound"
               DISPLAY "Select a sound file:" TO formonly.fieldLabel
               CALL wildcards.clear()
               LET wildcards[1] = "*.mp3"
               LET wildcards[2] = "*.wav"
               LET wildcards[3] = "*.ogg"
               LET wildcards[4] = "*.aac"
            WHEN "savefile"
               DISPLAY "Select a save file:" TO formonly.fieldLabel
               CALL wildcards.clear()
               LET wildcards[1] = "*.txt"
         END CASE
      ON ACTION zoom
         LET tmpValue = NULL
         CASE operation
            WHEN "opendir"
               LET tmpValue = pickFrontendDir("Get a directory")
            WHEN "openfile"
               LET tmpValue = pickFrontendFile(wildcards, "Get a File")
            WHEN "openfiles"
               LET tmpValue = pickFrontendFiles(wildcards, "Get Files")
            WHEN "playsound"
               LET tmpValue = pickFrontendFile(wildcards, "Get a Sound File")
            WHEN "savefile"
               LET tmpValue = pickFrontendSaveFile(wildcards, "Save Text File")
         END CASE
         IF tmpValue IS NOT NULL THEN
            LET browseValue = tmpValue
            DISPLAY tmpValue TO formonly.textInfo
         END IF
      ON ACTION CANCEL
         EXIT INPUT
      AFTER INPUT
         IF operation == "playsound" THEN
            IF browseValue IS NULL THEN
               ERROR "Must select a sound file"
            ELSE
               LET r = OSLib.playSound(browseValue, FALSE)
               IF r.success THEN
                  MESSAGE r.message
               ELSE
                  ERROR r.message
               END IF
            END IF
            CONTINUE INPUT
         END IF
   END INPUT

   LET int_flag = FALSE
   CALL closeWindow()

END FUNCTION #frontendBrowse

PRIVATE FUNCTION loadFrontendInfo(
   propList DYNAMIC ARRAY OF STRING,
   feData DYNAMIC ARRAY OF RECORD
      propName  STRING,
      propValue STRING
   END RECORD
) RETURNS ()
   DEFINE idx INTEGER
   DEFINE r OSLib.t_osStringResult

   FOR idx = 1 TO propList.getLength()
      LET feData[idx].propName = propList[idx]
      LET r = OSLib.feInfo(propList[idx])
      IF r.success THEN
         LET feData[idx].propValue = r.value
      ELSE
         LET feData[idx].propValue = SFMT("(%1)", r.message)
      END IF
   END FOR

END FUNCTION #loadFrontendInfo

PRIVATE FUNCTION pickFrontendFile(wildcards DYNAMIC ARRAY OF STRING, caption STRING) RETURNS STRING
   DEFINE r OSLib.t_osStringResult

   LET r = OSLib.openFile("", "File", joinWildcards(wildcards), caption)
   RETURN r.value

END FUNCTION #pickFrontendFile

PRIVATE FUNCTION pickFrontendDir(caption STRING) RETURNS STRING
   DEFINE r OSLib.t_osStringResult

   LET r = OSLib.openDir("", caption)
   RETURN r.value

END FUNCTION #pickFrontendDir

PRIVATE FUNCTION pickFrontendFiles(wildcards DYNAMIC ARRAY OF STRING, caption STRING) RETURNS STRING
   DEFINE r OSLib.t_osFilesResult

   LET r = OSLib.openFiles("", "File", joinWildcards(wildcards), caption)
   RETURN r.files

END FUNCTION #pickFrontendFiles

PRIVATE FUNCTION pickFrontendSaveFile(wildcards DYNAMIC ARRAY OF STRING, caption STRING) RETURNS STRING
   DEFINE r OSLib.t_osStringResult

   LET r = OSLib.saveFile("", "File", joinWildcards(wildcards), caption)
   RETURN r.value

END FUNCTION #pickFrontendSaveFile

PRIVATE FUNCTION joinWildcards(wildcards DYNAMIC ARRAY OF STRING) RETURNS STRING
   DEFINE wildcardString STRING
   DEFINE idx INTEGER

   FOR idx = 1 TO wildcards.getLength()
      LET wildcardString = SFMT("%1 %2", wildcardString, wildcards[idx])
   END FOR
   RETURN wildcardString.trim()

END FUNCTION #joinWildcards

PRIVATE FUNCTION openWindow(formName STRING, formTitle STRING) RETURNS ()

   OPEN WINDOW osWindow WITH FORM formName
      ATTRIBUTES(TEXT=formTitle)

END FUNCTION #openWindow

PRIVATE FUNCTION closeWindow() RETURNS ()

   TRY
      CLOSE WINDOW osWindow
   CATCH
      #Suppress error
   END TRY

END FUNCTION #closeWindow

PRIVATE FUNCTION setRunModeCombo() RETURNS ()
   DEFINE combo ui.ComboBox

   LET combo = ui.ComboBox.forName("formonly.runMode")
   IF combo IS NOT NULL THEN
      CALL combo.addItem(TRUE, "Run and wait")
      CALL combo.addItem(FALSE, "Run without waiting")
   END IF

END FUNCTION #setRunModeCombo
