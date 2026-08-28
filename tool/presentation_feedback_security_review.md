# Presentation feedback security review

Scope: `presentation_feedback/{feedbackId}` is written by the authenticated
owner of the referenced `presentations/{presentationId}` document and read only
by an administrator. A document contains a presentation ID, user ID, four
integer ratings (1–5), an optional note up to 1000 characters, and a server
timestamp.

The Flutter client creates records only after a user submits the feedback
dialog. The administrator queries the collection ordered by `submittedAt`
descending, limited to 300 records.

Attack review:

- Unauthenticated reads and writes are denied.
- Non-admin collection reads are denied, preventing feedback/note disclosure.
- A user cannot submit feedback for another user's presentation: the rule
  verifies the referenced presentation exists and has the current user's ID.
- Schema pollution, missing fields, wrong field types, ratings outside 1–5,
  overlong notes, and forged timestamps are denied by
  `isValidPresentationFeedback` plus the `request.time` check.
- User updates and deletes are denied, so an accepted record cannot be changed
  into an invalid one or replayed as an update.
- Admin read/update/delete access remains limited to the existing `isAdmin()`
  check.
