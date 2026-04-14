DEFINE tableData DYNAMIC ARRAY OF RECORD
   col1 STRING,
   col2 STRING,
   col3 STRING,
   col4 INTEGER,
   col5 STRING
END RECORD

PUBLIC FUNCTION tableAutoFit() RETURNS ()

   CALL loadDemoData()
   CALL openWindow("TableDemo", "table.autoFitAllColumns")

   DISPLAY ARRAY tableData TO srTableDemo.*
      BEFORE DISPLAY
         MESSAGE "Press 'Auto Fit' to adapt column widths to data"
      ON ACTION autofit ATTRIBUTES(TEXT="Auto Fit")
         CALL ui.Interface.frontCall(
            "table",
            "autoFitAllColumns",
            ["srTableDemo"],
            []
         )
         MESSAGE "autoFitAllColumns applied"
      ON ACTION CANCEL
         EXIT DISPLAY
   END DISPLAY

   CALL closeWindow()

END FUNCTION #tableAutoFit

PUBLIC FUNCTION tableFitToView() RETURNS ()

   CALL loadDemoData()
   CALL openWindow("TableDemo", "table.fitToViewAllColumns")

   DISPLAY ARRAY tableData TO srTableDemo.*
      BEFORE DISPLAY
         MESSAGE "Press 'Fit to View' to show all columns in window"
      ON ACTION fittoview ATTRIBUTES(TEXT="Fit to View")
         CALL ui.Interface.frontCall(
            "table",
            "fitToViewAllColumns",
            ["srTableDemo"],
            []
         )
         MESSAGE "fitToViewAllColumns applied"
      ON ACTION CANCEL
         EXIT DISPLAY
   END DISPLAY

   CALL closeWindow()

END FUNCTION #tableFitToView

PRIVATE FUNCTION loadDemoData() RETURNS ()

   CALL tableData.clear()
   LET tableData[1].col1 = "Short"
   LET tableData[1].col2 = "This is a much longer text for testing column auto-fit"
   LET tableData[1].col3 = "Medium text"
   LET tableData[1].col4 = 12345
   LET tableData[1].col5 = "A"

   LET tableData[2].col1 = "Another short value"
   LET tableData[2].col2 = "Brief"
   LET tableData[2].col3 = "This column has variable length content for demonstration"
   LET tableData[2].col4 = 67890
   LET tableData[2].col5 = "BB"

   LET tableData[3].col1 = "X"
   LET tableData[3].col2 = "Y"
   LET tableData[3].col3 = "Z"
   LET tableData[3].col4 = 1
   LET tableData[3].col5 = "Very long value in the last column to test auto-fit behavior"

   LET tableData[4].col1 = "Product Alpha with Extended Name"
   LET tableData[4].col2 = "Description of alpha product"
   LET tableData[4].col3 = "Category A"
   LET tableData[4].col4 = 99999
   LET tableData[4].col5 = "Active"

   LET tableData[5].col1 = "Beta"
   LET tableData[5].col2 = "Short desc"
   LET tableData[5].col3 = "Cat B"
   LET tableData[5].col4 = 42
   LET tableData[5].col5 = "Inactive"

END FUNCTION #loadDemoData

PRIVATE FUNCTION openWindow(formName STRING, formTitle STRING) RETURNS ()

   OPEN WINDOW tableWindow WITH FORM formName
      ATTRIBUTES(TEXT=formTitle)

END FUNCTION #openWindow

PRIVATE FUNCTION closeWindow() RETURNS ()

   TRY
      CLOSE WINDOW tableWindow
   CATCH
      #suppress error
   END TRY

END FUNCTION #closeWindow
