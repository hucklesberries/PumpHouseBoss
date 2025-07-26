# GitHub Copilot File Edit Policy

## Backup Policy for File Edits

**Effective July 25, 2025:**

Before making any changes to any file in this project, Copilot will:

1. Create a backup of the original file in the `.git-copilot` directory at the project root.
2. Name the backup with the original filename and a timestamp or unique identifier to avoid overwriting previous backups.
3. Only proceed with the edit if the backup is successfully created.

This policy is mandatory and is intended to prevent data loss and ensure that the user can always restore previous file states.

## Incident Note

This policy was instituted after a troubleshooting session in which file changes were made without proper backup, leading to user frustration and lost time. Copilot will never repeat this mistake.

---

**If you need to restore a file from backup, simply copy the desired version from `.git-copilot` back to its original location.**
