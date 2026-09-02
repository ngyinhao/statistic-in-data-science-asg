# Helper script path resolved from the wrong working directory

## Context and symptom

During the 2026-09-02 IEEE reference rebuild, the command ran from `Assignment Report/` but used the repository-root-relative path `.agent-workflow/template-distill/group-report/build_ieee_reference.py`. Python therefore reported that the helper file did not exist.

## Impact and cause

The reference rebuild did not run, so a subsequent Pandoc command would have continued using the previous reference. The cause was a mismatch between the command working directory and the helper path's assumed base directory.

## Resolution and prevention

Invoke repository workflow helpers with an absolute path, or run them from the repository root. Keep content conversion commands scoped to `Assignment Report/` only when their resource paths depend on that directory.
