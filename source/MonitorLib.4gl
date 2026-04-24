#
# MonitorLib — reusable wrappers for the "monitor" front-call module
# (GDC configuration / auto-update).
#
# Supported front-ends: GDC only.
#

PACKAGE com.fourjs.fclib

IMPORT FGL com.fourjs.fclib.FrontCallLib

PRIVATE CONSTANT ALLOWED_FE = "GDC"

#
# Start a GDC auto-update from the supplied update archive.
#
#   updatePath       path to the .zip/.upd archive previously pushed to GDC
#   warningText      optional text shown to the user before update
#   elevationPrompt  on Windows, request admin elevation when required
#
PUBLIC FUNCTION update(
   updatePath STRING,
   warningText STRING,
   elevationPrompt BOOLEAN
) RETURNS FrontCallLib.t_result
   DEFINE r FrontCallLib.t_result
   DEFINE ok BOOLEAN

   IF NOT FrontCallLib.isFrontEnd(ALLOWED_FE) THEN
      RETURN FrontCallLib.notSupported("monitor.update", ALLOWED_FE)
   END IF

   TRY
      CALL ui.Interface.frontCall(
         "monitor", "update",
         [updatePath, warningText, elevationPrompt],
         [ok])
      LET r.success = ok
      IF ok THEN
         LET r.message = SFMT("GDC update started from '%1'", updatePath)
      ELSE
         LET r.message = "GDC reported the update could not be started"
      END IF
   CATCH
      LET r = FrontCallLib.caught("monitor.update")
   END TRY
   RETURN r

END FUNCTION #update
