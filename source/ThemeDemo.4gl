IMPORT util

#
# ThemeDemo.4gl
#
# Standalone demo for theme frontcalls:
#   theme.listThemes      - populates the combobox with available themes
#   theme.getCurrentTheme - pre-selects the active theme on startup
#   theme.setTheme        - applies the theme when the user selects one
#
# Also provides a "Show Tree" button to view themes in a tree hierarchy.
#

MAIN
   DEFINE themeName    STRING
   DEFINE currentTheme STRING
   DEFINE themeListJson STRING

   OPEN WINDOW w WITH FORM "ThemeDemo"
      ATTRIBUTES(TEXT="Theme Frontcall Demo")
   CLOSE WINDOW SCREEN

   # Get available themes and populate the combobox
   TRY
      CALL ui.Interface.frontCall("theme", "listThemes", [], [themeListJson])
   CATCH
      DISPLAY "Could not retrieve theme list" TO formonly.result
   END TRY

   # Get the current theme
   TRY
      CALL ui.Interface.frontCall("theme", "getCurrentTheme", [], [currentTheme])
   CATCH
      LET currentTheme = NULL
   END TRY

   # Pre-select the current theme
   LET themeName = currentTheme

   INPUT themeName WITHOUT DEFAULTS
      FROM formonly.themeName
      ATTRIBUTES(UNBUFFERED, accept=FALSE)

      BEFORE INPUT
         DISPLAY "Select a theme to apply it" TO formonly.fieldLabel
         CALL populateThemeCombo(themeListJson)
         IF currentTheme IS NOT NULL THEN
            DISPLAY SFMT("Current theme: %1", currentTheme) TO formonly.result
         END IF

      ON CHANGE themeName
         IF themeName IS NOT NULL THEN
            TRY
               CALL ui.Interface.frontCall(
                  "theme", "setTheme",
                  [themeName], []
               )
               DISPLAY SFMT("Theme applied: %1", themeName) TO formonly.result
               MESSAGE SFMT("Theme set to: %1", themeName)
            CATCH
               DISPLAY SFMT("Error applying theme: %1", err_get(STATUS)) TO formonly.result
            END TRY
         END IF

      ON ACTION showtree ATTRIBUTES(TEXT="Show Tree", IMAGE="fa-sitemap")
         IF themeListJson IS NOT NULL THEN
            CALL showThemeTree(themeListJson)
         ELSE
            ERROR "No theme data available"
         END IF

      ON ACTION CANCEL
         EXIT INPUT

   END INPUT

   CLOSE WINDOW w

END MAIN

# ---------------------------------------------------------------------------
PRIVATE FUNCTION populateThemeCombo(themeListJson STRING) RETURNS ()
   DEFINE combo     ui.ComboBox
   DEFINE jarr      util.JSONArray
   DEFINE jobj      util.JSONObject
   DEFINE tokenizer base.StringTokenizer
   DEFINE i         INTEGER
   DEFINE name      STRING
   DEFINE title     STRING

   LET combo = ui.ComboBox.forName("formonly.themeName")
   IF combo IS NULL THEN RETURN END IF
   IF themeListJson IS NULL THEN RETURN END IF

   TRY
      LET jarr = util.JSONArray.parse(themeListJson)
      FOR i = 1 TO jarr.getLength()
         LET jobj = jarr.get(i)
         LET name = jobj.get("name")
         LET title = jobj.get("title")
         CALL combo.addItem(name, title)
      END FOR
   CATCH
      # Fallback: treat as comma-separated list
      LET tokenizer = base.StringTokenizer.create(themeListJson, ",")
      WHILE tokenizer.hasMoreTokens()
         LET name = tokenizer.nextToken().trim()
         IF name.getLength() > 0 THEN
            CALL combo.addItem(name, name)
         END IF
      END WHILE
   END TRY
END FUNCTION

# ---------------------------------------------------------------------------
PRIVATE FUNCTION showThemeTree(jsonStr STRING) RETURNS ()
   DEFINE treeData DYNAMIC ARRAY OF RECORD
      tname    STRING,
      title    STRING,
      pid      STRING,
      id       STRING,
      expanded BOOLEAN,
      isnode   BOOLEAN,
      image    STRING
   END RECORD
   DEFINE jarr util.JSONArray
   DEFINE jobj util.JSONObject
   DEFINE conds util.JSONArray
   DEFINE condMap DICTIONARY OF STRING
   DEFINE nodeId INTEGER
   DEFINE i INTEGER
   DEFINE j INTEGER
   DEFINE condStr STRING

   LET nodeId = 0

   TRY
      LET jarr = util.JSONArray.parse(jsonStr)
   CATCH
      RETURN
   END TRY

   # Build tree: group themes by their conditions
   FOR i = 1 TO jarr.getLength()
      LET jobj = jarr.get(i)

      # Build condition string for grouping
      LET condStr = ""
      IF jobj.has("conditions") AND jobj.getType("conditions") = "ARRAY" THEN
         LET conds = jobj.get("conditions")
         FOR j = 1 TO conds.getLength()
            IF j > 1 THEN
               LET condStr = condStr, ", "
            END IF
            LET condStr = condStr, conds.get(j)
         END FOR
      END IF
      IF condStr.getLength() = 0 THEN
         LET condStr = "(no conditions)"
      END IF

      # Create parent node for this condition group if it doesn't exist
      IF NOT condMap.contains(condStr) THEN
         LET nodeId = nodeId + 1
         LET condMap[condStr] = nodeId
         LET treeData[treeData.getLength() + 1].tname = condStr
         LET treeData[treeData.getLength()].title = ""
         LET treeData[treeData.getLength()].pid = NULL
         LET treeData[treeData.getLength()].id = nodeId
         LET treeData[treeData.getLength()].expanded = TRUE
         LET treeData[treeData.getLength()].isnode = TRUE
         LET treeData[treeData.getLength()].image = "fa-folder-open"
      END IF

      # Add theme as child node
      LET nodeId = nodeId + 1
      LET treeData[treeData.getLength() + 1].tname = jobj.get("name")
      LET treeData[treeData.getLength()].title = jobj.get("title")
      LET treeData[treeData.getLength()].pid = condMap[condStr]
      LET treeData[treeData.getLength()].id = nodeId
      LET treeData[treeData.getLength()].expanded = FALSE
      LET treeData[treeData.getLength()].isnode = FALSE
      LET treeData[treeData.getLength()].image = "fa-paint-brush"
   END FOR

   OPEN WINDOW themeTreeWindow WITH FORM "ThemeTree"
      ATTRIBUTES(TEXT="Available Themes")

   DISPLAY ARRAY treeData TO srThemeTree.*

      ON ACTION CANCEL
         EXIT DISPLAY

   END DISPLAY

   CLOSE WINDOW themeTreeWindow

END FUNCTION #showThemeTree
