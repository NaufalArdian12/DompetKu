import SwiftUI

struct SwipeToDeleteModifier: ViewModifier {
    var action: () -> Void
    @State private var offset: CGFloat = 0
    @State private var isSwiped: Bool = false
    
    func body(content: Content) -> some View {
        ZStack(alignment: .trailing) {
            // Delete Background and Icon
            Color.red
            
            Image(systemName: "trash")
                .font(.title3)
                .foregroundStyle(.white)
                .padding(.trailing, 24)
            
            // Content
            content
                .background(AppTheme.bgCard)
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.width < 0 {
                                // Swiping left
                                offset = value.translation.width
                            } else if isSwiped && value.translation.width > 0 {
                                // Swiping right from already swiped state
                                offset = -80 + value.translation.width
                            }
                        }
                        .onEnded { value in
                            withAnimation(.spring()) {
                                if value.translation.width < -50 {
                                    offset = -80
                                    isSwiped = true
                                } else {
                                    offset = 0
                                    isSwiped = false
                                }
                            }
                        }
                )
                .onTapGesture {
                    if isSwiped {
                        withAnimation(.spring()) {
                            offset = 0
                            isSwiped = false
                        }
                    }
                }
            
            // Invisible button over the trash icon area when swiped
            if isSwiped {
                Button(action: {
                    withAnimation {
                        offset = 0
                        isSwiped = false
                    }
                    action()
                }) {
                    Color.clear
                }
                .frame(width: 80)
            }
        }
        .clipped()
    }
}

extension View {
    func swipeToDelete(action: @escaping () -> Void) -> some View {
        self.modifier(SwipeToDeleteModifier(action: action))
    }
}
