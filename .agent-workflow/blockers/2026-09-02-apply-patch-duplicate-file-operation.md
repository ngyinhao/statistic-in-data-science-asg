# `apply_patch` rejected repeated update declarations for one file

## Context and intended action

While updating the individual-report plan, one patch contained three separate `*** Update File` declarations targeting the same Markdown file. The intent was to modify several distant sections in a single operation.

## Symptom and impact

The patch failed verification with `invalid patch: multiple operations target ...`. None of the intended plan edits in that patch were applied.

## Cause

This `apply_patch` implementation accepts multiple hunks for a file under one `*** Update File` declaration, but rejects repeated operations targeting the same path within a single patch.

## Workaround and prevention

Consolidate every hunk for a given file beneath one `*** Update File` declaration. Use separate declarations only for different files. The consolidated retry applied successfully.
