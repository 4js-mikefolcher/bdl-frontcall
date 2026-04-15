IMPORT util

PUBLIC FUNCTION webComponentCall() RETURNS ()
   DEFINE funcName   STRING
   DEFINE funcParam1 STRING
   DEFINE funcParam2 STRING
   DEFINE result     STRING

   CALL openWindow("WebComponent", "webcomponent.call")

   INPUT funcName, funcParam1, funcParam2 WITHOUT DEFAULTS
      FROM formonly.funcName, formonly.funcParam1, formonly.funcParam2
      ATTRIBUTES(UNBUFFERED)
      BEFORE INPUT
         CALL setupFuncCombo()
         DISPLAY "Select a JavaScript function and press OK" TO formonly.fieldLabel
         CALL updateFieldState(DIALOG, NULL)
      ON CHANGE funcName
         CALL updateFieldState(DIALOG, funcName)
         CALL showFuncHint(funcName)
      ON ACTION CANCEL
         EXIT INPUT
      AFTER INPUT
         IF funcName IS NULL THEN
            ERROR "Select a function first"
            CONTINUE INPUT
         END IF
         TRY
            CASE funcName
               WHEN "getTimestamp"
                  CALL ui.Interface.frontCall(
                     "webcomponent", "call",
                     ["formonly.wc", funcName],
                     [result]
                  )
               WHEN "add"
                  CALL ui.Interface.frontCall(
                     "webcomponent", "call",
                     ["formonly.wc", funcName, funcParam1, funcParam2],
                     [result]
                  )
               OTHERWISE
                  CALL ui.Interface.frontCall(
                     "webcomponent", "call",
                     ["formonly.wc", funcName, funcParam1],
                     [result]
                  )
            END CASE
            DISPLAY result TO formonly.resultValue
            MESSAGE SFMT("Result: %1", result)
         CATCH
            ERROR SFMT("Error calling web component: %1", err_get(STATUS))
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

   DISPLAY "Press 'Get Title' when the web component has loaded" TO formonly.fieldLabel

   MENU "Web Component"
      ON ACTION gettitle ATTRIBUTES(TEXT="Get Title", IMAGE="fa-tag")
         TRY
            CALL ui.Interface.frontCall(
               "webcomponent",
               "getTitle",
               ["formonly.wc"],
               [result]
            )
            DISPLAY result TO formonly.resultValue
            MESSAGE SFMT("Title: %1", result)
         CATCH
            LET result = SFMT("Error: %1", err_get(STATUS))
            DISPLAY result TO formonly.resultValue
         END TRY
      ON ACTION CANCEL
         EXIT MENU
   END MENU

   LET int_flag = FALSE
   CALL closeWindow()

END FUNCTION #webComponentGetTitle

PRIVATE FUNCTION setupFuncCombo() RETURNS ()
   DEFINE combo ui.ComboBox

   LET combo = ui.ComboBox.forName("formonly.funcName")
   IF combo IS NOT NULL THEN
      CALL combo.addItem("echo",         "echo(message)")
      CALL combo.addItem("getTimestamp", "getTimestamp()")
      CALL combo.addItem("add",          "add(a, b)")
      CALL combo.addItem("greet",        "greet(name)")
   END IF

END FUNCTION #setupFuncCombo

PRIVATE FUNCTION updateFieldState(d ui.Dialog, funcName STRING) RETURNS ()

   CASE funcName
      WHEN "echo"
         CALL d.setFieldActive("formonly.funcParam1", TRUE)
         CALL d.setFieldActive("formonly.funcParam2", FALSE)
      WHEN "getTimestamp"
         CALL d.setFieldActive("formonly.funcParam1", FALSE)
         CALL d.setFieldActive("formonly.funcParam2", FALSE)
      WHEN "add"
         CALL d.setFieldActive("formonly.funcParam1", TRUE)
         CALL d.setFieldActive("formonly.funcParam2", TRUE)
      WHEN "greet"
         CALL d.setFieldActive("formonly.funcParam1", TRUE)
         CALL d.setFieldActive("formonly.funcParam2", FALSE)
      OTHERWISE
         CALL d.setFieldActive("formonly.funcParam1", FALSE)
         CALL d.setFieldActive("formonly.funcParam2", FALSE)
   END CASE

END FUNCTION #updateFieldState

PRIVATE FUNCTION showFuncHint(funcName STRING) RETURNS ()
   DEFINE hint STRING

   CASE funcName
      WHEN "echo"
         LET hint = "echo(message) — Param 1: text to echo back"
      WHEN "getTimestamp"
         LET hint = "getTimestamp() — no parameters needed"
      WHEN "add"
         LET hint = "add(a, b) — Param 1: first number, Param 2: second number"
      WHEN "greet"
         LET hint = "greet(name) — Param 1: name to greet"
      OTHERWISE
         LET hint = "Select a function"
   END CASE

   DISPLAY hint TO formonly.fieldLabel

END FUNCTION #showFuncHint

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
