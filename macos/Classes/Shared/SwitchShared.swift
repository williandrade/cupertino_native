import SwiftUI

struct CupertinoSwitchView: View {
  @ObservedObject var model: SwitchModel

  var body: some View {
    Toggle("", isOn: $model.value)
      .labelsHidden()
      .disabled(!model.enabled)
      .onChange(of: model.value) { newValue in
        model.onChange(newValue)
      }
  }
}

class SwitchModel: ObservableObject {
  @Published var value: Bool
  @Published var enabled: Bool
  var onChange: (Bool) -> Void

  init(value: Bool, enabled: Bool, onChange: @escaping (Bool) -> Void) {
    self.value = value
    self.enabled = enabled
    self.onChange = onChange
  }
}

