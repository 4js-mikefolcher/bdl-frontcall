PUBLIC FUNCTION createNotification() RETURNS ()
   DEFINE notifTitle STRING
   DEFINE notifContent STRING
   DEFINE notifIcon STRING
   DEFINE options RECORD
      id INTEGER,
      title STRING,
      content STRING,
      icon STRING
   END RECORD
   DEFINE notifId INTEGER

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
         CALL ui.Interface.frontCall(
            "standard",
            "createNotification",
            [options],
            [notifId]
         )
         IF notifId IS NOT NULL THEN
            MESSAGE SFMT("Notification created with ID: %1", notifId)
         ELSE
            ERROR "Notification could not be created"
         END IF
         CONTINUE INPUT
   END INPUT

   LET int_flag = FALSE
   CALL closeWindow()

END FUNCTION #createNotification

PUBLIC FUNCTION clearNotifications() RETURNS ()
   DEFINE ret STRING
   DEFINE response STRING

   MENU "Clear Notifications"
      ATTRIBUTES(STYLE="dialog", COMMENT="Clear all notifications? Pass NULL to clear all.")
      COMMAND "Clear All"
         CALL ui.Interface.frontCall(
            "standard",
            "clearNotifications",
            [NULL],
            [ret]
         )
         LET response = SFMT("clearNotifications result: %1", ret)
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
   TYPE t_nl DYNAMIC ARRAY OF RECORD
      id STRING,
      type STRING
   END RECORD
   DEFINE nl t_nl
   DEFINE resultText STRING
   DEFINE idx INTEGER

   CALL ui.Interface.frontCall(
      "standard",
      "getLastNotificationInteractions",
      [],
      [nl]
   )

   IF nl.getLength() == 0 THEN
      LET resultText = "No notification interactions found"
   ELSE
      LET resultText = SFMT("Found %1 interaction(s):\n", nl.getLength())
      FOR idx = 1 TO nl.getLength()
         LET resultText = resultText, SFMT("  ID: %1, Type: %2\n", nl[idx].id, nl[idx].type)
      END FOR
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
