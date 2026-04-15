#
# WebComponentDemo.4gl
#
# Standalone demo that exercises all three webcomponent frontcalls:
#
#   webcomponent.call              - invoke a JS function in wcdemo
#   webcomponent.frontCallAPIVersion - query the API version
#   webcomponent.getTitle          - retrieve the <title> of the component
#
# Available JS functions in wcdemo:
#   echo(message)    - 1 param
#   getTimestamp()   - 0 params
#   add(a, b)        - 2 params
#   greet(name)      - 1 param
#

MAIN
   DEFINE wcAction   STRING
   DEFINE funcName   STRING
   DEFINE funcParam1 STRING
   DEFINE funcParam2 STRING

   OPEN WINDOW w WITH FORM "WebComponentDemo"
      ATTRIBUTES(TEXT="Web Component Frontcall Demo")
   CLOSE WINDOW SCREEN

   INPUT wcAction, funcName, funcParam1, funcParam2 WITHOUT DEFAULTS
      FROM formonly.wcAction, formonly.funcName, formonly.funcParam1, formonly.funcParam2
      ATTRIBUTES(UNBUFFERED, accept=FALSE)

      BEFORE INPUT
         CALL setupActionCombo()
         CALL showHint(NULL)
         CALL updateFieldState(DIALOG, NULL, NULL)

      ON CHANGE wcAction
         CALL showHint(wcAction)
         IF wcAction = "call" THEN
            CALL setupFuncCombo()
            CALL updateFieldState(DIALOG, wcAction, funcName)
         ELSE
            CALL updateFieldState(DIALOG, wcAction, NULL)
         END IF

      ON CHANGE funcName
         CALL updateFieldState(DIALOG, wcAction, funcName)
         CALL showFuncHint(funcName)

      ON ACTION execute ATTRIBUTES(TEXT="Execute", IMAGE="fa-play")
         ACCEPT INPUT

      ON ACTION CANCEL
         EXIT INPUT

      AFTER INPUT
         IF wcAction IS NULL THEN
            ERROR "Select an action first"
            CONTINUE INPUT
         END IF
         CALL executeAction(wcAction, funcName, funcParam1, funcParam2)
         CONTINUE INPUT

   END INPUT

   CLOSE WINDOW w

END MAIN

# ---------------------------------------------------------------------------
PRIVATE FUNCTION setupActionCombo() RETURNS ()
   DEFINE combo ui.ComboBox

   LET combo = ui.ComboBox.forName("formonly.wcAction")
   IF combo IS NOT NULL THEN
      CALL combo.addItem("call",                "webcomponent.call")
      CALL combo.addItem("frontCallAPIVersion", "webcomponent.frontCallAPIVersion")
      CALL combo.addItem("getTitle",            "webcomponent.getTitle")
   END IF

END FUNCTION #setupActionCombo

# ---------------------------------------------------------------------------
PRIVATE FUNCTION setupFuncCombo() RETURNS ()
   DEFINE combo ui.ComboBox

   LET combo = ui.ComboBox.forName("formonly.funcName")
   IF combo IS NOT NULL THEN
      CALL combo.clear()
      CALL combo.addItem("echo",         "echo(message)")
      CALL combo.addItem("getTimestamp", "getTimestamp()")
      CALL combo.addItem("add",          "add(a, b)")
      CALL combo.addItem("greet",        "greet(name)")
   END IF

END FUNCTION #setupFuncCombo

# ---------------------------------------------------------------------------
PRIVATE FUNCTION updateFieldState(d ui.Dialog, wcAction STRING, funcName STRING) RETURNS ()

   IF wcAction = "call" THEN
      CALL d.setFieldActive("formonly.funcName", TRUE)
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
   ELSE
      CALL d.setFieldActive("formonly.funcName", FALSE)
      CALL d.setFieldActive("formonly.funcParam1", FALSE)
      CALL d.setFieldActive("formonly.funcParam2", FALSE)
   END IF

END FUNCTION #updateFieldState

# ---------------------------------------------------------------------------
PRIVATE FUNCTION showHint(wcAction STRING) RETURNS ()
   DEFINE hint STRING

   CASE wcAction
      WHEN "call"
         LET hint = "Select a JavaScript function from the combo and press Execute"
      WHEN "frontCallAPIVersion"
         LET hint = "Returns the Genero Web Component API version string (no inputs needed)"
      WHEN "getTitle"
         LET hint = "Returns the HTML <title> of the wcdemo component (no inputs needed)"
      OTHERWISE
         LET hint = "Select an action and press Execute"
   END CASE

   DISPLAY hint TO formonly.fieldLabel

END FUNCTION #showHint

# ---------------------------------------------------------------------------
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

# ---------------------------------------------------------------------------
PRIVATE FUNCTION executeAction(wcAction STRING, funcName STRING, funcParam1 STRING, funcParam2 STRING) RETURNS ()
   DEFINE result STRING

   TRY
      CASE wcAction

         WHEN "call"
            IF funcName IS NULL OR funcName.trimRight() = "" THEN
               ERROR "Select a function first"
               RETURN
            END IF
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

         WHEN "frontCallAPIVersion"
            CALL ui.Interface.frontCall(
               "webcomponent", "frontCallAPIVersion",
               [],
               [result]
            )

         WHEN "getTitle"
            CALL ui.Interface.frontCall(
               "webcomponent", "getTitle",
               ["formonly.wc"],
               [result]
            )

         OTHERWISE
            LET result = SFMT("Unknown action: %1", wcAction)

      END CASE
   CATCH
      LET result = SFMT("Error %1: %2", STATUS, err_get(STATUS))
   END TRY

   DISPLAY result TO formonly.result
   MESSAGE SFMT("[%1] => %2", wcAction, result)

END FUNCTION #executeAction
