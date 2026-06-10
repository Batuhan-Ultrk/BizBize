import SwiftUI
import UIKit

struct SplashView: View {
    @EnvironmentObject private var appSession: AppSession

    let onFinished: () -> Void

    var body: some View {
        splashContent
        .task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            appSession.restoreSession()
            withAnimation(.easeInOut(duration: 0.35)) {
                onFinished()
            }
        }
    }

    private var splashContent: some View {
        ZStack {
            Color.bizBizeScreenBackground
                .ignoresSafeArea()

            if let image = splashImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .ignoresSafeArea()
            }
        }
        .statusBarHidden(true)
    }

    private var splashImage: UIImage? {
        guard let path = Bundle.main.path(forResource: "SplashPreview", ofType: "png") else {
            return nil
        }

        return UIImage(contentsOfFile: path)
    }
}
