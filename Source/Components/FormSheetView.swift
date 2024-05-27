import SwiftUI

struct FormSheetView: View {
    
    var id: String
    var title: String
    var artistName: String
    var artworkURL: URL?
    
    @State private var appear = false
    @State private var formData = ""
    @State private var textEditorHeight: CGFloat = 40

    var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack {
                    AsyncImage(url: artworkURL) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width * 0.8, height: 350)
                                .cornerRadius(20)
                                .scaleEffect(calculateScaleEffect(totalHeight: geometry.size.height))
                                .opacity(appear ? 1 : 0)
                                .blur(radius: appear ? 0 : 16)
                                .rotationEffect(.degrees(appear ? -2 : 0))
                                .animation(.spring(response: 1, dampingFraction: 1, blendDuration: 1), value: calculateScaleEffect(totalHeight: geometry.size.height))
                                .onAppear {
                                    withAnimation(.spring(response: 1, dampingFraction: 1, blendDuration: 1)) {
                                        appear = true
                                    }
                                }
                        case .empty, .failure:
                            Color.clear
                                .frame(width: geometry.size.width * 0.8, height: 350)
                                .cornerRadius(20)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .shadow(color: Color.black.opacity(0.8), radius: 20, x: 10, y: 10)
                }
                .frame(height: 350 * calculateScaleEffect(totalHeight: geometry.size.height))
                .padding(.bottom, 32)
                .animation(.spring(response: 1, dampingFraction: 1, blendDuration: 1), value: textEditorHeight)
                
                Text(artistName)
                    .font(.system(size: 13))
                    .foregroundColor(Color.white.opacity(0.75))
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color.white.opacity(0.75))
                
                CustomTextEditor(text: $formData)
                    .padding(.horizontal, 24)
                    .frame(minHeight: 40, maxHeight: .infinity)
                    .font(.system(size: 15))
                    .onChange(of: formData) { _ in
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0.5)) {
                            updateTextEditorHeight()
                        }
                    }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .padding(.top, 40)
    }
    
    private func updateTextEditorHeight() {
        let size = CGSize(width: UIScreen.main.bounds.width - 64, height: .infinity)
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]
        let estimatedHeight = NSString(string: formData).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil).height
        textEditorHeight = max(40, estimatedHeight)
    }

    private func calculateScaleEffect(totalHeight: CGFloat) -> CGFloat {
        let initialHeight: CGFloat = 350
        let minHeight: CGFloat = 100
        let availableHeight = totalHeight - textEditorHeight - 200
        let imageHeight = min(initialHeight, max(minHeight, availableHeight))
        return imageHeight / initialHeight
    }
}
