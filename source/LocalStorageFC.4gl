PUBLIC FUNCTION storageSetItem() RETURNS ()
   DEFINE storageKey STRING
   DEFINE storageValue STRING

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
         CALL ui.Interface.frontCall(
            "localStorage",
            "setItem",
            [storageKey, storageValue],
            []
         )
         MESSAGE SFMT("Stored: %1 = %2", storageKey, storageValue)
         CONTINUE INPUT
   END INPUT

   LET int_flag = FALSE
   CALL closeWindow()

END FUNCTION #storageSetItem

PUBLIC FUNCTION storageGetItem() RETURNS ()
   DEFINE storageKey STRING
   DEFINE storageValue STRING

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
         CALL ui.Interface.frontCall(
            "localStorage",
            "getItem",
            [storageKey],
            [storageValue]
         )
         DISPLAY storageValue TO formonly.storageValue
         IF storageValue IS NULL THEN
            MESSAGE SFMT("No value found for key: %1", storageKey)
         ELSE
            MESSAGE SFMT("Value for '%1': %2", storageKey, storageValue)
         END IF
         CONTINUE INPUT
   END INPUT

   LET int_flag = FALSE
   CALL closeWindow()

END FUNCTION #storageGetItem

PUBLIC FUNCTION storageKeys() RETURNS ()
   DEFINE keyList STRING

   CALL ui.Interface.frontCall(
      "localStorage",
      "keys",
      [],
      [keyList]
   )

   IF keyList IS NULL OR keyList.getLength() == 0 THEN
      LET keyList = "(no keys found)"
   END IF

   MENU "localStorage Keys"
      ATTRIBUTES(STYLE="dialog", COMMENT=SFMT("Stored keys:\n%1", keyList))
      COMMAND "OK"
         EXIT MENU
   END MENU

END FUNCTION #storageKeys

PUBLIC FUNCTION storageRemoveItem() RETURNS ()
   DEFINE storageKey STRING

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
         CALL ui.Interface.frontCall(
            "localStorage",
            "removeItem",
            [storageKey],
            []
         )
         MESSAGE SFMT("Key '%1' removed from local storage", storageKey)
   END INPUT

   LET int_flag = FALSE
   CALL closeWindow()

END FUNCTION #storageRemoveItem

PUBLIC FUNCTION storageClear() RETURNS ()
   DEFINE response STRING

   MENU "Clear Local Storage"
      ATTRIBUTES(STYLE="dialog", COMMENT="This will remove ALL key/value pairs from local storage. Continue?")
      COMMAND "Clear All"
         CALL ui.Interface.frontCall(
            "localStorage",
            "clear",
            [],
            []
         )
         LET response = "Local storage cleared successfully"
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
