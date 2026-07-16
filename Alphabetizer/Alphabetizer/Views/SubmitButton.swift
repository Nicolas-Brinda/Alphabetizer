import SwiftUI


struct SubmitButton: View {
    @Environment(Alphabetizer.self) private var alphabetizer

    var body: some View {
        Button {
            alphabetizer.submit()
        } label: {
            Image(systemName: "play.circle")
                .font(.system(size: 24))
                .foregroundStyle(Color.white)
                .padding(12)
                .background(
                    Color.purple
                        .clipShape(Circle())
                        .opacity(isEnabled ? 1.0 : 0.5)
                )
        }
        .animation(.default, value: isEnabled)
        .disabled(!isEnabled)
    }


    var isEnabled: Bool {
        alphabetizer.message == .instructions
    }
}


#Preview {
    SubmitButton()
        .environment(Alphabetizer())
}
