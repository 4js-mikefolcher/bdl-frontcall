#
# BrowserLib — reusable wrappers for the "browser" front-call module.
#
# Supported front-ends: GBC only.
#
# Result types:
#   - FrontCallLib.t_result  setAppState (no data returned)
#   - t_bwGetResult          getAppState (success/message + anchor)
#

PACKAGE com.fourjs.fclib

IMPORT FGL com.fourjs.fclib.FrontCallLib

PRIVATE CONSTANT ALLOWED_FE = "GBC"

PUBLIC TYPE t_bwGetResult RECORD
   success BOOLEAN,
   message STRING,
   anchor STRING
END RECORD

#
# Set the URL anchor (#fragment) displayed in the browser address bar.
#
PUBLIC FUNCTION setAppState(anchor STRING) RETURNS FrontCallLib.t_result
   DEFINE r FrontCallLib.t_result

   IF NOT FrontCallLib.isFrontEnd(ALLOWED_FE) THEN
      RETURN FrontCallLib.notSupported("browser.setApplicationState", ALLOWED_FE)
   END IF

   TRY
      CALL ui.Interface.frontCall(
         "browser", "setApplicationState",
         [anchor], [])
      LET r.success = TRUE
      LET r.message = SFMT("URL anchor set to #%1", anchor)
   CATCH
      LET r = FrontCallLib.caught("browser.setApplicationState")
   END TRY
   RETURN r

END FUNCTION #setAppState

#
# Return the current URL anchor (#fragment) displayed in the browser.
#
PUBLIC FUNCTION getAppState() RETURNS t_bwGetResult
   DEFINE r t_bwGetResult
   DEFINE base FrontCallLib.t_result

   IF NOT FrontCallLib.isFrontEnd(ALLOWED_FE) THEN
      LET base = FrontCallLib.notSupported("browser.getApplicationState", ALLOWED_FE)
      LET r.success = base.success
      LET r.message = base.message
      RETURN r
   END IF

   TRY
      CALL ui.Interface.frontCall(
         "browser", "getApplicationState",
         [], [r.anchor])
      LET r.success = TRUE
      IF r.anchor IS NULL THEN
         LET r.message = "No URL anchor is currently set"
      ELSE
         LET r.message = SFMT("Current URL anchor: #%1", r.anchor)
      END IF
   CATCH
      LET base = FrontCallLib.caught("browser.getApplicationState")
      LET r.success = base.success
      LET r.message = base.message
      LET r.anchor = NULL
   END TRY
   RETURN r

END FUNCTION #getAppState
