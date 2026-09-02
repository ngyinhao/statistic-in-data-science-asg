param(
    [Parameter(Mandatory = $true)][string]$Source,
    [Parameter(Mandatory = $true)][string]$Output
)

$sourcePath = (Get-Item -LiteralPath $Source).FullName
$outputPath = [System.IO.Path]::GetFullPath($Output)
$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 0

try {
    $sourceDoc = $word.Documents.Open($sourcePath, $false, $true)
    try {
        $sourceDoc.SaveAs2($outputPath, 12)
    }
    finally {
        $sourceDoc.Close($false)
    }

    $doc = $word.Documents.Open($outputPath, $false, $false)
    try {
        foreach ($section in $doc.Sections) {
            $section.PageSetup.SectionStart = 0
            $section.PageSetup.TextColumns.SetCount(2)
            $section.PageSetup.TextColumns.Spacing = 18
            $section.PageSetup.DifferentFirstPageHeaderFooter = 0
            $section.PageSetup.OddAndEvenPagesHeaderFooter = 0
            foreach ($header in $section.Headers) {
                if ($header.Exists) {
                    $header.Range.Text = ''
                }
            }
            foreach ($footer in $section.Footers) {
                if ($footer.Exists) {
                    $footer.Range.Text = ''
                }
            }
        }

        $normal = $doc.Styles.Item('Normal')
        $normal.Font.Name = 'Times New Roman'
        $normal.Font.Size = 10
        $normal.Font.Bold = 0
        $normal.Font.Italic = 0
        $normal.ParagraphFormat.Alignment = 3
        $normal.ParagraphFormat.FirstLineIndent = 14.4
        $normal.ParagraphFormat.SpaceBefore = 0
        $normal.ParagraphFormat.SpaceAfter = 6

        $title = $doc.Styles.Item('Title')
        $title.Font.Name = 'Times New Roman'
        $title.Font.Size = 24
        $title.Font.Bold = 0
        $title.ParagraphFormat.Alignment = 1
        $title.ParagraphFormat.SpaceBefore = 0
        $title.ParagraphFormat.SpaceAfter = 6

        $caption = $doc.Styles.Item('Caption')
        $caption.Font.Name = 'Times New Roman'
        $caption.Font.Size = 8
        $caption.Font.Bold = 0
        $caption.Font.Italic = 0
        $caption.ParagraphFormat.Alignment = 3
        $caption.ParagraphFormat.SpaceBefore = 4
        $caption.ParagraphFormat.SpaceAfter = 10

        try {
            $sourceCode = $doc.Styles.Item('Source Code')
        }
        catch {
            $sourceCode = $doc.Styles.Add('Source Code', 1)
        }
        $sourceCode.Font.Name = 'Courier New'
        $sourceCode.Font.Size = 7
        $sourceCode.Font.Bold = 0
        $sourceCode.Font.Italic = 0
        $sourceCode.ParagraphFormat.Alignment = 0
        $sourceCode.ParagraphFormat.FirstLineIndent = 0
        $sourceCode.ParagraphFormat.LeftIndent = 0
        $sourceCode.ParagraphFormat.RightIndent = 0
        $sourceCode.ParagraphFormat.SpaceBefore = 0
        $sourceCode.ParagraphFormat.SpaceAfter = 0

        try {
            $tableStyle = $doc.Styles.Item('Table')
        }
        catch {
            $tableStyle = $doc.Styles.Add('Table', 3)
        }
        $tableStyle.Font.Name = 'Times New Roman'
        $tableStyle.Font.Size = 8
        $tableStyle.ParagraphFormat.FirstLineIndent = 0
        $tableStyle.ParagraphFormat.SpaceBefore = 0
        $tableStyle.ParagraphFormat.SpaceAfter = 0

        try {
            $bibliography = $doc.Styles.Item('Bibliography')
        }
        catch {
            $bibliography = $doc.Styles.Add('Bibliography', 1)
        }
        $bibliography.Font.Name = 'Times New Roman'
        $bibliography.Font.Size = 8
        $bibliography.Font.Bold = 0
        $bibliography.Font.Italic = 0
        $bibliography.ParagraphFormat.Alignment = 3
        $bibliography.ParagraphFormat.FirstLineIndent = 0
        $bibliography.ParagraphFormat.SpaceBefore = 0
        $bibliography.ParagraphFormat.SpaceAfter = 2.5

        $doc.Save()
    }
    finally {
        $doc.Close($false)
    }
}
finally {
    $word.Quit()
    [void][System.Runtime.InteropServices.Marshal]::FinalReleaseComObject($word)
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
}
