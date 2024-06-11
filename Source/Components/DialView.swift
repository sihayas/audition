import UIKit

class DialView: UIView {

    var selectedAction: Int? = nil
    
    // Define actions with names and icons
    private let actions: [(name: String, icon: UIImage)] = [
        ("Plus", UIImage(systemName: "plus")!.resized(to: CGSize(width: 16, height: 16))!),
        ("Expand", UIImage(systemName: "arrow.up.right")!.resized(to: CGSize(width: 16, height: 16))!),
        ("Heart", UIImage(systemName: "heart.fill")!.resized(to: CGSize(width: 16, height: 16))!)
    ]
    private var actionButtons: [UIButton] = []
    private let arcLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDial()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupDial()
    }

    // Setup dial buttons and arc background
    private func setupDial() {
        self.backgroundColor = UIColor.clear
        
        // Configure arc background
        arcLayer.fillColor = UIColor.clear.cgColor
        arcLayer.strokeColor = UIColor.black.cgColor
        arcLayer.lineWidth = 44
        arcLayer.lineCap = .round
        self.layer.addSublayer(arcLayer)
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 5, height: 5)
        self.layer.shadowRadius = 10
        
        // Create buttons for each action
        for i in 0..<actions.count {
            let button = UIButton(type: .system)
            button.setImage(actions[i].icon, for: .normal)
            button.tintColor = .white
            button.frame.size = CGSize(width: 32, height: 32)
            button.layer.cornerRadius = 16
            button.backgroundColor = UIColor.clear
            button.addTarget(self, action: #selector(actionButtonTapped(_:)), for: .touchUpInside)
            self.addSubview(button)
            actionButtons.append(button)
        }
    }
    
    // Adjust button positions when view layout changes
    override func layoutSubviews() {
        super.layoutSubviews()
        updateButtonPositions()
    }
    
    // Position buttons along the top-left arc and update arc background
    private func updateButtonPositions() {
        let totalAngle: CGFloat = 90
        let startAngle: CGFloat = -180
        let radius: CGFloat = 100
        let angleIncrement = totalAngle / CGFloat(actions.count - 1)
        
        // Offset to position the arc closer to the touch point
        let offsetX: CGFloat = -self.bounds.width / 8
        let offsetY: CGFloat = -self.bounds.height / 8
        
        // Path for the arc background
        let arcPath = UIBezierPath()
        arcPath.addArc(withCenter: CGPoint(x: self.bounds.midX + offsetX, y: self.bounds.midY + offsetY),
                       radius: radius,
                       startAngle: startAngle * .pi / 180,
                       endAngle: (startAngle + totalAngle) * .pi / 180,
                       clockwise: true)
        arcLayer.path = arcPath.cgPath
        
        // Calculate and set button positions
        for i in 0..<actionButtons.count {
            let angle = startAngle + CGFloat(i) * angleIncrement
            let angleRadians = angle * .pi / 180
            let button = actionButtons[i]
            button.center = CGPoint(x: self.bounds.midX + offsetX + cos(angleRadians) * radius,
                                    y: self.bounds.midY + offsetY + sin(angleRadians) * radius)
        }
    }
    
    // Update selected action based on touch point and scale the closest button
    func updateSelectedAction(at point: CGPoint) {
        let maxScale: CGFloat = 1.5
        let minScale: CGFloat = 1.0
        let maxDistance: CGFloat = 150.0
        
        var closestButton: UIButton? = nil
        var closestDistance: CGFloat = .greatestFiniteMagnitude
        
        // Find the closest button
        for button in actionButtons {
            let buttonCenter = button.center
            let distance = hypot(point.x - buttonCenter.x, point.y - buttonCenter.y)
            
            if distance < closestDistance {
                closestDistance = distance
                closestButton = button
            }
        }
        
        // Scale the closest button
        for button in actionButtons {
            let distance = hypot(point.x - button.center.x, point.y - button.center.y)
            let scale = max(minScale, min(maxScale, maxScale - (distance / maxDistance) * (maxScale - minScale)))
            UIView.animate(withDuration: 0.2) {
                button.transform = (button == closestButton) ? CGAffineTransform(scaleX: scale, y: scale) : .identity
            }
        }
        
        if let closestButton = closestButton, let index = actionButtons.firstIndex(of: closestButton) {
            selectedAction = index
        } else {
            selectedAction = nil
        }
        
        updateButtonColors()
    }
    
    // Handle button tap action
    @objc private func actionButtonTapped(_ sender: UIButton) {
        if let index = actionButtons.firstIndex(of: sender) {
            selectedAction = index
            performAction(index)
        }
    }
    
    // Update button colors based on selection
    private func updateButtonColors() {
        for (index, button) in actionButtons.enumerated() {
            button.tintColor = (index == selectedAction) ? .white : .white.withAlphaComponent(0.5)
        }
    }
    
    // Perform action based on selected button
    private func performAction(_ action: Int) {
        switch action {
        case 0:
            print("Hide action selected")
        case 1:
            print("Add action selected")
        case 2:
            print("Heart action selected")
        default:
            break
        }
    }
}
