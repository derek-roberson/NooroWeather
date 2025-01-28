import SwiftUI

struct SearchBarView: View {
    @Binding var text: String
    @FocusState.Binding var isFocused: Bool
    var onClear: (() -> Void)?

    var body: some View {
        HStack {
            TextField("Location Search", text: $text)
                .focused($isFocused)
                .foregroundStyle(Color.primary)
                .overlay(alignment: .trailing) {
                    Image(systemName: "xmark.circle.fill")
                        .padding()
                        .offset(x: 10)
                        .foregroundStyle(Color.primary)
                        .opacity(text.isEmpty ? 0.0 : 1.0)
                        .onTapGesture {
                            text = ""
                            isFocused = false
                            onClear?()
                        }
                }

            Image(systemName: "magnifyingglass")
                .foregroundStyle(
                    text.isEmpty ? Color.primary : Color.secondary
                )

        }
        .font(.headline)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.2))
                .shadow(
                    color: .black.opacity(0.1),
                    radius: 10
                )
        )
    }
}
