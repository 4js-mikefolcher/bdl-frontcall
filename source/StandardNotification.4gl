IMPORT FGL com.fourjs.fclib.NotificationLib
IMPORT FGL com.fourjs.fclib.FrontCallLib

PUBLIC FUNCTION createNotification() RETURNS ()
   DEFINE notifTitle STRING
   DEFINE notifContent STRING
   DEFINE notifIcon STRING
   DEFINE options NotificationLib.t_nfOptions
   DEFINE r NotificationLib.t_nfCreateResult

   CALL openWindow("Notification", "Create Notification")

   INPUT notifTitle, notifContent, notifIcon WITHOUT DEFAULTS
      FROM formonly.notifTitle, formonly.notifContent, formonly.notifIcon
      ATTRIBUTES(UNBUFFERED)
      BEFORE INPUT
         DISPLAY "Enter notification details and press OK" TO formonly.fieldLabel
      ON ACTION CANCEL
         EXIT INPUT
      AFTER INPUT
         IF notifTitle IS NULL THEN
            ERROR "Notification title is required"
            CONTINUE INPUT
         END IF
         LET options.id = NULL
         LET options.title = notifTitle
         LET options.content = notifContent
         LET options.icon = notifIcon
         LET r = NotificationLib.createNotification(options)
         IF r.success THEN
            MESSAGE r.message
         ELSE
            ERROR r.message
         END IF
         CONTINUE INPUT
   END INPUT

   LET int_flag = FALSE
   CALL closeWindow()

END FUNCTION #createNotification

PUBLIC FUNCTION clearNotifications() RETURNS ()
   DEFINE r FrontCallLib.t_result
   DEFINE response STRING

   MENU "Clear Notifications"
      ATTRIBUTES(STYLE="dialog", COMMENT="Clear all notifications?")
      COMMAND "Clear All"
         LET r = NotificationLib.clearNotifications(NULL)
         LET response = r.message
      COMMAND "Cancel"
         LET response = "Cancelled"
   END MENU

   IF response IS NOT NULL THEN
      MENU "Result"
         ATTRIBUTES(STYLE="dialog", COMMENT=response)
         COMMAND "OK"
            EXIT MENU
      END MENU
   END IF

END FUNCTION #clearNotifications

PUBLIC FUNCTION getLastNotificationInteractions() RETURNS ()
   DEFINE r NotificationLib.t_nfInteractionsResult
   DEFINE resultText STRING
   DEFINE idx INTEGER

   LET r = NotificationLib.getLastNotificationInteractions()

   IF NOT r.success THEN
      LET resultText = r.message
   ELSE
      IF r.interactions.getLength() = 0 THEN
         LET resultText = "No notification interactions found"
      ELSE
         LET resultText = SFMT("Found %1 interaction(s):\n", r.interactions.getLength())
         FOR idx = 1 TO r.interactions.getLength()
            LET resultText = resultText,
               SFMT("  ID: %1, Type: %2\n", r.interactions[idx].id, r.interactions[idx].type)
         END FOR
      END IF
   END IF

   MENU "Notification Interactions"
      ATTRIBUTES(STYLE="dialog", COMMENT=resultText)
      COMMAND "OK"
         EXIT MENU
   END MENU

END FUNCTION #getLastNotificationInteractions

PRIVATE FUNCTION openWindow(formName STRING, formTitle STRING) RETURNS ()

   OPEN WINDOW notifWindow WITH FORM formName
      ATTRIBUTES(TEXT=formTitle)

END FUNCTION #openWindow

PRIVATE FUNCTION closeWindow() RETURNS ()

   TRY
      CLOSE WINDOW notifWindow
   CATCH
      #suppress error
   END TRY

END FUNCTION #closeWindow
