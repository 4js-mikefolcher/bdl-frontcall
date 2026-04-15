IMPORT util

PUBLIC FUNCTION setTheme() RETURNS ()
   DEFINE themeName STRING
   DEFINE themeList STRING

   CALL openWindow("ThemeSelect", "Set Theme")

   # Pre-populate the combo with available themes
   CALL ui.Interface.frontCall(
      "theme",
      "listThemes",
      [],
      [themeList]
   )

   INPUT themeName WITHOUT DEFAULTS FROM formonly.themeName
      ATTRIBUTES(UNBUFFERED)
      BEFORE INPUT
         DISPLAY "Select a theme and press OK to apply" TO formonly.fieldLabel
         CALL populateThemeCombo(themeList)
      ON ACTION CANCEL
         EXIT INPUT
      AFTER INPUT
         IF themeName IS NULL THEN
            ERROR "Select a theme to apply"
            CONTINUE INPUT
         END IF
         CALL ui.Interface.frontCall(
            "theme",
            "setTheme",
            [themeName],
            []
         )
         MESSAGE SFMT("Theme set to: %1", themeName)
         CONTINUE INPUT
   END INPUT

   LET int_flag = FALSE
   CALL closeWindow()

END FUNCTION #setTheme

PUBLIC FUNCTION getCurrentTheme() RETURNS ()
   DEFINE result STRING

   CALL ui.Interface.frontCall(
      "theme",
      "getCurrentTheme",
      [],
      [result]
   )

   MENU "Current Theme"
      ATTRIBUTES(STYLE="dialog", COMMENT=SFMT("Current theme: %1", result))
      COMMAND "OK"
         EXIT MENU
   END MENU

END FUNCTION #getCurrentTheme

PUBLIC FUNCTION listThemes() RETURNS ()
   DEFINE result STRING

   CALL ui.Interface.frontCall(
      "theme",
      "listThemes",
      [],
      [result]
   )

   IF result IS NULL THEN
      MENU "Available Themes"
         ATTRIBUTES(STYLE="dialog", COMMENT="(no themes available)")
         COMMAND "OK"
            EXIT MENU
      END MENU
      RETURN
   END IF

   CALL showThemeTree(result)

END FUNCTION #listThemes

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
   DEFINE condKey STRING
   DEFINE condMap DICTIONARY OF STRING
   DEFINE nodeId INTEGER
   DEFINE i INTEGER
   DEFINE j INTEGER
   DEFINE condStr STRING

   LET nodeId = 0

   TRY
      LET jarr = util.JSONArray.parse(jsonStr)
   CATCH
      MENU "Theme List"
         ATTRIBUTES(STYLE="dialog", COMMENT=SFMT("Themes: %1", jsonStr))
         COMMAND "OK"
            EXIT MENU
      END MENU
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
      LET condKey = condStr
      IF NOT condMap.contains(condKey) THEN
         LET nodeId = nodeId + 1
         LET condMap[condKey] = nodeId
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
      LET treeData[treeData.getLength()].pid = condMap[condKey]
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

PRIVATE FUNCTION populateThemeCombo(themeList STRING) RETURNS ()
   DEFINE combo ui.ComboBox
   DEFINE tokenizer base.StringTokenizer
   DEFINE themeName STRING

   LET combo = ui.ComboBox.forName("formonly.themeName")
   IF combo IS NULL THEN
      RETURN
   END IF

   IF themeList IS NULL THEN
      RETURN
   END IF

   # Theme list is typically comma or space separated
   LET tokenizer = base.StringTokenizer.create(themeList, ",")
   WHILE tokenizer.hasMoreTokens()
      LET themeName = tokenizer.nextToken().trim()
      IF themeName.getLength() > 0 THEN
         CALL combo.addItem(themeName, themeName)
      END IF
   END WHILE

END FUNCTION #populateThemeCombo

PRIVATE FUNCTION openWindow(formName STRING, formTitle STRING) RETURNS ()

   OPEN WINDOW themeWindow WITH FORM formName
      ATTRIBUTES(TEXT=formTitle)

END FUNCTION #openWindow

PRIVATE FUNCTION closeWindow() RETURNS ()

   TRY
      CLOSE WINDOW themeWindow
   CATCH
      #suppress error
   END TRY

END FUNCTION #closeWindow
