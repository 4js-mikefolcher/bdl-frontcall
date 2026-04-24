#
# NotificationLib — reusable wrappers for "standard" notification
# frontcalls.
#
# Supported front-ends: GDC, GMA, GMI, GBC. Actual behaviour is
# front-end specific — for example standard.createNotification may
# return NULL if the host cannot display notifications. The FE-allow
# list therefore stays permissive; runtime issues are surfaced via
# r.success / r.message.
#
# Result types:
#   - FrontCallLib.t_result     clearNotifications
#   - t_nfCreateResult          createNotification   (adds notifId)
#   - t_nfInteraction (element type)
#   - t_nfInteractionsResult    getLastNotificationInteractions
#

PACKAGE com.fourjs.fclib

IMPORT FGL com.fourjs.fclib.FrontCallLib

PRIVATE CONSTANT FE_ALL = "GDC,GMA,GMI,GBC"

PUBLIC TYPE t_nfOptions RECORD
   id INTEGER,
   title STRING,
   content STRING,
   icon STRING
END RECORD

PUBLIC TYPE t_nfCreateResult RECORD
   success BOOLEAN,
   message STRING,
   notifId INTEGER
END RECORD

PUBLIC TYPE t_nfInteraction RECORD
   id STRING,
   type STRING
END RECORD

PUBLIC TYPE t_nfInteractionsResult RECORD
   success BOOLEAN,
   message STRING,
   interactions DYNAMIC ARRAY OF t_nfInteraction
END RECORD

#
# Create a local notification. Returns the assigned notification id.
# `notifId` will be NULL if the front-end cannot display notifications.
#
PUBLIC FUNCTION createNotification(options t_nfOptions) RETURNS t_nfCreateResult
   DEFINE r t_nfCreateResult
   DEFINE base FrontCallLib.t_result

   IF NOT FrontCallLib.isFrontEnd(FE_ALL) THEN
      LET base = FrontCallLib.notSupported("standard.createNotification", FE_ALL)
      LET r.success = base.success
      LET r.message = base.message
      RETURN r
   END IF

   TRY
      CALL ui.Interface.frontCall(
         "standard", "createNotification",
         [options], [r.notifId])
      IF r.notifId IS NOT NULL AND r.notifId > 0 THEN
         LET r.success = TRUE
         LET r.message = SFMT("Notification created with id %1", r.notifId)
      ELSE
         LET r.success = FALSE
         LET r.message = "Front-end cannot display notifications (notifId was NULL)"
      END IF
   CATCH
      LET base = FrontCallLib.caught("standard.createNotification")
      LET r.success = base.success
      LET r.message = base.message
   END TRY
   RETURN r

END FUNCTION #createNotification

#
# Clear displayed notifications. Pass NULL to clear all notifications.
#
PUBLIC FUNCTION clearNotifications(options STRING) RETURNS FrontCallLib.t_result
   DEFINE r FrontCallLib.t_result
   DEFINE ret STRING

   IF NOT FrontCallLib.isFrontEnd(FE_ALL) THEN
      RETURN FrontCallLib.notSupported("standard.clearNotifications", FE_ALL)
   END IF

   TRY
      CALL ui.Interface.frontCall(
         "standard", "clearNotifications",
         [options], [ret])
      LET r.success = TRUE
      LET r.message = SFMT("clearNotifications returned: %1",
         IIF(ret IS NULL, "(null)", ret))
   CATCH
      LET r = FrontCallLib.caught("standard.clearNotifications")
   END TRY
   RETURN r

END FUNCTION #clearNotifications

#
# Return the list of user interactions since the last call.
#
PUBLIC FUNCTION getLastNotificationInteractions() RETURNS t_nfInteractionsResult
   DEFINE r t_nfInteractionsResult
   DEFINE base FrontCallLib.t_result

   IF NOT FrontCallLib.isFrontEnd(FE_ALL) THEN
      LET base = FrontCallLib.notSupported(
         "standard.getLastNotificationInteractions", FE_ALL)
      LET r.success = base.success
      LET r.message = base.message
      RETURN r
   END IF

   TRY
      CALL ui.Interface.frontCall(
         "standard", "getLastNotificationInteractions",
         [], [r.interactions])
      LET r.success = TRUE
      LET r.message = SFMT("%1 interaction(s) retrieved", r.interactions.getLength())
   CATCH
      LET base = FrontCallLib.caught("standard.getLastNotificationInteractions")
      LET r.success = base.success
      LET r.message = base.message
   END TRY
   RETURN r

END FUNCTION #getLastNotificationInteractions
