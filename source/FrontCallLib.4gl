#
# FrontCallLib — shared foundations for every *Lib module that wraps
# ui.Interface.frontCall. Provides:
#
#   - t_result           generic success/failure record
#   - FE_* constants     canonical front-end names
#   - getFrontEnd()      cached ui.Interface.getFrontEndName()
#   - isFrontEnd(csv)    "is the current FE in this comma-separated list"
#   - notSupported()     build a t_result for an unsupported FE
#   - caught()           build a t_result from a TRY/CATCH block
#

PACKAGE com.fourjs.fclib

PUBLIC CONSTANT FE_GDC     = "GDC"
PUBLIC CONSTANT FE_GMA     = "GMA"
PUBLIC CONSTANT FE_GMI     = "GMI"
PUBLIC CONSTANT FE_GBC     = "GBC"
PUBLIC CONSTANT FE_CONSOLE = "Console"

PUBLIC TYPE t_result RECORD
   success BOOLEAN,
   message STRING
END RECORD

PRIVATE DEFINE m_frontEnd   STRING
PRIVATE DEFINE m_initialized BOOLEAN

#
# Returns the current front-end name, cached on first call.
#
PUBLIC FUNCTION getFrontEnd() RETURNS STRING

   IF NOT m_initialized THEN
      LET m_frontEnd = ui.Interface.getFrontEndName()
      LET m_initialized = TRUE
   END IF
   RETURN m_frontEnd

END FUNCTION #getFrontEnd

#
# Returns TRUE if the current front-end is in the comma-separated
# allowed list. Example: isFrontEnd("GDC,GMA,GMI,GBC").
#
PUBLIC FUNCTION isFrontEnd(allowedCsv STRING) RETURNS BOOLEAN
   DEFINE tok base.StringTokenizer
   DEFINE fe STRING

   LET fe = getFrontEnd()
   LET tok = base.StringTokenizer.create(allowedCsv, ",")
   WHILE tok.hasMoreTokens()
      IF tok.nextToken() = fe THEN
         RETURN TRUE
      END IF
   END WHILE
   RETURN FALSE

END FUNCTION #isFrontEnd

#
# Build a standard "frontcall not supported on this front-end" result.
#
PUBLIC FUNCTION notSupported(
   frontcallName STRING,
   allowedCsv STRING
) RETURNS t_result
   DEFINE r t_result

   LET r.success = FALSE
   LET r.message = SFMT(
      "Frontcall '%1' is not supported on front-end '%2' (supported: %3)",
      frontcallName, getFrontEnd(), allowedCsv)
   RETURN r

END FUNCTION #notSupported

#
# Build a standard "exception caught" result from inside a CATCH block.
# Callers pass the frontcall name and the caller should CALL caught()
# from inside CATCH so STATUS / err_get() are still populated.
#
PUBLIC FUNCTION caught(frontcallName STRING) RETURNS t_result
   DEFINE r t_result

   LET r.success = FALSE
   LET r.message = SFMT("Frontcall '%1' raised error %2: %3",
      frontcallName, status, err_get(status))
   RETURN r

END FUNCTION #caught
