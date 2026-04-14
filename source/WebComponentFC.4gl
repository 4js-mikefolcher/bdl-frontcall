PUBLIC FUNCTION webComponentCall() RETURNS ()
   DEFINE funcName STRING
   DEFINE param1 STRING
   DEFINE result STRING

   CALL openWindow("WebComponent", "webcomponent.call")

   INPUT funcName, param1 WITHOUT DEFAULTS
      FROM formonly.funcName, formonly.funcParam
      ATTRIBUTES(UNBUFFERED)
      BEFORE INPUT
         DISPLAY "Enter a JavaScript function name and parameter to call in the web component" TO formonly.fieldLabel
      ON ACTION CANCEL
         EXIT INPUT
      AFTER INPUT
         IF funcName IS NULL THEN
            ERROR "Function name is required"
            CONTINUE INPUT
         END IF
         TRY
            CALL ui.Interface.frontCall(
               "webcomponent",
               "call",
               ["formonly.wc", funcName, param1],
               [result]
            )
            DISPLAY result TO formonly.resultValue
            MESSAGE SFMT("Result: %1", result)
         CATCH
            ERROR SFMT("Error calling web component: %1", err_get(status))
         END TRY
         CONTINUE INPUT
   END INPUT

   LET int_flag = FALSE
   CALL closeWindow()

END FUNCTION #webComponentCall

PUBLIC FUNCTION frontCallAPIVersion() RETURNS ()
   DEFINE result STRING

   CALL ui.Interface.frontCall(
      "webcomponent",
      "frontCallAPIVersion",
      [],
      [result]
   )

   MENU "Web Component API Version"
      ATTRIBUTES(STYLE="dialog", COMMENT=SFMT("frontCallAPIVersion: %1", result))
      COMMAND "OK"
         EXIT MENU
   END MENU

END FUNCTION #frontCallAPIVersion

PUBLIC FUNCTION webComponentGetTitle() RETURNS ()
   DEFINE result STRING

   CALL openWindow("WebComponent", "webcomponent.getTitle")

   TRY
      CALL ui.Interface.frontCall(
         "webcomponent",
         "getTitle",
         ["formonly.wc"],
         [result]
      )
      DISPLAY result TO formonly.resultValue
   CATCH
      DISPLAY SFMT("Error: %1", err_get(status)) TO formonly.resultValue
   END TRY

   MENU
      COMMAND "OK"
         EXIT MENU
   END MENU

   CALL closeWindow()

END FUNCTION #webComponentGetTitle

PRIVATE FUNCTION openWindow(formName STRING, formTitle STRING) RETURNS ()

   OPEN WINDOW wcWindow WITH FORM formName
      ATTRIBUTES(TEXT=formTitle)

END FUNCTION #openWindow

PRIVATE FUNCTION closeWindow() RETURNS ()

   TRY
      CLOSE WINDOW wcWindow
   CATCH
      #suppress error
   END TRY

END FUNCTION #closeWindow
