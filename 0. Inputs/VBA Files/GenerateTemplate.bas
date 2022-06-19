Attribute VB_Name = "GenerateTemplate"
Public StartYear, EndYear As Integer

Function IsInArray(valToBeFound As Variant, arr As Variant) As Boolean
    'DESCRIPTION: Function to check if a value is in an array of values
    'INPUT: Pass the function a value to search for and an array of values of any data type.
    'OUTPUT: True if is in array, false otherwise
    Dim element As Variant
    On Error GoTo IsInArrayError: 'array is empty
        For Each element In arr
            If element = valToBeFound Then
                IsInArray = True
                Exit Function
            End If
        Next element
    Exit Function
IsInArrayError:
    On Error GoTo 0
    IsInArray = False
End Function

Function NotExist() As Boolean

    'DESCRIPTION: Subroutine to check if template already generated
    'OUTPUT: True if template sheets exist False if it does not

    NameList = Array("Sales & Outbound Cost", "Factory Per Product", "Inbound Cost Per Product", _
    "Efficiency Per Product", "Capacity Constraints", "Capacity Volume", "Supply Constraints")
    
    NotExist = True
    For Each Worksheet In Worksheets
        If IsInArray(Worksheet.Name, NameList) Then
            NotExist = False
            MsgBox "Templates already generated"
            Exit For
        End If
    Next Worksheet
        
End Function

Function NotEmpty() As Boolean
    'DESCRIPTION: Subroutine to check if the Fac/Prod is not empty
    'OUTPUT: True if the columns in Factory or Product list is empty False otherwise
    If Sheets("Product List").Range("A1").End(xlDown).Row = 1048576 Or Sheets("Factory List").Range("A1").End(xlDown).Row = 1048576 Or Sheets("Customer List").Range("A1").End(xlDown).Row = 1048576 Then
        NotEmpty = False
        MsgBox "Factory or Product or Customer List is empty"
    Else: NotEmpty = True
    End If
    
End Function

Function GetYears() As Variant

    StartYear = InputBox("Enter the start year: ", "Start Year")
    EndYear = InputBox("Enter the end year: ", "End Year")
    
    'Change StartYear to an integer (default 2022)
    If IsNumeric(StartYear) Then
        StartYear = CInt(StartYear)
    Else:
        StartYear = 2022
    End If
        
    'Change EndYear to an integer (default StartYear+1)
    If IsNumeric(EndYear) Then
        EndYear = CInt(EndYear)
    Else:
        EndYear = StartYear + 1
    End If
        
    GetYears = Array(StartYear, EndYear)
    
End Function

Sub FormatFacProd(SheetName As String)

    'DESCRIPTION: Subroutine to delete blank rows then sort input A-Z
    'INPUT: Name of the sheet to format (Product List or Factory List)

    Sheets(SheetName).Select
    
    'Delete blank rows
    
    On Error GoTo eh
        Range("A:A").Select.SpecialCells(xlCellTypeBlanks).EntireRow.Delete
eh:
    
    'Sort and format
    Range(Range("A1"), Range("A1").End(xlDown)).Select
    
    With Selection
        .Sort key1:=Range("A2"), Order1:=xlAscending, Header:=xlYes
        .Columns.AutoFit
        .Borders.LineStyle = xlContinuous
        .VerticalAlignment = xlCenter
        .HorizontalAlignment = xlCenter
    End With
    
    Range("A1").Select

End Sub

Sub FormatCustomer()

    Sheets("Customer List").Select
    'Delete blank rows
    
    On Error GoTo eh
        Columns("A:C").SpecialCells(xlCellTypeBlanks).EntireRow.Delete
        
eh:

    'Sort and format
    Range("A1").CurrentRegion.Select
    
    With Selection
        .Sort key1:=Range("C2"), Order1:=xlAscending, key2:=Range("B2"), Order2:=xlAscending, key3:=Range("A2"), order3:=xlAscending, Header:=xlYes
        .Columns.AutoFit
        .Borders.LineStyle = xlContinuous
        .VerticalAlignment = xlCenter
        .HorizontalAlignment = xlCenter
    End With
    
    Range("A1").Select
    
    
    
End Sub

Sub FactoryProductTemplate()

    'DESCRIPTION: Subroutine to create a Factory-Product Template

    'Create Template Sheet
    Sheets.Add.Name = "FacProdTemplate"
    
    'Copy list of products from Product List
    Sheets("Product List").Select
    Range(Range("A2"), Range("A2").End(xlDown)).Copy
    
    'Paste in the column of Template
    Sheets("FacProdTemplate").Select
    Range("A2").PasteSpecial
    
    'Make bold
    Range(Range("A2"), Range("A2").End(xlDown)).Font.Bold = True
    
    'Copy list of factory from Factory List
    Sheets("Factory List").Select
    
    If Range(Range("A2"), Range("A2").End(xlDown)).Count = 1048575 Then
        Range("A2").Copy
    Else:
        Range(Range("A2"), Range("A2").End(xlDown)).Copy
    End If
    
    'Paste in the row of Template
    Sheets("FacProdTemplate").Select
    Range("B1").PasteSpecial Transpose:=True
    
    'Create the year range
    BlockSize = Range(Range("B1"), Range("B1").End(xlToRight)).Columns.Count
    If BlockSize = 16383 Then
        BlockSize = 1
    End If
    
    For Yr = EndYear - StartYear To 0 Step -1
        For Block = 1 To BlockSize
            Cells(1, BlockSize * Yr + Block + 1).Value = Yr + StartYear & " - " & Cells(1, Block + 1).Value
        Next Block
    Next Yr
    
    'Make bold
    Range(Range("B1"), Range("B1").End(xlToRight)).Font.Bold = True
    
    'Autofit the rows and columns
    Range("A1").CurrentRegion.Select
    
    With Selection
        .Columns.AutoFit
        .Borders.LineStyle = xlContinuous
        .VerticalAlignment = xlCenter
        .HorizontalAlignment = xlCenter
    End With
    
    Range("A1").Select

End Sub

Sub ConstraintsTemplate(ConsType As String)

    'DESCRIPTION: Subroutine to create a Constraint Template
    'INPUT: Type of constraints (Caps or Cons)
    
    'Create Template Sheet
    Sheets.Add.Name = ConsType & "ConsTemplate"
    
    'Copy data from Product List
    Sheets("Product List").Select
    
    'Count Number of Product
    If Range(Range("A2"), Range("A2").End(xlDown)).Count = 1048575 Then
        Range("A2").Copy
    Else:
        Range(Range("A2"), Range("A2").End(xlDown)).Copy
    End If
    
    'Paste data to header row and bold
    Sheets(ConsType & "ConsTemplate").Select
    Range("A1").Value = "CONSTRAINT"
    Range("B1").PasteSpecial Transpose:=True
    
    'Ask user for the number of constraints and create column
    If ConsType = "Cap" Then
        NumCons = InputBox("Click Cancel for manual inputting" & vbCrLf & vbCrLf & "Else input the number of capacity constraints")
    ElseIf ConsType = "Sup" Then
        NumCons = InputBox("Click Cancel for manual inputting" & vbCrLf & vbCrLf & "Else input the number of supply constraints")
    End If
    
    If IsNumeric(NumCons) Then
        NumCons = CInt(NumCons)
    ElseIf ConsType = "Caps" Then
        NumCons = 1
        MsgBox "Number of constraints must be identical for Capacity Constraints and Capacity Volume", , "Note"
    Else:
        NumCons = 1
        MsgBox "Invalid input, one constraint is created"
    End If
    
    For i = 1 To NumCons
        Cells(i + 1, 1).Value = i
        Cells(i + 1, 1).Font.Bold = True
    Next i
    
    'Create Yr Range
    BlockSize = Range(Range("B1"), Range("B1").End(xlToRight)).Columns.Count
    If BlockSize = 16383 Then
        BlockSize = 1
    End If
    
    For Yr = EndYear - StartYear To 0 Step -1
        For Block = 1 To BlockSize
            Cells(1, BlockSize * Yr + Block + 1).Value = Yr + StartYear & " - " & Cells(1, Block + 1).Value
        Next Block
    Next Yr
    
    'Autofit the rows and columns
    Range("A1").CurrentRegion.Select
    
    With Selection
        .Font.Bold = True
        .Columns.AutoFit
        .Borders.LineStyle = xlContinuous
        .VerticalAlignment = xlCenter
        .HorizontalAlignment = xlCenter
        
    End With
    Range("A1").Select
    
End Sub

Sub CapVolTemplate()
    
    'DESCRIPTION: Subroutine for generating the template of the capacity volume sheet
    
    'Create Template Sheet
    Sheets.Add.Name = "Capacity Volume"
    
    'Copy the constraint from CapCons worksheet
    Sheets("Capacity Constraints").Select
    Range(Range("A2"), Range("A2").End(xlDown)).Copy
    
    'Paste in the column of Template
    Sheets("Capacity Volume").Select
    Range("A2").PasteSpecial
    
    'Put Header
    Range("A1").Value = "CONSTRAINT"
    Range("A1").Font.Bold = True
    
    Sheets("Factory List").Select
    If Range(Range("A2"), Range("A2").End(xlDown)).Count = 1048575 Then
        Range("A2").Copy
    Else:
        Range(Range("A2"), Range("A2").End(xlDown)).Copy
    End If
    
    Sheets("Capacity Volume").Range("B1").PasteSpecial Transpose:=True
    
    'Create Yr Range
    Sheets("Capacity Volume").Select
    BlockSize = Range(Range("B1"), Range("B1").End(xlToRight)).Columns.Count
    If BlockSize = 16383 Then
        BlockSize = 1
    End If
    
    For Yr = EndYear - StartYear To 0 Step -1
        For Block = 1 To BlockSize
            Cells(1, BlockSize * Yr + Block + 1).Value = Yr + StartYear & " - " & Cells(1, Block + 1).Value
        Next Block
    Next Yr
    
    Rows("1").Font.Bold = True
    
    'Autofit the rows and columns
    Worksheets("Capacity Volume").Select
    Range("A1").CurrentRegion.Select
    
    With Selection
    
        .Columns.AutoFit
        .Borders.LineStyle = xlContinuous
        .VerticalAlignment = xlCenter
        .HorizontalAlignment = xlCenter
        
    End With
    Range("A1").Select
    
End Sub

Sub SalesVolumeTemplate()

    'DESCRIPTION: Subroutine to generate Sales Volume template
    
    'Finish this function copy and paste from customer list to sales volume and outbound cost
    
    'Create Sheet
    Sheets.Add After:=Sheets("Factory Per Product")
    ActiveSheet.Name = "Sales Volume"
    
    'Fill in Fixed Header
    Range("D1").Value = "Sales Volume"
    Range("D1").Font.Bold = True
    
    'Copy the list of customer data
    Sheets("Customer List").Select
    Range("A1").CurrentRegion.Copy
    
    'Paste in the row of Template
    Sheets("Sales Volume").Select
    ActiveSheet.Paste
    
    'Create the year range
    BlockSize = 1
    For Yr = EndYear - StartYear To 0 Step -1
        For Block = 1 To BlockSize
            Cells(1, BlockSize * Yr + Block + 3).Value = Yr + StartYear & " - " & Cells(1, Block + 3).Value
        Next Block
    Next Yr
    
    'Make first row bold
    Rows(1).Font.Bold = True
    
    'Autofit the rows and columns
    Range("A1").CurrentRegion.Select
    
    With Selection
    
        .Columns.AutoFit
        .Borders.LineStyle = xlContinuous
        .VerticalAlignment = xlCenter
        .HorizontalAlignment = xlCenter
        
    End With
    
    Range("A1").Select

End Sub

Sub OutboundCostTemplate()

    'DESCRIPTION: Subroutine to generate Outbound Cost template
    
    'Create Sheet
    Sheets.Add After:=Sheets("Sales Volume")
    ActiveSheet.Name = "Outbound Cost"
    
    'Copy the list of customer data
    Sheets("Customer List").Select
    Range("A1").CurrentRegion.Copy
    
    'Paste in the row of Template
    Sheets("Outbound Cost").Select
    ActiveSheet.Paste
    
    'Fill in the list of factories
    Sheets("Factory List").Select
    
    If Range(Range("A2"), Range("A2").End(xlDown)).Count = 1048575 Then
        Range("A2").Copy
    Else:
        Range(Range("A2"), Range("A2").End(xlDown)).Copy
    End If
    
    'Paste in the row of Template
    Sheets("Outbound Cost").Select
    Range("D1").PasteSpecial Transpose:=True
    
    'Create the year range
    BlockSize = Range(Range("D1"), Range("D1").End(xlToRight)).Columns.Count
    If BlockSize = 16381 Then
        BlockSize = 1
    End If
    
    For Yr = EndYear - StartYear To 0 Step -1
        For Block = 1 To BlockSize
            Cells(1, BlockSize * Yr + Block + 3).Value = Yr + StartYear & " - " & Cells(1, Block + 3).Value
        Next Block
    Next Yr
    
    'Make first row bold
    Rows("1").Font.Bold = True
    
    'Autofit the rows and columns
    Range("A1").CurrentRegion.Select
    
    With Selection
    
        .Columns.AutoFit
        .Borders.LineStyle = xlContinuous
        .VerticalAlignment = xlCenter
        .HorizontalAlignment = xlCenter
        
    End With
    
    Range("A1").Select

End Sub

Sub CopyTemplate(PreFix As String, NameList As Variant)

    'DESCRIPTION: Subroutine for copying template to the appropriate file
    'INPUT: Prefix for template sheet; List of Name of the sheet to copy to

    'Copy the template sheet and rename
    For Each SheetName In NameList:
        Sheets(PreFix & "Template").Copy After:=Sheets(Worksheets.Count)
        ActiveSheet.Name = SheetName
    Next
    
    'Delete Template Sheet
    Application.DisplayAlerts = False
    Sheets(PreFix & "Template").Delete
    Application.DisplayAlerts = True

End Sub

Sub Timeframe(StartYr, EndYr)
    
    'Add sheets
    Sheets.Add Before:=Worksheets(1)
    ActiveSheet.Name = "Timeframe"
    
    'Write to sheets
    Range("A1").Value = "Start"
    Range("B1").Value = "End"
    Range("A2").Value = StartYr
    Range("B2").Value = EndYr
    
    Rows(1).Font.Bold = True
    
    'Format
    Range("A1").CurrentRegion.Select
    With Selection
        .HorizontalAlignment = xlCenter
        .VerticalAlignment = xlCenter
        .Borders.LineStyle = xlContinuous
        .Columns.AutoFit
    End With
    
End Sub


Sub GenerateTemplate()

    'DESCRIPTION: Subroutine to create template from Product and Factory
    
    'If template does not exist then generate new template
    If NotExist() And NotEmpty() Then
    
        'Message before run
        If MsgBox("             Generating templates..." & vbCrLf & vbCrLf & "                       Continue?", vbOKCancel, "Generate Templates") = 1 Then
        
            'Get the year range
            YearRange = GetYears()
            StartYear = YearRange(0)
            EndYear = YearRange(1)
        
            'First, we format the input by delete blank rows
            'Sort A-Z, autofit and place border
            Call FormatFacProd("Product List")
            Call FormatFacProd("Factory List")
            Call FormatCustomer
            
            'After we create the template in a template sheet
            Call FactoryProductTemplate
            Call ConstraintsTemplate("Cap")
            Call ConstraintsTemplate("Sup")
            
            'Finally we copy the template to the appropriate sheet
            CopyTemplate PreFix:="FacProd", NameList:=Array("Factory Per Product", "Inbound Cost Per Product", "Efficiency Per Product")
            CopyTemplate PreFix:="CapCons", NameList:=Array("Capacity Constraints")
            CopyTemplate PreFix:="SupCons", NameList:=Array("Supply Constraints")
            
            Call CapVolTemplate
            Call SalesVolumeTemplate
            Call OutboundCostTemplate
            
            'Rearrange Raw Inputs Sheets
            Worksheets("Product List").Move After:=Worksheets(1)
            Worksheets("Factory List").Move After:=Worksheets(2)
            Worksheets("Customer List").Move After:=Worksheets(3)
            
            Call Timeframe(StartYear, EndYear)
            
            MsgBox "Input templates generated successfully!"
                
        End If
        
    End If

End Sub

