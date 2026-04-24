#
# LocalStorageLib — reusable wrappers for the "localStorage" front-call
# module (HTML5 localStorage on the browser front-end).
#
# Supported front-ends: GBC only.
#
# Result types:
#   - FrontCallLib.t_result  setItem, removeItem, clear
#   - t_lsGetResult          getItem (success/message + value)
#   - t_lsKeysResult         keys   (success/message + keys STRING)
#

PACKAGE com.fourjs.fclib

IMPORT FGL com.fourjs.fclib.FrontCallLib

PRIVATE CONSTANT ALLOWED_FE = "GBC"

PUBLIC TYPE t_lsGetResult RECORD
   success BOOLEAN,
   message STRING,
   value STRING
END RECORD

PUBLIC TYPE t_lsKeysResult RECORD
   success BOOLEAN,
   message STRING,
   keys STRING
END RECORD

PUBLIC FUNCTION setItem(key STRING, value STRING) RETURNS FrontCallLib.t_result
   DEFINE r FrontCallLib.t_result

   IF NOT FrontCallLib.isFrontEnd(ALLOWED_FE) THEN
      RETURN FrontCallLib.notSupported("localStorage.setItem", ALLOWED_FE)
   END IF

   TRY
      CALL ui.Interface.frontCall(
         "localStorage", "setItem",
         [key, value], [])
      LET r.success = TRUE
      LET r.message = SFMT("Stored '%1' = '%2'", key, value)
   CATCH
      LET r = FrontCallLib.caught("localStorage.setItem")
   END TRY
   RETURN r

END FUNCTION #setItem

PUBLIC FUNCTION getItem(key STRING) RETURNS t_lsGetResult
   DEFINE r t_lsGetResult
   DEFINE base FrontCallLib.t_result

   IF NOT FrontCallLib.isFrontEnd(ALLOWED_FE) THEN
      LET base = FrontCallLib.notSupported("localStorage.getItem", ALLOWED_FE)
      LET r.success = base.success
      LET r.message = base.message
      RETURN r
   END IF

   TRY
      CALL ui.Interface.frontCall(
         "localStorage", "getItem",
         [key], [r.value])
      LET r.success = TRUE
      IF r.value IS NULL THEN
         LET r.message = SFMT("No value stored for key '%1'", key)
      ELSE
         LET r.message = SFMT("'%1' = '%2'", key, r.value)
      END IF
   CATCH
      LET base = FrontCallLib.caught("localStorage.getItem")
      LET r.success = base.success
      LET r.message = base.message
      LET r.value = NULL
   END TRY
   RETURN r

END FUNCTION #getItem

PUBLIC FUNCTION keys() RETURNS t_lsKeysResult
   DEFINE r t_lsKeysResult
   DEFINE base FrontCallLib.t_result

   IF NOT FrontCallLib.isFrontEnd(ALLOWED_FE) THEN
      LET base = FrontCallLib.notSupported("localStorage.keys", ALLOWED_FE)
      LET r.success = base.success
      LET r.message = base.message
      RETURN r
   END IF

   TRY
      CALL ui.Interface.frontCall(
         "localStorage", "keys",
         [], [r.keys])
      LET r.success = TRUE
      IF r.keys IS NULL OR r.keys.getLength() = 0 THEN
         LET r.message = "localStorage contains no keys"
      ELSE
         LET r.message = "localStorage keys retrieved"
      END IF
   CATCH
      LET base = FrontCallLib.caught("localStorage.keys")
      LET r.success = base.success
      LET r.message = base.message
      LET r.keys = NULL
   END TRY
   RETURN r

END FUNCTION #keys

PUBLIC FUNCTION removeItem(key STRING) RETURNS FrontCallLib.t_result
   DEFINE r FrontCallLib.t_result

   IF NOT FrontCallLib.isFrontEnd(ALLOWED_FE) THEN
      RETURN FrontCallLib.notSupported("localStorage.removeItem", ALLOWED_FE)
   END IF

   TRY
      CALL ui.Interface.frontCall(
         "localStorage", "removeItem",
         [key], [])
      LET r.success = TRUE
      LET r.message = SFMT("Key '%1' removed from localStorage", key)
   CATCH
      LET r = FrontCallLib.caught("localStorage.removeItem")
   END TRY
   RETURN r

END FUNCTION #removeItem

PUBLIC FUNCTION clear() RETURNS FrontCallLib.t_result
   DEFINE r FrontCallLib.t_result

   IF NOT FrontCallLib.isFrontEnd(ALLOWED_FE) THEN
      RETURN FrontCallLib.notSupported("localStorage.clear", ALLOWED_FE)
   END IF

   TRY
      CALL ui.Interface.frontCall(
         "localStorage", "clear",
         [], [])
      LET r.success = TRUE
      LET r.message = "All localStorage data cleared"
   CATCH
      LET r = FrontCallLib.caught("localStorage.clear")
   END TRY
   RETURN r

END FUNCTION #clear
