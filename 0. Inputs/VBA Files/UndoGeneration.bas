Attribute VB_Name = "UndoGeneration"
Public Sub UndoGeneration()

    'DESCRIPTION: Subroutine to delete all the template sheets
    
    If MsgBox("Undoing the template generation?", vbOKCancel, "Undo Generation") = vbOK Then
        'Delete all other sheet beside Product List and Factory List
        Application.DisplayAlerts = False
    
        For Each Worksheet In Worksheets
            If (Worksheet.Name <> "Product List") And (Worksheet.Name <> "Factory List") And (Worksheet.Name <> "Customer List") Then
                Worksheet.Delete
            End If
        Next Worksheet
        Application.DisplayAlerts = True
        
        MsgBox "All templates sheets deleted successfully!"
    End If
    
End Sub
