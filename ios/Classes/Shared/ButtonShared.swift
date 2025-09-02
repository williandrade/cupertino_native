import SwiftUI

struct CupertinoButtonView: View {
  @ObservedObject var model: ButtonModel

  var body: some View {
    Button(action: {
      model.onPress()
    }) {
      Text(model.title)
        .frame(maxWidth: .infinity)
    }
    .disabled(!model.enabled)
  }
}

class ButtonModel: ObservableObject {
  @Published var title: String
  @Published var enabled: Bool
  var onPress: () -> Void

  init(title: String, enabled: Bool, onPress: @escaping () -> Void) {
    self.title = title
    self.enabled = enabled
    self.onPress = onPress
  }
}

