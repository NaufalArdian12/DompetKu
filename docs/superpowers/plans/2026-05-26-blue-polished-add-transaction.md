# Blue Polished Add Transaction Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Dompetku's add transaction form faster to use and visually consistent with a full blue style.

**Architecture:** Keep the existing SwiftUI and SwiftData flow. Add a small reusable blue surface style to `AppTheme`, then refactor `AddTransactionView` into focused computed views and validation helpers without changing `Transaction` persistence.

**Tech Stack:** SwiftUI, SwiftData, iOS 17+, macOS 14+, Xcode project `Dompetku.xcodeproj`.

---

## File Structure

- Modify `App/Theme/AppTheme.swift`: add reusable blue-tinted background and gradient tokens for the polished add form.
- Modify `App/Views/AddTransactionView.swift`: add focus state, amount validation helpers, compact blue UI sections, and a sticky save button.
- Do not modify `App/Models/Transaction.swift`: the model and stored fields remain unchanged.
- Do not modify dashboard, analytics, or transaction list files in this iteration.

## Task 1: Add Blue Form Theme Tokens

**Files:**
- Modify: `App/Theme/AppTheme.swift`

- [ ] **Step 1: Add blue form styling tokens**

In `App/Theme/AppTheme.swift`, add these properties after `bgCard`:

```swift
    static let bgBlueSoft = Color(red: 0.941, green: 0.965, blue: 1.0) // #F0F6FF
```

Add this gradient after `primaryGradient`:

```swift
    static let addTransactionGradient = LinearGradient(
        colors: [primary, income],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
```

- [ ] **Step 2: Build to catch syntax issues**

Run:

```bash
xcodebuild -scheme Dompetku -destination "generic/platform=iOS Simulator" -configuration Debug build
```

Expected: build succeeds. If the local sandbox blocks DerivedData or Xcode cache writes, rerun with approved unsandboxed execution.

- [ ] **Step 3: Commit if Git is available**

Run:

```bash
git rev-parse --show-toplevel
```

Expected in this workspace today: `fatal: not a git repository`. If Git is available in the execution environment, commit:

```bash
git add App/Theme/AppTheme.swift
git commit -m "style: add blue transaction form theme tokens"
```

## Task 2: Add Amount Validation And Focus Helpers

**Files:**
- Modify: `App/Views/AddTransactionView.swift`

- [ ] **Step 1: Add focus state and computed validation helpers**

In `AddTransactionView`, add this state below `@State private var note = ""`:

```swift
    @FocusState private var isAmountFocused: Bool
```

Add these computed properties below `var categories: [String]`:

```swift
    private var parsedAmount: Double? {
        let unformattedString = amountString.replacingOccurrences(of: ".", with: "")
        return Double(unformattedString)
    }

    private var canSave: Bool {
        guard let parsedAmount else { return false }
        return parsedAmount > 0
    }
```

- [ ] **Step 2: Update save logic to use the helper**

Replace the first two lines of `saveTransaction()`:

```swift
        // Strip the dots before converting to Double
        let unformattedString = amountString.replacingOccurrences(of: ".", with: "")
        guard let amount = Double(unformattedString), amount > 0 else { return }
```

with:

```swift
        guard let amount = parsedAmount, amount > 0 else { return }
```

- [ ] **Step 3: Build to verify helper names and Swift syntax**

Run:

```bash
xcodebuild -scheme Dompetku -destination "generic/platform=iOS Simulator" -configuration Debug build
```

Expected: build succeeds.

- [ ] **Step 4: Commit if Git is available**

If Git is available:

```bash
git add App/Views/AddTransactionView.swift
git commit -m "refactor: add add transaction validation helpers"
```

## Task 3: Refactor AddTransactionView Into Focused Blue Sections

**Files:**
- Modify: `App/Views/AddTransactionView.swift`

- [ ] **Step 1: Replace the current `body` content**

Replace the whole `var body: some View` implementation with:

```swift
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        amountEntrySection
                        transactionTypeSection
                        categorySection
                        detailsSection
                    }
                    .padding(.vertical, 20)
                    .padding(.bottom, 96)
                }
                .scrollContentBackground(.hidden)

                saveButtonSection
            }
            .background(AppTheme.bgMain)
            .navigationTitle("Tambah Catatan")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                isAmountFocused = true
            }
        }
    }
```

- [ ] **Step 2: Add the amount entry section**

Add this computed view below `body`:

```swift
    private var amountEntrySection: some View {
        VStack(spacing: 10) {
            Text("Jumlah Uang")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.82))

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("Rp")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white.opacity(0.92))

                TextField("0", text: $amountString)
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    #if os(iOS)
                    .keyboardType(.numberPad)
                    #endif
                    .focused($isAmountFocused)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.white)
                    .tint(.white)
                    .onChange(of: amountString) { oldValue, newValue in
                        formatAmount(oldValue: oldValue, newValue: newValue)
                    }
            }

            Text("Masukkan nominal transaksi")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.72))
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .background(AppTheme.addTransactionGradient)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: AppTheme.primary.opacity(0.18), radius: 18, x: 0, y: 10)
        .padding(.horizontal)
    }
```

- [ ] **Step 3: Add amount formatting helper**

Move the existing inline `onChange` formatting logic into this private method below the computed views:

```swift
    private func formatAmount(oldValue: String, newValue: String) {
        let unformatted = newValue.replacingOccurrences(of: ".", with: "")

        if let number = Int(unformatted) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.groupingSeparator = "."
            formatter.maximumFractionDigits = 0

            if let formatted = formatter.string(from: NSNumber(value: number)), amountString != formatted {
                amountString = formatted
            }
        } else if unformatted.isEmpty {
            if amountString != "" {
                amountString = ""
            }
        } else {
            amountString = oldValue
        }
    }
```

- [ ] **Step 4: Add the type picker section**

Add this computed view:

```swift
    private var transactionTypeSection: some View {
        Picker("Tipe", selection: $selectedType) {
            Text("Keluar").tag(TransactionType.expense)
            Text("Masuk").tag(TransactionType.income)
        }
        .pickerStyle(.segmented)
        .padding(4)
        .background(AppTheme.bgBlueSoft)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal)
        .onChange(of: selectedType) { _, newValue in
            selectedCategory = newValue == .expense ? "Makanan" : "Gaji"
        }
    }
```

- [ ] **Step 5: Add the compact category section**

Add this computed view:

```swift
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Kategori")
                .font(.headline)
                .foregroundStyle(.black)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 10)], spacing: 10) {
                ForEach(categories, id: \.self) { category in
                    categoryButton(for: category)
                }
            }
        }
        .padding(.horizontal)
    }
```

Add this helper view:

```swift
    private func categoryButton(for category: String) -> some View {
        let isSelected = selectedCategory == category

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                selectedCategory = category
            }
        } label: {
            VStack(spacing: 8) {
                Image(systemName: AppTheme.categoryIcon(for: category))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : AppTheme.primary)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(isSelected ? AppTheme.primary : AppTheme.bgBlueSoft)
                    )

                Text(category)
                    .font(.caption.weight(isSelected ? .bold : .medium))
                    .foregroundStyle(isSelected ? AppTheme.primary : .secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(AppTheme.bgCard)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? AppTheme.primary : Color.clear, lineWidth: 1.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: isSelected ? AppTheme.primary.opacity(0.12) : .black.opacity(0.03), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
```

- [ ] **Step 6: Add secondary details section**

Add this computed view:

```swift
    private var detailsSection: some View {
        VStack(spacing: 16) {
            DatePicker("Tanggal", selection: $date, displayedComponents: [.date])
                .datePickerStyle(.compact)

            Divider()

            HStack {
                Image(systemName: "note.text")
                    .foregroundStyle(AppTheme.primary)
                TextField("Catatan tambahan...", text: $note)
            }
        }
        .padding()
        .background(AppTheme.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
```

- [ ] **Step 7: Add sticky save button section**

Add this computed view:

```swift
    private var saveButtonSection: some View {
        Button(action: saveTransaction) {
            Text("Simpan Transaksi")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(canSave ? AppTheme.primary : Color.gray.opacity(0.35))
                )
        }
        .disabled(!canSave)
        .padding(.horizontal)
        .padding(.top, 12)
        .padding(.bottom, 16)
        .background(.ultraThinMaterial)
    }
```

- [ ] **Step 8: Build after the refactor**

Run:

```bash
xcodebuild -scheme Dompetku -destination "generic/platform=iOS Simulator" -configuration Debug build
```

Expected: build succeeds. Fix any compile errors from misplaced methods or duplicate helper names before continuing.

- [ ] **Step 9: Commit if Git is available**

If Git is available:

```bash
git add App/Views/AddTransactionView.swift
git commit -m "feat: polish add transaction form"
```

## Task 4: Manual Verification

**Files:**
- Verify: `App/Views/AddTransactionView.swift`

- [ ] **Step 1: Run the app in an iPhone simulator**

Run from Xcode or use:

```bash
xcodebuild -scheme Dompetku -destination "platform=iOS Simulator,name=iPhone 16" -configuration Debug build
```

Expected: app builds for the selected simulator destination.

- [ ] **Step 2: Verify amount focus and formatting**

Open the add transaction sheet.

Expected:

- The amount field is focused automatically on iOS.
- Typing `25000` displays `25.000`.
- Typing non-numeric characters is rejected by the existing formatter behavior.

- [ ] **Step 3: Verify type and category behavior**

Change type from `Keluar` to `Masuk`.

Expected:

- The selected category resets from `Makanan` to `Gaji`.
- Changing back to `Keluar` resets the category to `Makanan`.
- Selected category has a clear blue selected state.

- [ ] **Step 4: Verify save validation**

Leave amount empty or enter `0`.

Expected:

- `Simpan Transaksi` is disabled.
- Tapping it does not insert a transaction.

Enter a valid amount and save.

Expected:

- Transaction is inserted into SwiftData.
- Sheet dismisses.
- New transaction appears in dashboard/history.

- [ ] **Step 5: Verify small-screen usability**

Run on a smaller simulator such as iPhone SE if available.

Expected:

- No text overlaps.
- Category labels fit or scale down.
- Sticky save button remains reachable.

## Self-Review Checklist

- Spec coverage: amount focus, blue styling, compact categories, secondary details, sticky save, validation, and unchanged model are all covered.
- Placeholder scan: no `TBD`, `TODO`, or unspecified implementation steps.
- Type consistency: helpers use `parsedAmount`, `canSave`, `formatAmount(oldValue:newValue:)`, and existing `TransactionType` cases consistently.
