import SwiftUI

struct InfoView: View {

    let content: Content

    var body: some View {
        VStack(spacing: 16) {
            content.asset
            Text(content.title)
                .multilineTextAlignment(.center)
                .avenirNextFont(.bold, size: 25)
                .foregroundColor(.textColor)
            Text(content.description)
                .multilineTextAlignment(.center)
                .avenirNextFont(.regular, size: 18)
                .foregroundColor(.textColor)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(8)
        }
        .padding()
    }
}

extension InfoView {

    enum Content: String {

        case failure
        case empty
        case idle
        case loading

        fileprivate var title: String {
            "content.info.\(rawValue).title".localized
        }

        fileprivate var description: String {
            "content.info.\(rawValue).description".localized
        }

        fileprivate var asset: some View {
            HStack {
                Spacer()
                switch self {
                case .failure:
                    Image(systemName: "xmark.icloud.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.red)
                        .font(.system(size: 100))
                case .empty:
                    Image(systemName: "list.bullet.rectangle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.accentColor)
                        .font(.system(size: 100))
                case .idle:
                    Image(systemName: "sun.dust.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color.accentColor, .yellow, Color.accentColor.opacity(0.5))
                        .font(.system(size: 100))
                case .loading:
                    Image(systemName: "waveform.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.accentColor)
                        .font(.system(size: 100))
                }
                Spacer()
            }
        }
    }
}

struct InfoTemplateView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView(content: .failure)
    }
}
