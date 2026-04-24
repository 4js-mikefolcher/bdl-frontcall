#
# WorkflowLib — composed workflows that chain multiple front calls
# plus server-side built-ins into a single user-facing operation.
#
# Supported front-ends: GDC only. The workflows in this module depend
# on standard.getEnv, standard.shellExec and fgl_putfile with an
# explicit client-side target path — none of which work in GBC.
#
# Public API:
#   - t_wfFileResult       { success, message, clientPath }
#   - getClientHome()      return client user's home directory
#   - putAndOpen()         copy server file to client + launch associated app
#

PACKAGE com.fourjs.fclib

IMPORT os
IMPORT FGL com.fourjs.fclib.FrontCallLib
IMPORT FGL com.fourjs.fclib.OSLib

PRIVATE CONSTANT FE_GDC = "GDC"

PUBLIC TYPE t_wfFileResult RECORD
   success BOOLEAN,
   message STRING,
   clientPath STRING
END RECORD

#
# Return the absolute path to the client-side user's home directory.
#
# Uses standard.feInfo("osType") to pick the right env var, then
# standard.getEnv to read it:
#   - WINDOWS  → USERPROFILE  (e.g. C:\Users\alice)
#   - anything → HOME         (e.g. /Users/alice, /home/alice)
#
# GDC only — getEnv is not available on GBC or mobile front-ends.
#
PUBLIC FUNCTION getClientHome() RETURNS t_wfFileResult
   DEFINE r         t_wfFileResult
   DEFINE base      FrontCallLib.t_result
   DEFINE osTypeR   OSLib.t_osStringResult
   DEFINE envR      OSLib.t_osStringResult
   DEFINE envVar    STRING

   IF NOT FrontCallLib.isFrontEnd(FE_GDC) THEN
      LET base = FrontCallLib.notSupported("WorkflowLib.getClientHome", FE_GDC)
      LET r.success = base.success
      LET r.message = base.message
      RETURN r
   END IF

   LET osTypeR = OSLib.feInfo("osType")
   IF NOT osTypeR.success THEN
      LET r.success = FALSE
      LET r.message = SFMT("Could not detect client OS: %1", osTypeR.message)
      RETURN r
   END IF

   IF osTypeR.value = "WINDOWS" THEN
      LET envVar = "USERPROFILE"
   ELSE
      LET envVar = "HOME"
   END IF

   LET envR = OSLib.getEnv(envVar)
   IF NOT envR.success OR envR.value IS NULL OR envR.value.getLength() = 0 THEN
      LET r.success = FALSE
      LET r.message = SFMT("Could not read client env var %1: %2",
         envVar, envR.message)
      RETURN r
   END IF

   LET r.success = TRUE
   LET r.clientPath = envR.value
   LET r.message = SFMT("Client home (%1): %2", envVar, envR.value)
   RETURN r

END FUNCTION #getClientHome

#
# Copy a file from the server to the client's home directory (or a
# subdirectory under it) and open it with the OS-associated program.
#
# Arguments:
#   serverPath     absolute path on the fglrun (server) filesystem
#   clientSubdir   optional sub-directory under the client home; may
#                  be NULL or "" to write directly into the home dir.
#                  Example: "Downloads"
#
# Steps performed:
#   1. Validate the server file exists (os.Path.exists)
#   2. Determine client home (getClientHome — implies GDC FE check)
#   3. Compose <home>[/<subdir>]/<basename(serverPath)> on the client
#   4. Transfer with fgl_putfile — wrapped in TRY/CATCH
#   5. Open with OSLib.shellExec
#
# The returned record:
#   success     TRUE only when both steps 4 and 5 succeeded
#   message     human-readable summary or error
#   clientPath  the target path on the client (populated even on
#               partial failure, so the caller can inspect/clean up)
#
PUBLIC FUNCTION putAndOpen(
   serverPath STRING,
   clientSubdir STRING
) RETURNS t_wfFileResult
   DEFINE r          t_wfFileResult
   DEFINE homeR      t_wfFileResult
   DEFINE execR      FrontCallLib.t_result
   DEFINE osTypeR    OSLib.t_osStringResult
   DEFINE sep        STRING
   DEFINE clientDir  STRING
   DEFINE fileName   STRING
   DEFINE targetPath STRING

   IF serverPath IS NULL OR serverPath.getLength() = 0 THEN
      LET r.success = FALSE
      LET r.message = "serverPath is required"
      RETURN r
   END IF

   IF NOT os.Path.exists(serverPath) THEN
      LET r.success = FALSE
      LET r.message = SFMT("Server file not found: %1", serverPath)
      RETURN r
   END IF

   LET homeR = getClientHome()
   IF NOT homeR.success THEN
      RETURN homeR
   END IF

   LET osTypeR = OSLib.feInfo("osType")
   IF osTypeR.success AND osTypeR.value = "WINDOWS" THEN
      LET sep = "\\"
   ELSE
      LET sep = "/"
   END IF

   IF clientSubdir IS NULL OR clientSubdir.getLength() = 0 THEN
      LET clientDir = homeR.clientPath
   ELSE
      LET clientDir = homeR.clientPath, sep, clientSubdir
   END IF

   LET fileName = os.Path.baseName(serverPath)
   LET targetPath = clientDir, sep, fileName

   TRY
      CALL fgl_putfile(serverPath, targetPath)
   CATCH
      LET r.success = FALSE
      LET r.clientPath = targetPath
      LET r.message = SFMT("fgl_putfile failed: error %1 (%2)",
         status, err_get(status))
      RETURN r
   END TRY

   LET execR = OSLib.shellExec(targetPath)
   IF NOT execR.success THEN
      LET r.success = FALSE
      LET r.clientPath = targetPath
      LET r.message = SFMT("File transferred to %1 but shellExec failed: %2",
         targetPath, execR.message)
      RETURN r
   END IF

   LET r.success = TRUE
   LET r.clientPath = targetPath
   LET r.message = SFMT("Transferred and opened: %1", targetPath)
   RETURN r

END FUNCTION #putAndOpen
