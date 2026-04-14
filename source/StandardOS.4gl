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
   DEFINE resultStatus BOOLEAN
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
         LET tmpFileName = getFrontendFile(wildcards, "Select a file to execute/open")
         IF tmpFileName IS NOT NULL THEN
            LET fileName = tmpFileName
         END IF
      AFTER INPUT
         IF fileName IS NULL OR runMode IS NULL THEN
            ERROR "Select a file and a run mode"
            CONTINUE INPUT
         END IF
         IF operation == "execute" THEN
            CALL ui.Interface.frontCall(
               "standard",
               "execute",
               [fileName, runMode],
               [resultStatus]
            )
         ELSE
            CALL ui.Interface.frontCall(
               "standard",
               "shellExec",
               [fileName],
               [resultStatus]
            )
         END IF
         IF resultStatus THEN
            MESSAGE "Command/file executed successfully"
         ELSE
            ERROR "An error occurred while executing"
         END IF
         CONTINUE INPUT

   END INPUT

   LET int_flag = FALSE
   CALL closeWindow()

END FUNCTION

PUBLIC FUNCTION frontendInfo() RETURNS ()
   DEFINE propName STRING
   DEFINE propValue STRING

   CALL openWindow("FrontendInfo", "Frontend Information")

   INPUT propName WITHOUT DEFAULTS FROM formonly.feInfo
      ATTRIBUTES(UNBUFFERED)
      BEFORE INPUT
         DISPLAY "Select a Frontend Property:" TO formonly.fieldLabel
         CALL setFrontendCombo()
      ON CHANGE feInfo
         IF propName IS NOT NULL THEN
            LET propValue = getFrontendInfo(propName)
            DISPLAY propValue TO formonly.feValue
         END IF
      ON ACTION CANCEL
         EXIT INPUT
      AFTER INPUT
         IF propName IS NULL THEN
            ERROR "Select a property to display"
         ELSE
            LET propValue = getFrontendInfo(propName)
            DISPLAY propValue TO formonly.feValue
         END IF
         CONTINUE INPUT
   END INPUT

   LET int_flag = FALSE
   CALL closeWindow()

END FUNCTION #frontendInfo

PUBLIC FUNCTION frontendEnvVar() RETURNS ()
   DEFINE varName STRING
   DEFINE varValue STRING

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
            CALL ui.Interface.frontCall(
               "standard",
               "getEnv",
               [varName],
               [varValue]
            )
            DISPLAY varValue TO formonly.feValue
         END IF
         CONTINUE INPUT
   END INPUT

   LET int_flag = FALSE
   CALL closeWindow()

END FUNCTION #frontendEnvVar

PUBLIC FUNCTION generateHardcopy()
   DEFINE resultSuccess BOOLEAN

   CALL ui.Interface.frontCall(
      "standard",
      "hardCopy",
      [1],
      [resultSuccess]
   )

   IF resultSuccess THEN
      MESSAGE "Hardcopy generated successfully"
   ELSE
      ERROR "An error occurred generating the hardcopy"
   END IF

END FUNCTION #generateHardcopy

PUBLIC FUNCTION launchUrl() RETURNS ()
   DEFINE webUrl STRING

   CALL openWindow("WebsiteLauncher", "Open URL")

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
            CALL ui.Interface.frontCall(
               "standard",
               "launchURL",
               [webUrl],
               []
            )
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
               LET tmpValue = getFrontendDir("Get a directory")
            WHEN "openfile"
               LET tmpValue = getFrontendFile(wildcards, "Get a File")
            WHEN "openfiles"
               LET tmpValue = getFrontendFiles(wildcards, "Get Files")
            WHEN "playsound"
               LET tmpValue = getFrontendFile(wildcards, "Get a Sound File")
            WHEN "savefile"
               LET tmpValue = getFrontendSaveFile(wildcards, "Save Text File")
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
               CALL ui.Interface.frontCall(
                  "standard",
                  "playSound",
                  [browseValue],
                  []
               )
            END IF
            CONTINUE INPUT
         END IF
   END INPUT

   LET int_flag = FALSE
   CALL closeWindow()

END FUNCTION #frontendBrowse

PRIVATE FUNCTION getFrontendInfo(propName STRING) RETURNS STRING
   DEFINE propValue STRING

   CALL ui.Interface.frontCall(
      "standard",
      "feInfo",
      [propName],
      [propValue]
   )

   RETURN propValue

END FUNCTION

PRIVATE FUNCTION getFrontendFile(wildcards DYNAMIC ARRAY OF STRING, caption STRING) RETURNS STRING
   DEFINE frontendFile STRING
   DEFINE wildcardString STRING
   DEFINE idx INTEGER

   FOR idx = 1 TO wildcards.getLength()
      LET wildcardString = SFMT("%1 %2", wildcardString, wildcards[idx])
   END FOR

   CALL ui.Interface.frontCall(
      "standard",
      "openFile",
      ["", "File", wildcardString.trim(), caption],
      [frontendFile]
   )

   RETURN frontendFile

END FUNCTION #getFrontendFile

PRIVATE FUNCTION getFrontendDir(caption STRING) RETURNS STRING
   DEFINE frontendDir STRING

   CALL ui.Interface.frontCall(
      "standard",
      "openDir",
      ["", caption],
      [frontendDir]
   )

   RETURN frontendDir

END FUNCTION #getFrontendDir

PRIVATE FUNCTION getFrontendFiles(wildcards DYNAMIC ARRAY OF STRING, caption STRING) RETURNS STRING
   DEFINE frontendFiles STRING
   DEFINE wildcardString STRING
   DEFINE idx INTEGER

   FOR idx = 1 TO wildcards.getLength()
      LET wildcardString = SFMT("%1 %2", wildcardString, wildcards[idx])
   END FOR

   CALL ui.Interface.frontCall(
      "standard",
      "openFiles",
      ["", "File", wildcardString.trim(), caption],
      [frontendFiles]
   )

   RETURN frontendFiles

END FUNCTION #getFrontendFiles

PRIVATE FUNCTION getFrontendSaveFile(wildcards DYNAMIC ARRAY OF STRING, caption STRING) RETURNS STRING
   DEFINE frontendFile STRING
   DEFINE wildcardString STRING
   DEFINE idx INTEGER

   FOR idx = 1 TO wildcards.getLength()
      LET wildcardString = SFMT("%1 %2", wildcardString, wildcards[idx])
   END FOR

   CALL ui.Interface.frontCall(
      "standard",
      "saveFile",
      ["", "File", wildcardString.trim(), caption],
      [frontendFile]
   )

   RETURN frontendFile

END FUNCTION #getFrontendSaveFile

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

PRIVATE FUNCTION setFrontendCombo() RETURNS ()
   DEFINE combo ui.ComboBox
   DEFINE valueList DYNAMIC ARRAY OF STRING = [
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
   DEFINE idx INTEGER

   LET combo = ui.ComboBox.forName("formonly.feInfo")
   IF combo IS NOT NULL THEN
      FOR idx = 1 TO valueList.getLength()
         CALL combo.addItem(valueList[idx], valueList[idx])
      END FOR
   END IF

END FUNCTION #setFrontendCombo
