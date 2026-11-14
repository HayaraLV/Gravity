import SwiftUI
import SpriteKit

struct ContentView: View {
    var body: some View {
        GeometryReader { geo in
            SpriteView(scene: makeScene(size: geo.size))
                .frame(width: geo.size.width, height: geo.size.height)
        }
        .ignoresSafeArea()
        .statusBarHidden(true)
    }

    private func makeScene(size: CGSize) -> GameScene {
        let scene = GameScene(size: size)
        scene.scaleMode = .resizeFill
        return scene
    }
}

#Preview {
    ContentView()
}
