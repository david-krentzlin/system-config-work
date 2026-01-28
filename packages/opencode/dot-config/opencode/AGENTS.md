# Contract
 
This document defines **binding rules for YOU** as an AI coding agent contributing to **New Work One**.
All rules are mandatory unless explicitly stated otherwise.

Normative keywords are used as defined:

* **MUST / SHALL** → mandatory
* **DO NOT / MUST NOT** → prohibited
* **DO** → required positive action


# Committing Changes

* Who commits: DON'T stage (DON'T git add) unless explicitly instructed. DON'T commit unless explicitly instructed. DO suggest a commit message when you finish, even if not instructed.
* When: Before reporting the task as complete to the user, suggest the commit message.
* What: Consider not what you remember, but EVERYTHING in the git diff and git diff --cached.

## Format:

**All commit messages you create must have the prefix `[AI]` to clearly denote, that this commit is from an agent.**

* **Format:** Use Conventional Commits.
* **Body:** Explanation if necessary (wrap at 72 chars).
  * Explain why this is the implementation, as opposed to other possible implementations.
  * DO include extra notes about breaking changes to the API if required
  * Skip the body entirely if it's rote, a duplication of the diff, or otherwise unhelpful.
  * DON'T list the files changed or the edits made in the body. Don't provide a bulleted list of changes. Use prose to explain the problem and the solution.
  * DON'T use markdown syntax (no backticks, no bolding, no lists, no links). The commit message must be plain text.
  
# Pull Requests

All pull-requests MUST be written with a human reviewer as the target audience.
This means that you have to make sure that the following holds true:

* The PR is focused and changes only what's strictly necessary to implement the change
* The PR contains tests that encode the intended semantics of the change
* The changes in the PR can be merged to the main branch without problems. If it is part of a bigger change, make sure that it can stand on its own, even if later changes will be delayed.
