#
# NotificationDemo.4gl
#
# Standalone demo for standard notification frontcalls via NotificationLib
# — no inline ui.Interface.frontCall in this module.
#

IMPORT FGL com.fourjs.fclib.NotificationLib
IMPORT FGL com.fourjs.fclib.FrontCallLib

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

PRIVATE FUNCTION setupCombo() RETURNS ()
   DEFINE combo ui.ComboBox
   LET combo = ui.ComboBox.forName("formonly.action")
   IF combo IS NOT NULL THEN
      CALL combo.addItem("createNotification",             "standard.createNotification")
      CALL combo.addItem("clearNotifications",             "standard.clearNotifications")
      CALL combo.addItem("getLastNotificationInteractions","standard.getLastNotificationInteractions")
   END IF
END FUNCTION

PRIVATE FUNCTION showHint(action STRING) RETURNS ()
   DEFINE hint STRING
   CASE action
      WHEN "createNotification"
         LET hint = "Enter Title and Content, then Execute to send a system notification"
      WHEN "clearNotifications"
         LET hint = "Press Execute to dismiss all active notifications (no input needed)"
      WHEN "getLastNotificationInteractions"
         LET hint = "Press Execute to retrieve the last notification interactions (no input needed)"
      OTHERWISE
         LET hint = "Select a notification frontcall action and press Execute"
   END CASE
   DISPLAY hint TO formonly.fieldLabel
END FUNCTION

PRIVATE FUNCTION executeAction(action STRING, notifTitle STRING, notifContent STRING) RETURNS ()
   DEFINE r FrontCallLib.t_result
   DEFINE createR NotificationLib.t_nfCreateResult
   DEFINE intR NotificationLib.t_nfInteractionsResult
   DEFINE options NotificationLib.t_nfOptions
   DEFINE result STRING
   DEFINE idx INTEGER

   CASE action

      WHEN "createNotification"
         IF notifTitle IS NULL OR notifTitle.trimRight() = "" THEN
            ERROR "Enter a notification Title first"
            RETURN
         END IF
         LET options.id = 1
         LET options.title = notifTitle
         LET options.content = IIF(notifContent IS NULL, "", notifContent)
         LET options.icon = ""
         LET createR = NotificationLib.createNotification(options)
         LET result = createR.message

      WHEN "clearNotifications"
         LET r = NotificationLib.clearNotifications("")
         LET result = r.message

      WHEN "getLastNotificationInteractions"
         LET intR = NotificationLib.getLastNotificationInteractions()
         IF NOT intR.success THEN
            LET result = intR.message
         ELSE
            IF intR.interactions.getLength() = 0 THEN
               LET result = "No notification interactions found"
            ELSE
               LET result = SFMT("Found %1 interaction(s):\n", intR.interactions.getLength())
               FOR idx = 1 TO intR.interactions.getLength()
                  LET result = result,
                     SFMT("  [%1] ID: %2  Type: %3\n", idx,
                        intR.interactions[idx].id, intR.interactions[idx].type)
               END FOR
            END IF
         END IF

      OTHERWISE
         LET result = SFMT("Unknown action: %1", action)

   END CASE

   DISPLAY result TO formonly.result
   MESSAGE SFMT("[%1] => %2", action, result)

END FUNCTION
