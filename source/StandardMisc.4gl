IMPORT FGL com.fourjs.fclib.MiscLib
IMPORT FGL com.fourjs.fclib.FrontCallLib

PUBLIC FUNCTION composeMail() RETURNS ()
   DEFINE mailTo STRING
   DEFINE mailSubject STRING
   DEFINE mailContent STRING
   DEFINE mailCC STRING
   DEFINE mailBCC STRING
   DEFINE r MiscLib.t_msStringResult

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
         LET r = MiscLib.composeMail(mailTo, mailSubject, mailContent, mailCC, mailBCC)
         IF r.success THEN
            MESSAGE r.message
         ELSE
            ERROR r.message
         END IF
         CONTINUE INPUT
   END INPUT

   LET int_flag = FALSE
   CALL closeWindow()

END FUNCTION #composeMail

PUBLIC FUNCTION connectivity() RETURNS ()
   DEFINE r MiscLib.t_msStringResult

   LET r = MiscLib.connectivity()

   MENU "Connectivity"
      ATTRIBUTES(STYLE="dialog", COMMENT=r.message)
      COMMAND "OK"
         EXIT MENU
   END MENU

END FUNCTION #connectivity

PUBLIC FUNCTION isForeground() RETURNS ()
   DEFINE r MiscLib.t_msBoolResult

   LET r = MiscLib.isForeground()

   MENU "Is Foreground"
      ATTRIBUTES(STYLE="dialog", COMMENT=r.message)
      COMMAND "OK"
         EXIT MENU
   END MENU

END FUNCTION #isForeground

PUBLIC FUNCTION getGeolocation() RETURNS ()
   DEFINE r MiscLib.t_msGeoResult

   CALL openWindow("Geolocation", "Get Geolocation")

   LET r = MiscLib.getGeolocation()

   DISPLAY IIF(r.success, "ok", "error") TO formonly.geoStatus
   DISPLAY r.latitude TO formonly.geoLatitude
   DISPLAY r.longitude TO formonly.geoLongitude

   MENU
      ATTRIBUTES(STYLE="dialog", COMMENT=r.message)
      COMMAND "OK"
         EXIT MENU
   END MENU

   CALL closeWindow()

END FUNCTION #getGeolocation

PUBLIC FUNCTION clearFileCache() RETURNS ()
   DEFINE r FrontCallLib.t_result

   LET r = MiscLib.clearFileCache()

   MENU "Clear File Cache"
      ATTRIBUTES(STYLE="dialog", COMMENT=r.message)
      COMMAND "OK"
         EXIT MENU
   END MENU

END FUNCTION #clearFileCache

PUBLIC FUNCTION storeSize() RETURNS ()
   DEFINE r FrontCallLib.t_result

   LET r = MiscLib.storeSize()

   MENU "Store Size"
      ATTRIBUTES(STYLE="dialog", COMMENT=r.message)
      COMMAND "OK"
         EXIT MENU
   END MENU

END FUNCTION #storeSize

PUBLIC FUNCTION restoreSize() RETURNS ()
   DEFINE delay INTEGER
   DEFINE r FrontCallLib.t_result

   CALL openWindow("WindowSize", "Restore Window Size")

   INPUT delay WITHOUT DEFAULTS FROM formonly.restoreDelay
      ATTRIBUTES(UNBUFFERED)
      BEFORE INPUT
         DISPLAY "Enter delay in ms (e.g. 500) for smooth resize, then press OK" TO formonly.fieldLabel
         LET delay = 500
      ON ACTION CANCEL
         EXIT INPUT
      AFTER INPUT
         LET r = MiscLib.restoreSize(delay)
         IF r.success THEN
            MESSAGE r.message
         ELSE
            ERROR r.message
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
