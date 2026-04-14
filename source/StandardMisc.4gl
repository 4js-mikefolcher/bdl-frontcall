PUBLIC FUNCTION composeMail() RETURNS ()
   DEFINE mailTo STRING
   DEFINE mailSubject STRING
   DEFINE mailContent STRING
   DEFINE mailCC STRING
   DEFINE mailBCC STRING
   DEFINE result STRING

   CALL openWindow("ComposeMail", "Compose Mail")

   INPUT mailTo, mailSubject, mailContent, mailCC, mailBCC WITHOUT DEFAULTS
      FROM formonly.mailTo, formonly.mailSubject, formonly.mailContent,
           formonly.mailCC, formonly.mailBCC
      ATTRIBUTES(UNBUFFERED)
      BEFORE INPUT
         DISPLAY "Enter mail details and press OK to compose" TO formonly.fieldLabel
      ON ACTION CANCEL
         EXIT INPUT
      AFTER INPUT
         IF mailTo IS NULL THEN
            ERROR "Recipient (To) is required"
            CONTINUE INPUT
         END IF
         CALL ui.Interface.frontCall(
            "standard",
            "composeMail",
            [mailTo, mailSubject, mailContent, mailCC, mailBCC],
            [result]
         )
         IF result == "ok" THEN
            MESSAGE "Mail application opened successfully"
         ELSE
            ERROR SFMT("composeMail returned: %1", result)
         END IF
         CONTINUE INPUT
   END INPUT

   LET int_flag = FALSE
   CALL closeWindow()

END FUNCTION #composeMail

PUBLIC FUNCTION connectivity() RETURNS ()
   DEFINE result STRING

   CALL ui.Interface.frontCall(
      "standard",
      "connectivity",
      [],
      [result]
   )

   MENU "Connectivity"
      ATTRIBUTES(STYLE="dialog", COMMENT=SFMT("Network connectivity: %1", result))
      COMMAND "OK"
         EXIT MENU
   END MENU

END FUNCTION #connectivity

PUBLIC FUNCTION isForeground() RETURNS ()
   DEFINE result BOOLEAN

   CALL ui.Interface.frontCall(
      "standard",
      "isForeground",
      [],
      [result]
   )

   MENU "Is Foreground"
      ATTRIBUTES(STYLE="dialog",
         COMMENT=SFMT("Application is in foreground: %1", IIF(result, "TRUE", "FALSE")))
      COMMAND "OK"
         EXIT MENU
   END MENU

END FUNCTION #isForeground

PUBLIC FUNCTION getGeolocation() RETURNS ()
   DEFINE status STRING
   DEFINE latitude FLOAT
   DEFINE longitude FLOAT
   DEFINE resultText STRING

   CALL openWindow("Geolocation", "Get Geolocation")

   CALL ui.Interface.frontCall(
      "standard",
      "getGeolocation",
      [],
      [status, latitude, longitude]
   )

   IF status == "ok" THEN
      LET resultText = SFMT("Latitude: %1\nLongitude: %2", latitude, longitude)
   ELSE
      LET resultText = SFMT("Error: %1", status)
   END IF

   DISPLAY status TO formonly.geoStatus
   DISPLAY latitude TO formonly.geoLatitude
   DISPLAY longitude TO formonly.geoLongitude

   MENU
      COMMAND "OK"
         EXIT MENU
   END MENU

   CALL closeWindow()

END FUNCTION #getGeolocation

PUBLIC FUNCTION clearFileCache() RETURNS ()
   DEFINE result BOOLEAN

   CALL ui.Interface.frontCall(
      "standard",
      "clearFileCache",
      [],
      [result]
   )

   IF result THEN
      MENU "Clear File Cache"
         ATTRIBUTES(STYLE="dialog", COMMENT="File cache cleared successfully")
         COMMAND "OK"
            EXIT MENU
      END MENU
   ELSE
      MENU "Clear File Cache"
         ATTRIBUTES(STYLE="dialog", COMMENT="Failed to clear file cache (only supported by GDC)")
         COMMAND "OK"
            EXIT MENU
      END MENU
   END IF

END FUNCTION #clearFileCache

PUBLIC FUNCTION storeSize() RETURNS ()
   DEFINE result BOOLEAN

   CALL ui.Interface.frontCall(
      "standard",
      "storeSize",
      [],
      [result]
   )

   IF result THEN
      MENU "Store Size"
         ATTRIBUTES(STYLE="dialog", COMMENT="Window size stored successfully. Resize the window, then use restoreSize to restore.")
         COMMAND "OK"
            EXIT MENU
      END MENU
   ELSE
      MENU "Store Size"
         ATTRIBUTES(STYLE="dialog", COMMENT="Failed to store window size (GDC only)")
         COMMAND "OK"
            EXIT MENU
      END MENU
   END IF

END FUNCTION #storeSize

PUBLIC FUNCTION restoreSize() RETURNS ()
   DEFINE delay INTEGER
   DEFINE result BOOLEAN

   CALL openWindow("WindowSize", "Restore Window Size")

   INPUT delay WITHOUT DEFAULTS FROM formonly.restoreDelay
      ATTRIBUTES(UNBUFFERED)
      BEFORE INPUT
         DISPLAY "Enter delay in ms (e.g. 500) for smooth resize, then press OK" TO formonly.fieldLabel
         LET delay = 500
      ON ACTION CANCEL
         EXIT INPUT
      AFTER INPUT
         CALL ui.Interface.frontCall(
            "standard",
            "restoreSize",
            [delay],
            [result]
         )
         IF result THEN
            MESSAGE "Window size restored"
         ELSE
            ERROR "Failed to restore window size (GDC only, requires prior storeSize call)"
         END IF
   END INPUT

   LET int_flag = FALSE
   CALL closeWindow()

END FUNCTION #restoreSize

PRIVATE FUNCTION openWindow(formName STRING, formTitle STRING) RETURNS ()

   OPEN WINDOW miscWindow WITH FORM formName
      ATTRIBUTES(TEXT=formTitle)

END FUNCTION #openWindow

PRIVATE FUNCTION closeWindow() RETURNS ()

   TRY
      CLOSE WINDOW miscWindow
   CATCH
      #suppress error
   END TRY

END FUNCTION #closeWindow
