#
# MiscLib — reusable wrappers for "standard" miscellaneous frontcalls
# that don't fit the OS / Notification / Clipboard groupings.
#
# Per-function supported front-ends:
#   composeMail                           all front-ends
#   connectivity, isForeground            all front-ends
#   getGeolocation                        GMA, GMI, GBC (no GDC)
#   clearFileCache, storeSize, restoreSize  GDC only
#
# Result types:
#   - FrontCallLib.t_result     clearFileCache, storeSize, restoreSize, isForeground, composeMail
#   - t_msStringResult          connectivity  (success/message + network)
#   - t_msGeoResult             getGeolocation  (success/message + latitude + longitude)
#   - t_msBoolResult            isForeground  (success/message + foreground)
#

PACKAGE com.fourjs.fclib

IMPORT FGL com.fourjs.fclib.FrontCallLib

PRIVATE CONSTANT FE_ALL    = "GDC,GMA,GMI,GBC"
PRIVATE CONSTANT FE_GDC    = "GDC"
PRIVATE CONSTANT FE_NO_GDC = "GMA,GMI,GBC"

PUBLIC TYPE t_msStringResult RECORD
   success BOOLEAN,
   message STRING,
   value STRING
END RECORD

PUBLIC TYPE t_msBoolResult RECORD
   success BOOLEAN,
   message STRING,
   value BOOLEAN
END RECORD

PUBLIC TYPE t_msGeoResult RECORD
   success BOOLEAN,
   message STRING,
   latitude FLOAT,
   longitude FLOAT
END RECORD

#
# Open the user's default mail client with pre-filled fields.
# Returns the raw front-end result ("ok" on success) inside .value
# AND sets r.success based on whether it was "ok".
#
PUBLIC FUNCTION composeMail(
   mailTo STRING, subject STRING, content STRING,
   cc STRING, bcc STRING
) RETURNS t_msStringResult
   DEFINE r t_msStringResult
   DEFINE base FrontCallLib.t_result

   IF NOT FrontCallLib.isFrontEnd(FE_ALL) THEN
      LET base = FrontCallLib.notSupported("standard.composeMail", FE_ALL)
      LET r.success = base.success
      LET r.message = base.message
      RETURN r
   END IF

   TRY
      CALL ui.Interface.frontCall(
         "standard", "composeMail",
         [mailTo, subject, content, cc, bcc],
         [r.value])
      IF r.value = "ok" THEN
         LET r.success = TRUE
         LET r.message = "Mail application opened"
      ELSE
         LET r.success = FALSE
         LET r.message = SFMT("composeMail returned: %1", r.value)
      END IF
   CATCH
      LET base = FrontCallLib.caught("standard.composeMail")
      LET r.success = base.success
      LET r.message = base.message
      LET r.value = NULL
   END TRY
   RETURN r

END FUNCTION #composeMail

#
# Return a string describing network connectivity (NONE, WIFI, MobileNetwork, Undefined network).
#
PUBLIC FUNCTION connectivity() RETURNS t_msStringResult
   DEFINE r t_msStringResult
   DEFINE base FrontCallLib.t_result

   IF NOT FrontCallLib.isFrontEnd(FE_ALL) THEN
      LET base = FrontCallLib.notSupported("standard.connectivity", FE_ALL)
      LET r.success = base.success
      LET r.message = base.message
      RETURN r
   END IF

   TRY
      CALL ui.Interface.frontCall(
         "standard", "connectivity",
         [], [r.value])
      LET r.success = TRUE
      LET r.message = SFMT("Network connectivity: %1",
         IIF(r.value IS NULL, "(unknown)", r.value))
   CATCH
      LET base = FrontCallLib.caught("standard.connectivity")
      LET r.success = base.success
      LET r.message = base.message
      LET r.value = NULL
   END TRY
   RETURN r

END FUNCTION #connectivity

#
# Return TRUE if the app is in the foreground on the front-end.
#
PUBLIC FUNCTION isForeground() RETURNS t_msBoolResult
   DEFINE r t_msBoolResult
   DEFINE base FrontCallLib.t_result

   IF NOT FrontCallLib.isFrontEnd(FE_ALL) THEN
      LET base = FrontCallLib.notSupported("standard.isForeground", FE_ALL)
      LET r.success = base.success
      LET r.message = base.message
      RETURN r
   END IF

   TRY
      CALL ui.Interface.frontCall(
         "standard", "isForeground",
         [], [r.value])
      LET r.success = TRUE
      LET r.message = SFMT("Application is in foreground: %1",
         IIF(r.value, "TRUE", "FALSE"))
   CATCH
      LET base = FrontCallLib.caught("standard.isForeground")
      LET r.success = base.success
      LET r.message = base.message
      LET r.value = FALSE
   END TRY
   RETURN r

END FUNCTION #isForeground

#
# Return the device latitude/longitude. GBC + mobile front-ends only.
#
PUBLIC FUNCTION getGeolocation() RETURNS t_msGeoResult
   DEFINE r t_msGeoResult
   DEFINE base FrontCallLib.t_result
   DEFINE geoStatus STRING

   IF NOT FrontCallLib.isFrontEnd(FE_NO_GDC) THEN
      LET base = FrontCallLib.notSupported("standard.getGeolocation", FE_NO_GDC)
      LET r.success = base.success
      LET r.message = base.message
      RETURN r
   END IF

   TRY
      CALL ui.Interface.frontCall(
         "standard", "getGeolocation",
         [], [geoStatus, r.latitude, r.longitude])
      IF geoStatus = "ok" THEN
         LET r.success = TRUE
         LET r.message = SFMT("Latitude: %1, Longitude: %2", r.latitude, r.longitude)
      ELSE
         LET r.success = FALSE
         LET r.message = SFMT("getGeolocation status: %1", geoStatus)
      END IF
   CATCH
      LET base = FrontCallLib.caught("standard.getGeolocation")
      LET r.success = base.success
      LET r.message = base.message
   END TRY
   RETURN r

END FUNCTION #getGeolocation

#
# Clear the local file cache (GDC only).
#
PUBLIC FUNCTION clearFileCache() RETURNS FrontCallLib.t_result
   DEFINE r FrontCallLib.t_result
   DEFINE ok BOOLEAN

   IF NOT FrontCallLib.isFrontEnd(FE_GDC) THEN
      RETURN FrontCallLib.notSupported("standard.clearFileCache", FE_GDC)
   END IF

   TRY
      CALL ui.Interface.frontCall(
         "standard", "clearFileCache",
         [], [ok])
      LET r.success = ok
      IF ok THEN
         LET r.message = "File cache cleared"
      ELSE
         LET r.message = "clearFileCache returned FALSE"
      END IF
   CATCH
      LET r = FrontCallLib.caught("standard.clearFileCache")
   END TRY
   RETURN r

END FUNCTION #clearFileCache

#
# Ask GDC to store the current window-container size (GDC only).
#
PUBLIC FUNCTION storeSize() RETURNS FrontCallLib.t_result
   DEFINE r FrontCallLib.t_result
   DEFINE ok BOOLEAN

   IF NOT FrontCallLib.isFrontEnd(FE_GDC) THEN
      RETURN FrontCallLib.notSupported("standard.storeSize", FE_GDC)
   END IF

   TRY
      CALL ui.Interface.frontCall(
         "standard", "storeSize",
         [], [ok])
      LET r.success = ok
      IF ok THEN
         LET r.message = "Window size stored"
      ELSE
         LET r.message = "storeSize returned FALSE"
      END IF
   CATCH
      LET r = FrontCallLib.caught("standard.storeSize")
   END TRY
   RETURN r

END FUNCTION #storeSize

#
# Ask GDC to restore the stored window-container size (GDC only).
#
PUBLIC FUNCTION restoreSize(delayMs INTEGER) RETURNS FrontCallLib.t_result
   DEFINE r FrontCallLib.t_result
   DEFINE ok BOOLEAN

   IF NOT FrontCallLib.isFrontEnd(FE_GDC) THEN
      RETURN FrontCallLib.notSupported("standard.restoreSize", FE_GDC)
   END IF

   TRY
      CALL ui.Interface.frontCall(
         "standard", "restoreSize",
         [delayMs], [ok])
      LET r.success = ok
      IF ok THEN
         LET r.message = SFMT("Window size restored (delay=%1 ms)", delayMs)
      ELSE
         LET r.message = "restoreSize returned FALSE (requires prior storeSize)"
      END IF
   CATCH
      LET r = FrontCallLib.caught("standard.restoreSize")
   END TRY
   RETURN r

END FUNCTION #restoreSize
