Attribute VB_Name = "PostProcessing"
'Let's try IBC - IBCF
'First create a function that creates the pivot table, then a wrapper

Public YrList As Variant

'Have public the list of sheets and product names
Public SheetList As Variant
Public ProdList As Variant

Public NoFactory As Integer

'Later I will have a format subroutine that formats everything

Sub GetInfo()

    Sheets("Inbound Cost Per Factory").Select
    
    'Unpack Number of Factories
    NoFactory = Range("A1").End(xlDown).Row - 1
    
    'Unpack YrList
    YrList = Array(Range("C1").Value, Range("C1").Value + Range("A1").End(xlToRight).Column - 3)
    
    'Unpack ProdList
    Sheets("Product List").Select
    NoProd = Range(Range("A2"), Range("A2").End(xlDown)).Count
    If NoProd = 1048575 Then
        ProdList = Array(Range("A2").Value)
    Else:
        ProdList = Range(Range("A2"), Range("A2").End(xlDown))
    End If
    'Fix this still
    'Format number style to have thousand divider as well
    
End Sub


Sub CreatePivot1(SourceSheet As String)

    'DESCRIPTION: Create the Pivot Table of Type 1
    'INPUT: SourceSheet - Name of the sheet where the source data comes from
    
    'Assuming the correct sheet is selected, create Pivot Table with
    ' - Factory in Rows
    ' - Years in Values
    ' - Product in Filter
    ' - Show Report Filter Pages
    
    '0. Get the Coordinates of the Source Data
    Worksheets(SourceSheet).Select
    Range("A1").End(xlDown).End(xlToRight).Select
    EndPoint = "R" & CStr(ActiveCell.Row) & "C" & CStr(ActiveCell.Column)
    
    PTName = "Pivot"
    
    '1. Insert Pivot Table
    Range("A1").Select
    Sheets.Add Before:=Worksheets(SourceSheet)
    ActiveSheet.Name = PTName
    Sheets(PTName).Select
    ActiveWorkbook.PivotCaches.Create(SourceType:=xlDatabase, SourceData:= _
        SourceSheet & "!R1C1:" & EndPoint, Version:=8).CreatePivotTable _
        TableDestination:=PTName & "!R3C1", TableName:=PTName, DefaultVersion _
        :=8
    Cells(3, 1).Select
    With ActiveSheet.PivotTables(PTName)
        .ColumnGrand = False
        .RowGrand = False
    End With
    ActiveSheet.PivotTables(PTName).RepeatAllLabels 2
    
    '2. Put Factory in Rows
    With ActiveSheet.PivotTables(PTName).PivotFields("Factory")
        .Orientation = xlRowField
        .Position = 1
    End With
    
    '3. Put Years in Value
    For Yr = YrList(0) To YrList(1)
        ActiveSheet.PivotTables(PTName).AddDataField ActiveSheet.PivotTables( _
        PTName).PivotFields(CStr(Yr)), "Sum of " & Yr, xlSum
    Next Yr
    
    '4. Put Product into Filters
    With ActiveSheet.PivotTables(PTName).PivotFields("Product")
        .Orientation = xlPageField
        .Position = 1
    End With
    
    '5. Show Report Filter Pages if more than one product
    If UBound(ProdList) - LBound(ProdList) + 1 > 1 Then
        ActiveSheet.PivotTables(PTName).ShowPages PageField:="Product"
    End If
        
End Sub

Sub CreatePivot2(SourceSheet As String)

    'DESCRIPTION: Create the Pivot Table of Type 2
    'INPUT: SourceSheet - Name of the sheet where the source data comes from
    
    'Assuming the correct sheet is selected, create Pivot Table with
    ' - Province in Rows
    ' - Years in Values
    ' - Factory in Columns
    ' - Product in Filter
    ' - Show Report Filter Pages
    
    '0. Get the Coordinates of the Source Data
    Worksheets(SourceSheet).Select
    Range("A1").End(xlDown).End(xlToRight).Select
    EndPoint = "R" & CStr(ActiveCell.Row) & "C" & CStr(ActiveCell.Column)
    
    PTName = "Pivot"
    
    '1. Insert Pivot Table
    Range("A1").Select
    Sheets.Add Before:=Worksheets(SourceSheet)
    ActiveSheet.Name = PTName
    Sheets(PTName).Select
    ActiveWorkbook.PivotCaches.Create(SourceType:=xlDatabase, SourceData:= _
        SourceSheet & "!R1C1:" & EndPoint, Version:=8).CreatePivotTable _
        TableDestination:=PTName & "!R3C1", TableName:=PTName, DefaultVersion _
        :=8
    Cells(3, 1).Select
    With ActiveSheet.PivotTables(PTName)
        .ColumnGrand = False
        .RowGrand = False
    End With
    ActiveSheet.PivotTables(PTName).RepeatAllLabels 2
    
    '2. Put Province in Rows
    With ActiveSheet.PivotTables(PTName).PivotFields("Province")
        .Orientation = xlRowField
        .Position = 1
    End With
    
    '3. Put Years in Value
    For Yr = YrList(0) To YrList(1)
        ActiveSheet.PivotTables(PTName).AddDataField ActiveSheet.PivotTables( _
        PTName).PivotFields(CStr(Yr)), "Sum of " & Yr, xlSum
    Next Yr
    
    '4. Put Factory into Columns
    With ActiveSheet.PivotTables(PTName).PivotFields("Factory")
        .Orientation = xlColumnField
        '.Position = 1
    End With
    
    
    '4. Put Product into Filters
    With ActiveSheet.PivotTables(PTName).PivotFields("Product")
        .Orientation = xlPageField
        .Position = 1
    End With
    
    '5. Show Report Filter Pages if more than one product
    If UBound(ProdList) - LBound(ProdList) + 1 > 1 Then
        ActiveSheet.PivotTables(PTName).ShowPages PageField:="Product"
    End If
        
End Sub

Sub CopyPivot(SheetName, Color1, Color2)
    
    SheetList = Array("ICF", "OCF", "OCP", "OVF", "OVP")
    
    'DESCRIPTION: Subroutine for Copying Pivot Table
    'INPUT: Name of SheetName
    
    'All Products Sheets
    Application.DisplayAlerts = False
    
    'Copy
    Sheets("Pivot").Cells(3, 1).CurrentRegion.Copy
    
    'And Paste
    Sheets.Add.Name = SheetName
    Cells(1, 1).PasteSpecial
    
    If Right(SheetName, 1) = "P" Then
        Rows(1).Delete
    End If
    
    Range("A1").Select
    
    'Change Tab Color
    ActiveSheet.Tab.Color = Color1
    
    'Delete Pivot Sheets
    Sheets("Pivot").Delete
        
    'Single Product sheet
    
    If UBound(ProdList) - LBound(ProdList) + 1 > 1 Then
        For Each Prod In ProdList
        
            On Error GoTo NextProd
        
                'Copy
                Sheets(Prod).Cells(3, 1).CurrentRegion.Copy
                
                'Create New Sheet After the Current Sheet
                Sheets.Add After:=Worksheets(Prod)
                ActiveSheet.Name = SheetName & " - " & Prod
                
                'Paste
                Cells(1, 1).PasteSpecial
                
                If Right(SheetName, 1) = "P" Then
                    Rows(1).Delete
                End If
                
                Sheets(SheetName & " - " & Prod).Select
                Range("A1").Select
                
                'Change Tab Color
                ActiveSheet.Tab.Color = Color2
                
                
                'Delete Pivot Sheets
                Sheets(Prod).Delete
                
NextProd:
            Resume NextProd1
            
NextProd1:
            
        Next Prod
        
    End If
    
    Application.DisplayAlerts = True
    
End Sub

Sub Format()

    'DESCRIPTION: Subroutine to format sheet after postprocessing

    For WSInd = 5 To Worksheets.Count
    
        Worksheets(WSInd).Select
        ActiveSheet.Range("A1").CurrentRegion.Select
        With Selection
            .HorizontalAlignment = xlCenter
            .VerticalAlignment = xlCenter
            .Borders.LineStyle = xlContinuous
            .Columns.AutoFit
            .NumberFormat = "#,##0"
            
        End With
            
    Range("A1").Select
        
    Next WSInd

        
End Sub

Sub PostProcess()

    'DESCRIPTION: All processing here
    
    'Get preliminary info
    Call GetInfo

    'ICF
    Call CreatePivot1("Inbound Cost Per Factory")
    Call CopyPivot("ICF", RGB(255, 255, 255), RGB(128, 128, 128))

    'OCF
    Call CreatePivot1("Outbound Cost Per Customer")
    Call CopyPivot("OCF", RGB(255, 0, 0), RGB(255, 192, 0))
    
    'OCP
    Call CreatePivot2("Outbound Cost Per Customer")
    Call CopyPivot("OCP", RGB(255, 255, 0), RGB(0, 176, 80))
    
    'OVF
    Call CreatePivot1("Outbound Volume Per Customer")
    Call CopyPivot("OVF", RGB(0, 176, 240), RGB(0, 112, 192))
    
    'OVP
    Call CreatePivot2("Outbound Volume Per Customer")
    Call CopyPivot("OVP", RGB(0, 32, 96), RGB(112, 48, 160))
    
    'Delete Starters Worksheets
    'Worksheets("Outbound Volume Per Customer").Delete
    'Worksheets("Outbound Cost Per Customer").Delete
    'Worksheets("Inbound Cost Per Factory").Delete
    'Worksheets("Product List").Delete
    
    'Move Starters Worksheets
    Worksheets("Outbound Volume Per Customer").Move Before:=Worksheets(1)
    Worksheets("Outbound Cost Per Customer").Move Before:=Worksheets(1)
    Worksheets("Inbound Cost Per Factory").Move Before:=Worksheets(1)
    Worksheets("Product List").Move Before:=Worksheets(1)
    
    'Formatting
    Call Format
    
    MsgBox "Post-Processing Completed Successfully!"
    
End Sub
