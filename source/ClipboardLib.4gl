#
# ClipboardLib — reusable wrappers around the "standard" clipboard
# front calls. Every function checks the current front-end is
# supported, wraps the front call in TRY/CATCH, and returns a typed
# result record.
#
# Result types:
#   - FrontCallLib.t_result    success/failure only (add, clear, paste, set)
#   - t_cbGetResult            success/failure + text  (get)
#
# Supported front-ends: GDC, GMA, GMI, GBC
# (GBC additionally needs an https scheme or localhost — that is a
# runtime environment constraint, not a front-end mismatch.)
#

PACKAGE com.fourjs.fclib

IMPORT FGL com.fourjs.fclib.FrontCallLib

PRIVATE CONSTANT ALLOWED_FE = "GDC,GMA,GMI,GBC"

PUBLIC TYPE t_cbGetResult RECORD
   success BOOLEAN,
   message STRING,
   text STRING
END RECORD

PUBLIC FUNCTION add(text STRING) RETURNS FrontCallLib.t_result
   DEFINE r FrontCallLib.t_result
   DEFINE ok BOOLEAN

   IF NOT FrontCallLib.isFrontEnd(ALLOWED_FE) THEN
      RETURN FrontCallLib.notSupported("cbAdd", ALLOWED_FE)
   END IF

   TRY
      CALL ui.Interface.frontCall(
         "standard", "cbAdd",
         [text], [ok])
      LET r.success = ok
      IF ok THEN
         LET r.message = "Text appended to clipboard"
      ELSE
         LET r.message = "Front-end reported failure appending to clipboard"
      END IF
   CATCH
      LET r = FrontCallLib.caught("cbAdd")
   END TRY
   RETURN r

END FUNCTION #add

PUBLIC FUNCTION clear() RETURNS FrontCallLib.t_result
   DEFINE r FrontCallLib.t_result
   DEFINE ok BOOLEAN

   IF NOT FrontCallLib.isFrontEnd(ALLOWED_FE) THEN
      RETURN FrontCallLib.notSupported("cbClear", ALLOWED_FE)
   END IF

   TRY
      CALL ui.Interface.frontCall(
         "standard", "cbClear",
         [], [ok])
      LET r.success = ok
      IF ok THEN
         LET r.message = "Clipboard cleared"
      ELSE
         LET r.message = "Front-end reported failure clearing clipboard"
      END IF
   CATCH
      LET r = FrontCallLib.caught("cbClear")
   END TRY
   RETURN r

END FUNCTION #clear

PUBLIC FUNCTION get() RETURNS t_cbGetResult
   DEFINE r t_cbGetResult
   DEFINE base FrontCallLib.t_result

   IF NOT FrontCallLib.isFrontEnd(ALLOWED_FE) THEN
      LET base = FrontCallLib.notSupported("cbGet", ALLOWED_FE)
      LET r.success = base.success
      LET r.message = base.message
      RETURN r
   END IF

   TRY
      CALL ui.Interface.frontCall(
         "standard", "cbGet",
         [], [r.text])
      LET r.success = TRUE
      LET r.message = "Clipboard content retrieved"
   CATCH
      LET base = FrontCallLib.caught("cbGet")
      LET r.success = base.success
      LET r.message = base.message
      LET r.text = NULL
   END TRY
   RETURN r

END FUNCTION #get

PUBLIC FUNCTION paste() RETURNS FrontCallLib.t_result
   DEFINE r FrontCallLib.t_result
   DEFINE ok BOOLEAN

   IF NOT FrontCallLib.isFrontEnd(ALLOWED_FE) THEN
      RETURN FrontCallLib.notSupported("cbPaste", ALLOWED_FE)
   END IF

   TRY
      CALL ui.Interface.frontCall(
         "standard", "cbPaste",
         [], [ok])
      LET r.success = ok
      IF ok THEN
         LET r.message = "Clipboard pasted into current field"
      ELSE
         LET r.message = "Front-end reported failure pasting clipboard"
      END IF
   CATCH
      LET r = FrontCallLib.caught("cbPaste")
   END TRY
   RETURN r

END FUNCTION #paste

PUBLIC FUNCTION set(text STRING) RETURNS FrontCallLib.t_result
   DEFINE r FrontCallLib.t_result
   DEFINE ok BOOLEAN

   IF NOT FrontCallLib.isFrontEnd(ALLOWED_FE) THEN
      RETURN FrontCallLib.notSupported("cbSet", ALLOWED_FE)
   END IF

   TRY
      CALL ui.Interface.frontCall(
         "standard", "cbSet",
         [text], [ok])
      LET r.success = ok
      IF ok THEN
         LET r.message = "Clipboard content set"
      ELSE
         LET r.message = "Front-end reported failure setting clipboard"
      END IF
   CATCH
      LET r = FrontCallLib.caught("cbSet")
   END TRY
   RETURN r

END FUNCTION #set
