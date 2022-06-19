Attribute VB_Name = "ReinitializeWorkbook"
Sub DeleteAll()

    'DESCRIPTION: Subroutine to delete all worksheets
    
    'Create a blank sheet at the beginning
    'Note that VBA index from 1
    Sheets.Add
    ActiveSheet.Move Before:=Worksheets(1)
    
    'Delete all other sheet
    Application.DisplayAlerts = False
    For SheetIndex = 2 To Worksheets.Count

        Sheets(2).Delete
            
    Next SheetIndex
    Application.DisplayAlerts = True

End Sub

Sub BuildProductList()

    'DESCRIPTION: Subroutine to create Product List sheet
    ActiveSheet.Name = "Product List"
    
    Range("A1").Select
    
    With Selection
        .Value = "PRODUCT"
        .Font.Bold = True
        .HorizontalAlignment = xlCenter
        .VerticalAlignment = xlCenter
        .Columns.AutoFit
        
    End With

End Sub

Sub BuildFactoryList()

    'DESCRIPTION: Subroutine to create Factory List sheet
    
    ActiveSheet.Name = "Factory List"
    
    Range("A1").Select
    
    With Selection
        .Value = "FACTORY"
        .Font.Bold = True
        .HorizontalAlignment = xlCenter
        .VerticalAlignment = xlCenter
        .Columns.AutoFit
        
    End With

End Sub

Sub BuildCustomerList()

    'DESCRIPTION: Subroutine to create Customer List sheet
    
    ActiveSheet.Name = "Customer List"
    
    Range("A1").Value = "Customer ID"
        
    Range("B1").Value = "Province"
        
    Range("C1").Value = "Sales Product"
        
    Range("A1").CurrentRegion.Select
    
    With Selection
        .Font.Bold = True
        .HorizontalAlignment = xlCenter
        .VerticalAlignment = xlCenter
        .Columns.AutoFit
        .Borders.LineStyle = xlContinuous
        
    End With
    
End Sub

Sub ReinitializeWorkbook()

    'DESCRIPTION: Subroutine to reinitialize worksheet to original
    If MsgBox("Reinitializing the workbook (returning to a blank workbook)?", vbOKCancel, "Reinitialize Workbook") = 1 Then
        Call DeleteAll
        Call BuildProductList
        
        Sheets.Add After:=Sheets("Product List")
        Call BuildFactoryList
        
        Sheets.Add After:=Sheets("Factory List")
        Call BuildCustomerList
        
        MsgBox "Workbook reinitialized sucessfully"
    End If

End Sub

