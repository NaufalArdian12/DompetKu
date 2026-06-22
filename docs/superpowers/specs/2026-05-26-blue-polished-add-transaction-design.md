# Blue Polished Add Transaction Design

## Context

Dompetku is a SwiftUI and SwiftData personal finance app. It already supports adding transactions, viewing a dashboard, searching/filtering transaction history, and seeing category analytics.

The selected improvement is focused on daily usability: make transaction input faster and visually more consistent with the app's blue brand direction. Template transactions are intentionally out of scope for this iteration.

## Goals

- Make the existing add transaction flow faster for daily use.
- Keep the form familiar so the change is low-risk.
- Use a full blue visual style for both income and expense states.
- Make invalid input clearer by disabling save until the amount is valid.
- Keep the existing `Transaction` model and SwiftData persistence unchanged.

## Non-Goals

- No transaction templates in this iteration.
- No custom categories.
- No dashboard redesign.
- No analytics or data model changes.
- No import/export, backup, or sync.

## User Experience

When the add transaction sheet opens, the amount field should be the visual and interaction focus. The numeric keyboard should appear immediately on iOS so the user can start typing without tapping first.

The amount card uses the app's primary blue styling. Type selection remains available, but its labels can be shortened to `Keluar` and `Masuk` for faster scanning. Both selected states use blue styling rather than orange/red for expense.

Categories remain as the existing fixed category lists, but selected category styling becomes simpler and more consistent: blue border or blue fill treatment rather than category-specific colors dominating the form.

Date and note remain available, but visually secondary. They should not compete with amount, type, category, and save.

The save button should be easy to reach. It should stay visible near the bottom of the sheet instead of requiring the user to scroll to the end of the content. The button is disabled while the amount is empty or zero.

## UI Structure

`AddTransactionView` remains the owner of the add flow.

Recommended layout:

1. Navigation title and cancel action remain.
2. Amount entry card at the top, blue gradient or solid blue surface.
3. Type segmented control below the amount card.
4. Compact category grid.
5. Secondary detail card for date and note.
6. Sticky bottom save button.

The form should continue using existing app theme primitives from `AppTheme` where practical. New blue variants should be added only if they improve clarity and reuse.

## Data Flow

The existing local state remains:

- `amountString`
- `selectedType`
- `selectedCategory`
- `date`
- `note`

Amount formatting still strips grouping separators before conversion. Saving still creates a `Transaction` and inserts it into `modelContext`.

The save action should be guarded by a computed amount validity helper. The same helper should drive the disabled state of the save button.

## Error Handling And Validation

Invalid amount behavior should be explicit:

- Empty amount disables save.
- Zero amount disables save.
- Non-numeric input is rejected or reverted as it is today.

No alert is required for invalid amount if the disabled state is visually clear.

## Accessibility

The selected type and selected category states should remain visible through more than color alone where possible, such as stronger border, weight, or selected background.

The save button disabled state must have enough contrast against the background.

## Testing

Manual verification should cover:

- Opening the add sheet focuses the amount field on iOS.
- Typing amount formats with Indonesian grouping separators.
- Switching transaction type updates category defaults correctly.
- Selected category is visually clear.
- Save is disabled for empty and zero amount.
- Saving a valid transaction inserts it and dismisses the sheet.
- The form remains usable on small iPhone simulator sizes.

Build verification:

- Run an Xcode build for the Dompetku scheme after implementation.

## Scope Boundaries

Primary files expected to change:

- `App/Views/AddTransactionView.swift`
- `App/Theme/AppTheme.swift`, only if a reusable blue styling helper is needed.

Avoid changing `Transaction`, dashboard, analytics, or transaction list behavior during this iteration.
