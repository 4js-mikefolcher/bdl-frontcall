IMPORT FGL com.fourjs.fclib.LocalStorageLib
IMPORT FGL com.fourjs.fclib.FrontCallLib

PUBLIC FUNCTION storageSetItem() RETURNS ()
   DEFINE storageKey STRING
   DEFINE storageValue STRING
   DEFINE r FrontCallLib.t_result

   CALL openWindow("LocalStorage", "localStorage.setItem")

   INPUT storageKey, storageValue WITHOUT DEFAULTS
      FROM formonly.storageKey, formonly.storageValue
      ATTRIBUTES(UNBUFFERED)
      BEFORE INPUT
         DISPLAY "Enter a key and value, then press OK to store" TO formonly.fieldLabel
      ON ACTION CANCEL
         EXIT INPUT
      AFTER INPUT
         IF storageKey IS NULL THEN
            ERROR "Key is required"
            CONTINUE INPUT
         END IF
         LET r = LocalStorageLib.setItem(storageKey, storageValue)
         IF r.success THEN
            MESSAGE r.message
         ELSE
            ERROR r.message
         END IF
   END INPUT

   LET int_flag = FALSE
   CALL closeWindow()

END FUNCTION #storageSetItem

PUBLIC FUNCTION storageGetItem() RETURNS ()
   DEFINE storageKey STRING
   DEFINE r LocalStorageLib.t_lsGetResult

   CALL openWindow("LocalStorage", "localStorage.getItem")

   INPUT storageKey WITHOUT DEFAULTS FROM formonly.storageKey
      ATTRIBUTES(UNBUFFERED)
      BEFORE INPUT
         DISPLAY "Enter a key and press OK to retrieve its value" TO formonly.fieldLabel
      ON ACTION CANCEL
         EXIT INPUT
      AFTER INPUT
         IF storageKey IS NULL THEN
            ERROR "Key is required"
            CONTINUE INPUT
         END IF
         LET r = LocalStorageLib.getItem(storageKey)
         IF r.success THEN
            DISPLAY r.value TO formonly.storageValue
            MESSAGE r.message
         ELSE
            ERROR r.message
         END IF
         CONTINUE INPUT
   END INPUT

   LET int_flag = FALSE
   CALL closeWindow()

END FUNCTION #storageGetItem

PUBLIC FUNCTION storageKeys() RETURNS ()
   DEFINE r LocalStorageLib.t_lsKeysResult
   DEFINE comment STRING

   LET r = LocalStorageLib.keys()

   IF r.success AND r.keys IS NOT NULL AND r.keys.getLength() > 0 THEN
      LET comment = SFMT("Stored keys:\n%1", r.keys)
   ELSE
      LET comment = r.message
   END IF

   MENU "localStorage Keys"
      ATTRIBUTES(STYLE="dialog", COMMENT=comment)
      COMMAND "OK"
         EXIT MENU
   END MENU

END FUNCTION #storageKeys

PUBLIC FUNCTION storageRemoveItem() RETURNS ()
   DEFINE storageKey STRING
   DEFINE r FrontCallLib.t_result

   CALL openWindow("LocalStorage", "localStorage.removeItem")

   INPUT storageKey WITHOUT DEFAULTS FROM formonly.storageKey
      ATTRIBUTES(UNBUFFERED)
      BEFORE INPUT
         DISPLAY "Enter a key and press OK to remove it" TO formonly.fieldLabel
      ON ACTION CANCEL
         EXIT INPUT
      AFTER INPUT
         IF storageKey IS NULL THEN
            ERROR "Key is required"
            CONTINUE INPUT
         END IF
         LET r = LocalStorageLib.removeItem(storageKey)
         IF r.success THEN
            MESSAGE r.message
         ELSE
            ERROR r.message
         END IF
   END INPUT

   LET int_flag = FALSE
   CALL closeWindow()

END FUNCTION #storageRemoveItem

PUBLIC FUNCTION storageClear() RETURNS ()
   DEFINE r FrontCallLib.t_result
   DEFINE response STRING

   MENU "Clear Local Storage"
      ATTRIBUTES(STYLE="dialog", COMMENT="This will remove ALL key/value pairs from local storage. Continue?")
      COMMAND "Clear All"
         LET r = LocalStorageLib.clear()
         LET response = r.message
      COMMAND "Cancel"
         LET response = "Cancelled"
   END MENU

   MENU "Result"
      ATTRIBUTES(STYLE="dialog", COMMENT=response)
      COMMAND "OK"
         EXIT MENU
   END MENU

END FUNCTION #storageClear

PRIVATE FUNCTION openWindow(formName STRING, formTitle STRING) RETURNS ()

   OPEN WINDOW storageWindow WITH FORM formName
      ATTRIBUTES(TEXT=formTitle)

END FUNCTION #openWindow

PRIVATE FUNCTION closeWindow() RETURNS ()

   TRY
      CLOSE WINDOW storageWindow
   CATCH
      #suppress error
   END TRY

END FUNCTION #closeWindow
