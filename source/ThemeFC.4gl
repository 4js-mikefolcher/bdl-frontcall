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
      LET result = "(no themes available)"
   END IF

   MENU "Available Themes"
      ATTRIBUTES(STYLE="dialog", COMMENT=SFMT("Themes: %1", result))
      COMMAND "OK"
         EXIT MENU
   END MENU

END FUNCTION #listThemes

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
