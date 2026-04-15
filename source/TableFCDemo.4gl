#
# TableFCDemo.4gl
#
# Standalone demo for table frontcalls:
#   table.autoFitAllColumns  - resize columns to fit their data content
#   table.fitToViewAllColumns - resize all columns to fill the visible window
#
# Uses the existing TableDemo form with demo data pre-loaded.
# Press the toolbar buttons to apply each frontcall and see the effect.
#

MAIN
   DEFINE tableData DYNAMIC ARRAY OF RECORD
      col1 STRING,
      col2 STRING,
      col3 STRING,
      col4 INTEGER,
      col5 STRING
   END RECORD

   OPEN WINDOW w WITH FORM "TableDemo"
      ATTRIBUTES(TEXT="Table Frontcall Demo")
   CLOSE WINDOW SCREEN

   # Load demo data with deliberately varied column widths
   LET tableData[1].col1 = "Short"
   LET tableData[1].col2 = "This is a much longer text to test column auto-fit behaviour"
   LET tableData[1].col3 = "Medium text here"
   LET tableData[1].col4 = 12345
   LET tableData[1].col5 = "A"

   LET tableData[2].col1 = "Another short val"
   LET tableData[2].col2 = "Brief"
   LET tableData[2].col3 = "Variable length content for demonstration purposes"
   LET tableData[2].col4 = 67890
   LET tableData[2].col5 = "BB"

   LET tableData[3].col1 = "X"
   LET tableData[3].col2 = "Y"
   LET tableData[3].col3 = "Z"
   LET tableData[3].col4 = 1
   LET tableData[3].col5 = "Very long value in the last column to test auto-fit"

   LET tableData[4].col1 = "Product Alpha with Extended Name"
   LET tableData[4].col2 = "Description of the alpha product line"
   LET tableData[4].col3 = "Category A"
   LET tableData[4].col4 = 99999
   LET tableData[4].col5 = "Active"

   LET tableData[5].col1 = "Beta"
   LET tableData[5].col2 = "Short desc"
   LET tableData[5].col3 = "Cat B"
   LET tableData[5].col4 = 42
   LET tableData[5].col5 = "Inactive"

   DISPLAY ARRAY tableData TO srTableDemo.*

      BEFORE DISPLAY
         MESSAGE "Auto Fit = resize columns to data width   |   Fit to View = fill window width"

      ON ACTION autofit ATTRIBUTES(TEXT="Auto Fit Columns", IMAGE="fa-arrows-h")
         CALL ui.Interface.frontCall(
            "table", "autoFitAllColumns",
            ["srTableDemo"], []
         )
         MESSAGE "autoFitAllColumns applied — columns now sized to their content"

      ON ACTION fittoview ATTRIBUTES(TEXT="Fit to View", IMAGE="fa-expand")
         CALL ui.Interface.frontCall(
            "table", "fitToViewAllColumns",
            ["srTableDemo"], []
         )
         MESSAGE "fitToViewAllColumns applied — all columns fill the window"

      ON ACTION CANCEL
         EXIT DISPLAY

   END DISPLAY

   CLOSE WINDOW w

END MAIN
