import SwiftUI
import SwiftData

struct CategorySettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TransactionCategory.name) private var categories: [TransactionCategory]
    
    @State private var showingAddCategory = false
    
    var body: some View {
        List {
            ForEach(categories) { category in
                HStack(spacing: 16) {
                    let catColor = Color(hex: category.colorHex) ?? AppTheme.primary
                    Image(systemName: category.iconName)
                        .font(.system(size: 20))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(catColor)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading) {
                        Text(category.name)
                            .font(.headline)
                        Text(category.type == .income ? "Pemasukan" : "Pengeluaran")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    if category.isDefault {
                        Text("Bawaan")
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Capsule())
                    }
                }
                .swipeActions(edge: .trailing) {
                    if !category.isDefault {
                        Button(role: .destructive) {
                            modelContext.delete(category)
                        } label: {
                            Label("Hapus", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle("Kategori")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddCategory = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        // Minimal implementation for Add Category Sheet
        .sheet(isPresented: $showingAddCategory) {
            AddCategoryView()
        }
    }
}

struct AddCategoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var type: TransactionType = .expense
    @State private var colorHex = "#34C759"
    @State private var iconName = "star.fill"
    
    let icons = ["star.fill", "heart.fill", "car.fill", "house.fill", "cart.fill", "bag.fill", "gamecontroller.fill", "book.fill", "graduationcap.fill", "airplane", "cross.case.fill"]
    let colors = ["#FF3B30", "#FF9500", "#FFCC00", "#34C759", "#00C7BE", "#32ADE6", "#007AFF", "#5856D6", "#AF52DE", "#FF2D55"]
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Nama Kategori", text: $name)
                
                Picker("Tipe", selection: $type) {
                    Text("Pengeluaran").tag(TransactionType.expense)
                    Text("Pemasukan").tag(TransactionType.income)
                }
                .pickerStyle(.segmented)
                
                Section(header: Text("Warna")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(colors, id: \.self) { hex in
                                Circle()
                                    .fill(Color(hex: hex) ?? .gray)
                                    .frame(width: 40, height: 40)
                                    .overlay(Circle().stroke(Color.black, lineWidth: colorHex == hex ? 2 : 0))
                                    .onTapGesture { colorHex = hex }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section(header: Text("Ikon")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(icons, id: \.self) { icon in
                                Image(systemName: icon)
                                    .font(.title)
                                    .frame(width: 44, height: 44)
                                    .background(iconName == icon ? Color(hex: colorHex)?.opacity(0.3) : Color.clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .onTapGesture { iconName = icon }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Kategori Baru")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Simpan") {
                        let newCat = TransactionCategory(name: name, iconName: iconName, colorHex: colorHex, type: type, isDefault: false)
                        modelContext.insert(newCat)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}
