#
# NotificationDemo.4gl
#
# Standalone demo for standard notification frontcalls:
#   standard.createNotification           - send a system notification
#   standard.clearNotifications           - dismiss all notifications
#   standard.getLastNotificationInteractions - query last user interactions
#

MAIN
   DEFINE action       STRING
   DEFINE notifTitle   STRING
   DEFINE notifContent STRING

   OPEN WINDOW w WITH FORM "NotificationDemo"
      ATTRIBUTES(TEXT="Notification Frontcall Demo")
   CLOSE WINDOW SCREEN

   INPUT action, notifTitle, notifContent WITHOUT DEFAULTS
      FROM formonly.action, formonly.notifTitle, formonly.notifContent
      ATTRIBUTES(UNBUFFERED, accept=FALSE)

      BEFORE INPUT
         CALL setupCombo()
         CALL showHint(NULL)

      ON CHANGE action
         CALL showHint(action)

      ON ACTION execute ATTRIBUTES(TEXT="Execute", IMAGE="fa-play")
         ACCEPT INPUT

      ON ACTION CANCEL
         EXIT INPUT

      AFTER INPUT
         IF action IS NULL THEN
            ERROR "Select an action first"
            CONTINUE INPUT
         END IF
         CALL executeAction(action, notifTitle, notifContent)
         CONTINUE INPUT

   END INPUT

   CLOSE WINDOW w

END MAIN

# ---------------------------------------------------------------------------
PRIVATE FUNCTION setupCombo() RETURNS ()
   DEFINE combo ui.ComboBox
   LET combo = ui.ComboBox.forName("formonly.action")
   IF combo IS NOT NULL THEN
      CALL combo.addItem("createNotification",             "standard.createNotification")
      CALL combo.addItem("clearNotifications",             "standard.clearNotifications")
      CALL combo.addItem("getLastNotificationInteractions","standard.getLastNotificationInteractions")
   END IF
END FUNCTION

# ---------------------------------------------------------------------------
PRIVATE FUNCTION showHint(action STRING) RETURNS ()
   DEFINE hint STRING
   CASE action
      WHEN "createNotification"
         LET hint = "GBC only: Enter Title and Content, then Execute to send a browser notification"
      WHEN "clearNotifications"
         LET hint = "GBC only: Press Execute to dismiss all active notifications (no input needed)"
      WHEN "getLastNotificationInteractions"
         LET hint = "GBC only: Press Execute to retrieve the last notification interactions (no input needed)"
      OTHERWISE
         LET hint = "Select a notification frontcall action and press Execute"
   END CASE
   DISPLAY hint TO formonly.fieldLabel
END FUNCTION

# ---------------------------------------------------------------------------
PRIVATE FUNCTION executeAction(action STRING, notifTitle STRING, notifContent STRING) RETURNS ()
   DEFINE result   STRING
   DEFINE notifId  INTEGER
   DEFINE ret      STRING

   TYPE t_nl DYNAMIC ARRAY OF RECORD
      id   STRING,
      type STRING
   END RECORD
   DEFINE nl  t_nl
   DEFINE idx INTEGER

   DEFINE options RECORD
      id      INTEGER,
      title   STRING,
      content STRING,
      icon    STRING
   END RECORD

   TRY
      CASE action

         WHEN "createNotification"
            IF notifTitle IS NULL OR notifTitle.trimRight() = "" THEN
               ERROR "Enter a notification Title first"
               RETURN
            END IF
            LET options.id      = 1
            LET options.title   = notifTitle
            LET options.content = IIF(notifContent IS NULL, "", notifContent)
            LET options.icon    = ""
            CALL ui.Interface.frontCall(
               "standard", "createNotification",
               [options], [notifId]
            )
            IF notifId IS NOT NULL AND notifId > 0 THEN
               LET result = SFMT("Notification created with ID: %1\nCheck your system notification area / Action Center.", notifId)
            ELSE
               LET result = SFMT("createNotification returned ID=%1\n(Check Windows notification settings if not visible)", notifId)
            END IF

         WHEN "clearNotifications"
            CALL ui.Interface.frontCall(
               "standard", "clearNotifications",
               [""], [ret]
            )
            LET result = SFMT("clearNotifications returned: %1", IIF(ret IS NULL, "(null)", ret))

         WHEN "getLastNotificationInteractions"
            CALL ui.Interface.frontCall(
               "standard", "getLastNotificationInteractions",
               [], [nl]
            )
            IF nl.getLength() = 0 THEN
               LET result = "No notification interactions found"
            ELSE
               LET result = SFMT("Found %1 interaction(s):\n", nl.getLength())
               FOR idx = 1 TO nl.getLength()
                  LET result = result,
                     SFMT("  [%1] ID: %2  Type: %3\n", idx, nl[idx].id, nl[idx].type)
               END FOR
            END IF

         OTHERWISE
            LET result = SFMT("Unknown action: %1", action)

      END CASE
   CATCH
      IF STATUS = -6332 THEN
         LET result = SFMT("Not supported in GDC (Error %1).\nAll notification frontcalls require GBC (browser client).\nRun via: http://localhost:6394/ua/r/NotificationDemo", STATUS)
      ELSE
         LET result = SFMT("Error %1: %2", STATUS, err_get(STATUS))
      END IF
   END TRY

   DISPLAY result TO formonly.result
   MESSAGE SFMT("[%1] => %2", action, result)

END FUNCTION
