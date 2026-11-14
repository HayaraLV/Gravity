import SpriteKit
import CoreMotion

class GameScene: SKScene {

    // MARK: - Настройки (легко менять)

    let iconSize: CGFloat = 60
    let iconCornerRadius: CGFloat = 13.5
    let gridColumns = 4
    let horizontalSpacing: CGFloat = 27
    let verticalSpacing: CGFloat = 32
    let topSafeArea: CGFloat = 54          // место под статус-бар
    let gridTopOffset: CGFloat = 28        // отступ от статус-бара до первой иконки
    let dockHeight: CGFloat = 94

    // Порог тряски (чем меньше — тем чувствительнее)
    let shakeThreshold: Double = 2.7

    // Основные иконки (белые)
    let mainIconNames = [
        "FaceTime", "Календарь", "Фото", "Камера",
        "Почта", "Заметки", "Часы", "Карты",
        "Видео", "App Store", "Игры", "Здоровье",
        "Wallet", "Настройки", "Файлы", "Погода"
    ]

    // Иконки в Dock
    let dockIconNames = ["Телефон", "Safari", "Сообщения", "Музыка"]

    // MARK: - Состояние

    private var icons: [SKNode] = []
    private var dockIcons: [SKNode] = []
    private var gridPositions: [CGPoint] = []
    private var dockPositions: [CGPoint] = []
    private var isPhysicsMode = false
    private var lastShakeTime: TimeInterval = 0
    private let motionManager = CMMotionManager()

    private var statusBarNode: SKNode!
    private var dockBackground: SKShapeNode!

    // MARK: - Жизненный цикл

    override func didMove(to view: SKView) {
        // Классический светлый фон iOS
        backgroundColor = SKColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)

        physicsWorld.gravity = .zero
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)

        createStatusBar()
        createDockBackground()
        createMainIcons()
        createDockIcons()
        layoutEverything(animated: false)
        startMotionUpdates()
    }

    // MARK: - Статус-бар (статичный)

    private func createStatusBar() {
        statusBarNode = SKNode()
        statusBarNode.zPosition = 100
        statusBarNode.name = "statusBar"

        // Время (слева)
        let timeLabel = SKLabelNode(text: "19:36")
        timeLabel.fontName = "HelveticaNeue-Bold"
        timeLabel.fontSize = 16
        timeLabel.fontColor = .black
        timeLabel.horizontalAlignmentMode = .left
        timeLabel.verticalAlignmentMode = .center
        timeLabel.position = CGPoint(x: 28, y: 0)
        timeLabel.name = "time"
        statusBarNode.addChild(timeLabel)

        // Правая группа: Wi-Fi + Батарея
        let rightGroup = SKNode()
        rightGroup.name = "rightStatus"

        // Wi-Fi (простые дуги)
        let wifi = makeWifiIcon()
        wifi.position = CGPoint(x: -52, y: 0)
        rightGroup.addChild(wifi)

        // Батарея
        let battery = makeBatteryIcon()
        battery.position = CGPoint(x: 0, y: 0)
        rightGroup.addChild(battery)

        statusBarNode.addChild(rightGroup)
        addChild(statusBarNode)
    }

    private func makeWifiIcon() -> SKNode {
        let node = SKNode()

        // Три дуги
        for i in 0..<3 {
            let radius: CGFloat = 4.5 + CGFloat(i) * 3.2
            let arc = SKShapeNode(circleOfRadius: radius)
            arc.strokeColor = .black
            arc.fillColor = .clear
            arc.lineWidth = 1.6
            arc.path = UIBezierPath(
                arcCenter: .zero,
                radius: radius,
                startAngle: .pi * 0.25,
                endAngle: .pi * 0.75,
                clockwise: false
            ).cgPath
            node.addChild(arc)
        }

        // Точка внизу
        let dot = SKShapeNode(circleOfRadius: 1.4)
        dot.fillColor = .black
        dot.strokeColor = .clear
        dot.position = CGPoint(x: 0, y: -1)
        node.addChild(dot)

        return node
    }

    private func makeBatteryIcon() -> SKNode {
        let node = SKNode()

        // Корпус
        let body = SKShapeNode(rectOf: CGSize(width: 25, height: 12), cornerRadius: 2.5)
        body.strokeColor = .black
        body.fillColor = .clear
        body.lineWidth = 1.5
        node.addChild(body)

        // Заполнение
        let fill = SKShapeNode(rectOf: CGSize(width: 17, height: 8), cornerRadius: 1.5)
        fill.fillColor = .black
        fill.strokeColor = .clear
        fill.position = CGPoint(x: -2.5, y: 0)
        node.addChild(fill)

        // Кончик справа
        let tip = SKShapeNode(rectOf: CGSize(width: 2, height: 5), cornerRadius: 1)
        tip.fillColor = .black
        tip.strokeColor = .clear
        tip.position = CGPoint(x: 14.5, y: 0)
        node.addChild(tip)

        return node
    }

    // MARK: - Dock

    private func createDockBackground() {
        let width = size.width - 36
        dockBackground = SKShapeNode(rectOf: CGSize(width: width, height: 86), cornerRadius: 28)
        dockBackground.fillColor = UIColor.white.withAlphaComponent(0.55)
        dockBackground.strokeColor = UIColor.white.withAlphaComponent(0.35)
        dockBackground.lineWidth = 0.5
        dockBackground.zPosition = 5
        dockBackground.name = "dockBackground"
        addChild(dockBackground)
    }

    // MARK: - Иконки

    private func createMainIcons() {
        for (index, name) in mainIconNames.enumerated() {
            let icon = makeWhiteIcon(name: name, index: index)
            icons.append(icon)
            addChild(icon)
        }
    }

    private func createDockIcons() {
        for (index, name) in dockIconNames.enumerated() {
            let icon = makeWhiteIcon(name: name, index: 100 + index)
            dockIcons.append(icon)
            addChild(icon)
        }
    }

    private func makeWhiteIcon(name: String, index: Int) -> SKNode {
        let container = SKNode()
        container.name = "icon_\(index)"

        // Белый скруглённый квадрат
        let shape = SKShapeNode(rectOf: CGSize(width: iconSize, height: iconSize), cornerRadius: iconCornerRadius)
        shape.fillColor = .white
        shape.strokeColor = UIColor.black.withAlphaComponent(0.06)
        shape.lineWidth = 0.5
        shape.name = "background"

        // Лёгкая тень
        let shadow = SKShapeNode(rectOf: CGSize(width: iconSize, height: iconSize), cornerRadius: iconCornerRadius)
        shadow.fillColor = UIColor.black.withAlphaComponent(0.12)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 0, y: -2.5)
        shadow.zPosition = -1

        // Подпись
        let label = SKLabelNode(text: name)
        label.fontName = "HelveticaNeue"
        label.fontSize = 11
        label.fontColor = UIColor(white: 0.15, alpha: 1)
        label.verticalAlignmentMode = .top
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: -iconSize/2 - 15)
        label.name = "label"

        container.addChild(shadow)
        container.addChild(shape)
        container.addChild(label)

        // Физика
        container.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: iconSize * 0.92, height: iconSize * 0.92))
        container.physicsBody?.isDynamic = false
        container.physicsBody?.restitution = 0.32
        container.physicsBody?.friction = 0.45
        container.physicsBody?.linearDamping = 0.55
        container.physicsBody?.angularDamping = 0.75
        container.physicsBody?.mass = 0.28

        return container
    }

    // MARK: - Раскладка

    private func calculatePositions() {
        gridPositions.removeAll()
        dockPositions.removeAll()

        // --- Основные иконки ---
        let totalGridWidth = CGFloat(gridColumns) * iconSize + CGFloat(gridColumns - 1) * horizontalSpacing
        let startX = (size.width - totalGridWidth) / 2 + iconSize / 2
        let startY = size.height - topSafeArea - gridTopOffset - iconSize / 2

        for i in 0..<icons.count {
            let col = i % gridColumns
            let row = i / gridColumns
            let x = startX + CGFloat(col) * (iconSize + horizontalSpacing)
            let y = startY - CGFloat(row) * (iconSize + verticalSpacing + 18)
            gridPositions.append(CGPoint(x: x, y: y))
        }

        // --- Dock ---
        let dockCount = dockIcons.count
        let dockSpacing: CGFloat = 28
        let dockTotalWidth = CGFloat(dockCount) * iconSize + CGFloat(dockCount - 1) * dockSpacing
        let dockStartX = (size.width - dockTotalWidth) / 2 + iconSize / 2
        let dockY = dockHeight / 2 + 12

        for i in 0..<dockCount {
            let x = dockStartX + CGFloat(i) * (iconSize + dockSpacing)
            dockPositions.append(CGPoint(x: x, y: dockY))
        }
    }

    private func layoutEverything(animated: Bool) {
        calculatePositions()

        // Статус-бар
        statusBarNode.position = CGPoint(x: 0, y: size.height - topSafeArea / 2 - 4)
        if let right = statusBarNode.childNode(withName: "rightStatus") {
            right.position = CGPoint(x: size.width - 38, y: 0)
        }

        // Фон Dock
        dockBackground.position = CGPoint(x: size.width / 2, y: dockHeight / 2 + 6)
        dockBackground.path = UIBezierPath(
            roundedRect: CGRect(x: -((size.width - 36)/2), y: -43, width: size.width - 36, height: 86),
            cornerRadius: 28
        ).cgPath

        // Основные иконки
        for (i, icon) in icons.enumerated() {
            guard i < gridPositions.count else { break }
            placeIcon(icon, at: gridPositions[i], animated: animated)
        }

        // Dock-иконки
        for (i, icon) in dockIcons.enumerated() {
            guard i < dockPositions.count else { break }
            placeIcon(icon, at: dockPositions[i], animated: animated)
        }

        isPhysicsMode = false
        physicsWorld.gravity = .zero
    }

    private func placeIcon(_ icon: SKNode, at point: CGPoint, animated: Bool) {
        icon.physicsBody?.isDynamic = false
        icon.physicsBody?.velocity = .zero
        icon.physicsBody?.angularVelocity = 0
        icon.zRotation = 0

        if animated {
            let move = SKAction.move(to: point, duration: 0.55)
            move.timingMode = .easeInEaseOut
            let rotate = SKAction.rotate(toAngle: 0, duration: 0.4)
            icon.run(SKAction.group([move, rotate]))
        } else {
            icon.position = point
        }
    }

    // MARK: - Физика

    private func enablePhysicsMode() {
        isPhysicsMode = true

        let allIcons = icons + dockIcons
        for icon in allIcons {
            icon.physicsBody?.isDynamic = true
            let dx = CGFloat.random(in: -70...70)
            let dy = CGFloat.random(in: 30...140)
            icon.physicsBody?.applyImpulse(CGVector(dx: dx, dy: dy))
        }
    }

    // MARK: - Датчики

    private func startMotionUpdates() {
        guard motionManager.isAccelerometerAvailable else { return }

        motionManager.accelerometerUpdateInterval = 1.0 / 60.0
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let data = data else { return }

            let a = data.acceleration
            let magnitude = sqrt(a.x * a.x + a.y * a.y + a.z * a.z)

            let now = Date().timeIntervalSince1970
            if magnitude > self.shakeThreshold && (now - self.lastShakeTime) > 0.8 {
                self.lastShakeTime = now
                self.handleShake()
            }

            if self.isPhysicsMode {
                let gx = CGFloat(a.x) * 9.8 * 1.4
                let gy = CGFloat(a.y) * 9.8 * 1.4
                self.physicsWorld.gravity = CGVector(dx: gx, dy: gy)
            }
        }
    }

    private func handleShake() {
        if isPhysicsMode {
            layoutEverything(animated: true)
        } else {
            enablePhysicsMode()
        }
    }

    // MARK: - Изменение размера

    override func didChangeSize(_ oldSize: CGSize) {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        if !isPhysicsMode {
            layoutEverything(animated: false)
        } else {
            // Просто обновляем статус-бар и dock-фон
            statusBarNode.position = CGPoint(x: 0, y: size.height - topSafeArea / 2 - 4)
            if let right = statusBarNode.childNode(withName: "rightStatus") {
                right.position = CGPoint(x: size.width - 38, y: 0)
            }
            dockBackground.position = CGPoint(x: size.width / 2, y: dockHeight / 2 + 6)
        }
    }

    deinit {
        motionManager.stopAccelerometerUpdates()
    }
}
