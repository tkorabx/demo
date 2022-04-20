import SwiftUI

struct ListRow: View {

    let key: String
    let value: String
    let isAccented: Bool

    init(key: String, value: String, isAccented: Bool = false) {
        self.key = key
        self.value = value
        self.isAccented = isAccented
    }

    var body: some View {
        HStack {
            Text(key.localized)
                .avenirNextFont(.regular, size: 15)
                .foregroundColor(.textColor)
            Spacer()
            Text(value)
                .avenirNextFont(.bold, size: 16)
                .foregroundColor(isAccented ? .accentColor : .textColor)
        }
    }
}

struct ListRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ListRow(key: "Key", value: "Value")
            ListRow(key: "Key", value: "Value")
            ListRow(key: "Key", value: "Value")
        }
    }
}
