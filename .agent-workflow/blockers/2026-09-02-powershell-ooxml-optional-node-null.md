# PowerShell OOXML inspection assumed an optional node existed

## Context and intended action

While distilling the two-column Word reference on 2026-09-02, a read-only PowerShell script inspected each `w:sectPr` node in `word/document.xml`.

## Observable symptom

The script raised `You cannot call a method on a null-valued expression` while reading the section break type.

## Impact

The first section inventory stopped before reporting its column and margin properties.

## Confirmed cause

`w:type` is optional. Its absence means Word's default next-page section break, but the script called `GetAttribute()` without checking for a null node.

## Troubleshooting and result

The inspection was rerun with a null check. Both sections were then inventoried successfully: the cover is one column and the body is two columns with a 300 DXA gutter.

## Workaround and prevention

Treat optional OOXML nodes defensively. Check for null and apply the schema default before reading attributes, especially for `w:type`, `w:cols`, header/footer references, and pagination settings.

