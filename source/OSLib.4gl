#
# OSLib — reusable wrappers for file-system / OS / URL frontcalls
# in the "standard" module.
#
# Per-function supported front-ends (see FE_* constants per call):
#   launchURL, feInfo, playSound          all front-ends
#   openDir, openFile, openFiles, saveFile  all front-ends
#   getEnv, execute, shellExec, hardCopy    GDC only
#
# Result types:
#   - FrontCallLib.t_result      launchURL, playSound, execute, shellExec, hardCopy
#   - t_osStringResult           feInfo, getEnv, openDir, openFile, saveFile
#   - t_osFilesResult            openFiles (raw JSON string in .files)
#

PACKAGE com.fourjs.fclib

IMPORT FGL com.fourjs.fclib.FrontCallLib

PRIVATE CONSTANT FE_ALL = "GDC,GMA,GMI,GBC"
PRIVATE CONSTANT FE_GDC = "GDC"

PUBLIC TYPE t_osStringResult RECORD
   success BOOLEAN,
   message STRING,
   value STRING
END RECORD

PUBLIC TYPE t_osFilesResult RECORD
   success BOOLEAN,
   message STRING,
   files STRING
END RECORD

#
# Open a URL with the front-end's default URL handler.
#
PUBLIC FUNCTION launchURL(url STRING) RETURNS FrontCallLib.t_result
   DEFINE r FrontCallLib.t_result

   IF NOT FrontCallLib.isFrontEnd(FE_ALL) THEN
      RETURN FrontCallLib.notSupported("standard.launchURL", FE_ALL)
   END IF

   TRY
      CALL ui.Interface.frontCall(
         "standard", "launchURL",
         [url], [])
      LET r.success = TRUE
      LET r.message = SFMT("URL launched: %1", url)
   CATCH
      LET r = FrontCallLib.caught("standard.launchURL")
   END TRY
   RETURN r

END FUNCTION #launchURL

#
# Query a front-end property by name (browserName, feName, osType, etc.).
#
PUBLIC FUNCTION feInfo(propertyName STRING) RETURNS t_osStringResult
   DEFINE r t_osStringResult
   DEFINE base FrontCallLib.t_result

   IF NOT FrontCallLib.isFrontEnd(FE_ALL) THEN
      LET base = FrontCallLib.notSupported("standard.feInfo", FE_ALL)
      LET r.success = base.success
      LET r.message = base.message
      RETURN r
   END IF

   TRY
      CALL ui.Interface.frontCall(
         "standard", "feInfo",
         [propertyName], [r.value])
      LET r.success = TRUE
      LET r.message = SFMT("%1 = %2", propertyName,
         IIF(r.value IS NULL, "(not set)", r.value))
   CATCH
      LET base = FrontCallLib.caught("standard.feInfo")
      LET r.success = base.success
      LET r.message = base.message
      LET r.value = NULL
   END TRY
   RETURN r

END FUNCTION #feInfo

#
# Read a front-end environment variable. GDC only — docs say the
# browser sandbox and mobile runtimes do not expose host env vars.
#
PUBLIC FUNCTION getEnv(varName STRING) RETURNS t_osStringResult
   DEFINE r t_osStringResult
   DEFINE base FrontCallLib.t_result

   IF NOT FrontCallLib.isFrontEnd(FE_GDC) THEN
      LET base = FrontCallLib.notSupported("standard.getEnv", FE_GDC)
      LET r.success = base.success
      LET r.message = base.message
      RETURN r
   END IF

   TRY
      CALL ui.Interface.frontCall(
         "standard", "getEnv",
         [varName], [r.value])
      LET r.success = TRUE
      LET r.message = SFMT("%1 = %2", varName,
         IIF(r.value IS NULL, "(not set)", r.value))
   CATCH
      LET base = FrontCallLib.caught("standard.getEnv")
      LET r.success = base.success
      LET r.message = base.message
      LET r.value = NULL
   END TRY
   RETURN r

END FUNCTION #getEnv

#
# Show the front-end's directory picker and return the selected path.
#
PUBLIC FUNCTION openDir(startPath STRING, caption STRING) RETURNS t_osStringResult
   DEFINE r t_osStringResult
   DEFINE base FrontCallLib.t_result

   IF NOT FrontCallLib.isFrontEnd(FE_ALL) THEN
      LET base = FrontCallLib.notSupported("standard.openDir", FE_ALL)
      LET r.success = base.success
      LET r.message = base.message
      RETURN r
   END IF

   TRY
      CALL ui.Interface.frontCall(
         "standard", "openDir",
         [startPath, caption], [r.value])
      LET r.success = TRUE
      IF r.value IS NULL OR r.value.getLength() = 0 THEN
         LET r.message = "No directory selected"
      ELSE
         LET r.message = SFMT("Selected directory: %1", r.value)
      END IF
   CATCH
      LET base = FrontCallLib.caught("standard.openDir")
      LET r.success = base.success
      LET r.message = base.message
      LET r.value = NULL
   END TRY
   RETURN r

END FUNCTION #openDir

#
# Show the front-end's single-file picker and return the selected path.
#
PUBLIC FUNCTION openFile(
   startPath STRING, fileLabel STRING,
   wildcards STRING, caption STRING
) RETURNS t_osStringResult
   DEFINE r t_osStringResult
   DEFINE base FrontCallLib.t_result

   IF NOT FrontCallLib.isFrontEnd(FE_ALL) THEN
      LET base = FrontCallLib.notSupported("standard.openFile", FE_ALL)
      LET r.success = base.success
      LET r.message = base.message
      RETURN r
   END IF

   TRY
      CALL ui.Interface.frontCall(
         "standard", "openFile",
         [startPath, fileLabel, wildcards, caption],
         [r.value])
      LET r.success = TRUE
      IF r.value IS NULL OR r.value.getLength() = 0 THEN
         LET r.message = "No file selected"
      ELSE
         LET r.message = SFMT("Selected file: %1", r.value)
      END IF
   CATCH
      LET base = FrontCallLib.caught("standard.openFile")
      LET r.success = base.success
      LET r.message = base.message
      LET r.value = NULL
   END TRY
   RETURN r

END FUNCTION #openFile

#
# Show the front-end's multi-file picker. `.files` is the raw response
# (typically a JSON array of paths) — callers parse it with util.JSON.
#
PUBLIC FUNCTION openFiles(
   startPath STRING, fileLabel STRING,
   wildcards STRING, caption STRING
) RETURNS t_osFilesResult
   DEFINE r t_osFilesResult
   DEFINE base FrontCallLib.t_result

   IF NOT FrontCallLib.isFrontEnd(FE_ALL) THEN
      LET base = FrontCallLib.notSupported("standard.openFiles", FE_ALL)
      LET r.success = base.success
      LET r.message = base.message
      RETURN r
   END IF

   TRY
      CALL ui.Interface.frontCall(
         "standard", "openFiles",
         [startPath, fileLabel, wildcards, caption],
         [r.files])
      LET r.success = TRUE
      IF r.files IS NULL OR r.files.getLength() = 0 OR r.files = "[]" THEN
         LET r.message = "No files selected"
      ELSE
         LET r.message = "Files selected"
      END IF
   CATCH
      LET base = FrontCallLib.caught("standard.openFiles")
      LET r.success = base.success
      LET r.message = base.message
      LET r.files = NULL
   END TRY
   RETURN r

END FUNCTION #openFiles

#
# Show the front-end's save-file dialog.
#
PUBLIC FUNCTION saveFile(
   startPath STRING, fileLabel STRING,
   wildcards STRING, caption STRING
) RETURNS t_osStringResult
   DEFINE r t_osStringResult
   DEFINE base FrontCallLib.t_result

   IF NOT FrontCallLib.isFrontEnd(FE_ALL) THEN
      LET base = FrontCallLib.notSupported("standard.saveFile", FE_ALL)
      LET r.success = base.success
      LET r.message = base.message
      RETURN r
   END IF

   TRY
      CALL ui.Interface.frontCall(
         "standard", "saveFile",
         [startPath, fileLabel, wildcards, caption],
         [r.value])
      LET r.success = TRUE
      IF r.value IS NULL OR r.value.getLength() = 0 THEN
         LET r.message = "No save path selected"
      ELSE
         LET r.message = SFMT("Save path: %1", r.value)
      END IF
   CATCH
      LET base = FrontCallLib.caught("standard.saveFile")
      LET r.success = base.success
      LET r.message = base.message
      LET r.value = NULL
   END TRY
   RETURN r

END FUNCTION #saveFile

#
# Play an audio file on the front-end. `wait` blocks until playback ends.
#
PUBLIC FUNCTION playSound(resource STRING, wait BOOLEAN) RETURNS FrontCallLib.t_result
   DEFINE r FrontCallLib.t_result

   IF NOT FrontCallLib.isFrontEnd(FE_ALL) THEN
      RETURN FrontCallLib.notSupported("standard.playSound", FE_ALL)
   END IF

   TRY
      CALL ui.Interface.frontCall(
         "standard", "playSound",
         [resource, wait], [])
      LET r.success = TRUE
      LET r.message = SFMT("Playing: %1", resource)
   CATCH
      LET r = FrontCallLib.caught("standard.playSound")
   END TRY
   RETURN r

END FUNCTION #playSound

#
# Run a command on the front-end host (GDC only).
#
PUBLIC FUNCTION execute(cmd STRING, wait BOOLEAN) RETURNS FrontCallLib.t_result
   DEFINE r FrontCallLib.t_result
   DEFINE ok BOOLEAN

   IF NOT FrontCallLib.isFrontEnd(FE_GDC) THEN
      RETURN FrontCallLib.notSupported("standard.execute", FE_GDC)
   END IF

   TRY
      CALL ui.Interface.frontCall(
         "standard", "execute",
         [cmd, wait], [ok])
      LET r.success = ok
      IF ok THEN
         LET r.message = SFMT("Executed: %1", cmd)
      ELSE
         LET r.message = SFMT("execute returned FALSE for: %1", cmd)
      END IF
   CATCH
      LET r = FrontCallLib.caught("standard.execute")
   END TRY
   RETURN r

END FUNCTION #execute

#
# Open a file with the OS-associated program (GDC only).
#
PUBLIC FUNCTION shellExec(document STRING) RETURNS FrontCallLib.t_result
   DEFINE r FrontCallLib.t_result
   DEFINE ok BOOLEAN

   IF NOT FrontCallLib.isFrontEnd(FE_GDC) THEN
      RETURN FrontCallLib.notSupported("standard.shellExec", FE_GDC)
   END IF

   TRY
      CALL ui.Interface.frontCall(
         "standard", "shellExec",
         [document], [ok])
      LET r.success = ok
      IF ok THEN
         LET r.message = SFMT("Opened: %1", document)
      ELSE
         LET r.message = SFMT("shellExec returned FALSE for: %1", document)
      END IF
   CATCH
      LET r = FrontCallLib.caught("standard.shellExec")
   END TRY
   RETURN r

END FUNCTION #shellExec

#
# Print a screenshot of the current window (GDC only).
#
PUBLIC FUNCTION hardCopy(pageSize INTEGER) RETURNS FrontCallLib.t_result
   DEFINE r FrontCallLib.t_result
   DEFINE ok BOOLEAN

   IF NOT FrontCallLib.isFrontEnd(FE_GDC) THEN
      RETURN FrontCallLib.notSupported("standard.hardCopy", FE_GDC)
   END IF

   TRY
      CALL ui.Interface.frontCall(
         "standard", "hardCopy",
         [pageSize], [ok])
      LET r.success = ok
      IF ok THEN
         LET r.message = "Hardcopy generated"
      ELSE
         LET r.message = "hardCopy returned FALSE"
      END IF
   CATCH
      LET r = FrontCallLib.caught("standard.hardCopy")
   END TRY
   RETURN r

END FUNCTION #hardCopy
