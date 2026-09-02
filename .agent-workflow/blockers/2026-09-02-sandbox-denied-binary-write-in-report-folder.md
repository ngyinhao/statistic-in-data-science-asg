# Sandbox denied DOCX writes in the report folder

## Context and intended action

On 2026-09-02, Pandoc 3.10 was used to convert `Assignment Report/Group_Report.md` to `Assignment Report/Group_Report.docx`.

## Observable symptom

Pandoc failed with `withBinaryFile: permission denied` when the output path was inside `Assignment Report/`. Generating the same DOCX in the user's temporary directory succeeded, but `Copy-Item` from the temporary directory into `Assignment Report/` also failed with `Access to the path ... is denied`.

## Impact

Normal sandboxed commands could read all report sources and generate the binary artifact in a temporary directory, but could not place the final DOCX in the intended repository folder.

## Likely cause

The command sandbox's effective write policy for binary files did not match the repository ACL shown by `Get-Acl`; the directory reported Modify access, yet both Pandoc and PowerShell copy operations were denied. No pre-existing target file or Microsoft Word lock was found.

## Troubleshooting and result

- Confirmed the target DOCX did not already exist.
- Confirmed no `WINWORD` process was reported.
- Confirmed the directory ACL reports Modify access for the sandbox user/group.
- Confirmed Pandoc successfully created a non-empty DOCX under the task-local temporary directory.
- Confirmed copying that DOCX back to the repository was denied.
- During a later regeneration pass, Pandoc rewrote the first DOCX but failed on the second with the same permission error. A `WINWORD.EXE` process was confirmed. The user later clarified that the DOCX had been open in Word; closing it released the lock and the remaining conversions succeeded.
- During two-column QA on 2026-09-02, sandboxed `New-Item` was also denied when creating a fresh render subdirectory under `.agent-workflow/template-distill/group-report/`, even though earlier workflow files in that tree were writable through `apply_patch` and the repository root is declared writable.
- During the final all-two-column regeneration on 2026-09-02, direct Pandoc overwrite of the existing `Group_Report.docx` again returned `withBinaryFile: permission denied` even after the user had closed the document. This recurrence requires checking both a lingering Word process/file handle and the known sandbox binary-write mismatch before retrying.
- During individual-report layout correction on 2026-09-02, a bundled-Python OOXML postprocessor successfully created a temporary DOCX beside the target but `os.replace()` was denied when replacing `Individual_Report_1_SARIMA_updated.docx`. The script removed its temporary file during cleanup, and no report was corrupted. This is the same binary replacement boundary and requires narrowly approved execution.
- Retrying that exact replacement with escalated permissions still returned `WinError 5`; no Word or LibreOffice process was present and the target was not read-only. The reliable recovery is therefore to write a new, versioned sibling output rather than replacing an existing generated DOCX.
- During the 2026-09-02 individual-title consistency update, all four current individual DOCX files had first been moved to explicitly named archive paths, so none of the intended output files existed. Even so, four direct Pandoc conversions into `Assignment Report/` each failed with `withBinaryFile: permission denied`. This confirms that the restriction can affect creation of new DOCX files in the folder and is not limited to overwriting an open or existing target.

## Workaround or remaining limitation

Run the narrowly scoped Pandoc conversion and copy operation with approved elevated sandbox permissions, targeting only the five named report DOCX files.
Before overwriting DOCX files, confirm that the target is not open in Word. Ask the user to close it or wait for the lock to clear, then retry.
For QA intermediates, prefer a task-specific directory under the permitted system temporary directory rather than creating new nested binary-output folders under `.agent-workflow`.

## Prevention

Align the workspace-write sandbox policy with the repository's effective ACL for generated binary artifacts, and add a small binary-write smoke test when setting up document-generation workspaces.
