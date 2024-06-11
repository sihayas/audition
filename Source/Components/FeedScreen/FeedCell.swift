//
//  FeedCell.swift
//  vaela
//
//  Created by decoherence on 4/30/24.
//

import UIKit
import SwiftUI

class FeedCell: UICollectionViewCell {


    // MARK: Artifact UI Properties
    
    // Art card
    private var hostRatingView: UIHostingController<RatingView>?
    
    // Transition/Text card
    private let cardView = UIView()
    
    // MARK: Wisp UI Properties
    private var wispView = UIView()
    private var artistNameLabel = UILabel()
    private var dot1View = UIView()
    private var dot2View = UIView()
    
    // MARK: Universal UI Properties
    private var artContainerView = UIView()
    private let artImageView = ImageView()
    private var labelsStackView = UIStackView()
    private let nameLabel = UILabel()
    private var textLabel = UILabel()
    private var avatarContainerView = UIView()
    private let avatarImageView = ImageView()
    private var usernameLabel = UILabel()
    private var dialView: DialView?
    
    
    
    // MARK: Data
    
    private var entry: APIEntry?
    
    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Data

    func setup(with entry: APIEntry) {
        // Make sure apple sound data and entry are available
        self.entry = entry
        guard let appleData = entry.sound.appleData else {
            return
        }
        
        guard let artworkUrl = URL(string: appleData.artworkUrl.replacingOccurrences(of: "{w}", with: "\(600)").replacingOccurrences(of: "{h}", with: "\(600)")) else { return }
        artImageView.setImage(from: artworkUrl)

        
        guard let avatarUrl = URL(string: entry.author.image) else { return }
        avatarImageView.setImage(from: avatarUrl)

        
        if(entry.rating == nil){
            setupView()
            setupAvatar()
            setupWisp(artistText: appleData.artistName, nameText: appleData.name, username: entry.author.username, text: entry.text)
        } else {
            setupView()
            setupAvatar()
            setupArtifact(nameText: appleData.name, rating: entry.rating!, username: entry.author.username, text: entry.text)
        }
        setupGesture()
    }

}


// MARK: - Reuse

extension FeedCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        // Artifact
        hostRatingView?.view.removeFromSuperview()
        hostRatingView = nil
        cardView.removeFromSuperview()
        
        // Wisp
        wispView.removeFromSuperview()
        artistNameLabel.text = ""
        dot1View.removeFromSuperview()
        dot2View.removeFromSuperview()
        
        // Universal
        labelsStackView.removeFromSuperview()
        nameLabel.text = ""
        artImageView.image = nil
        artContainerView.removeFromSuperview()
        textLabel.text = ""
        avatarContainerView.removeFromSuperview()
        avatarImageView.image = nil
        usernameLabel.text = ""
        dialView = nil
        dialView?.removeFromSuperview()
        
        // Reset constraints
        NSLayoutConstraint.deactivate(artContainerView.constraints)
        NSLayoutConstraint.deactivate(artImageView.constraints)
    }
}

// MARK: - Setup

extension FeedCell {
    private func setupView() {
        contentView.backgroundColor = .clear
    }
    
    // MARK: Wisp UI
    private func setupWisp(artistText: String, nameText: String, username: String, text: String) {
        wispView = UIView()
        wispView.then {
            $0.backgroundColor = .black
            $0.layer.cornerRadius = 18
            $0.layer.cornerCurve = .continuous
            $0.layer.masksToBounds = true
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOffset = CGSize(width: 0, height: 4)
            $0.layer.shadowOpacity = 0.25
            $0.layer.shadowRadius = 16
            contentView.addSubview($0)
        }.layout {
            $0.bottom == contentView.bottomAnchor - 12
            $0.trailing == contentView.trailingAnchor
            $0.width == 330
            $0.height <= contentView.heightAnchor
        }
        
        textLabel = UILabel()
        textLabel.then {
            $0.text = text
            $0.textColor = .white.withAlphaComponent(0.75)
            $0.font = UIFont.systemFont(ofSize: 15)
            $0.numberOfLines = 10
            $0.textAlignment = .left
            $0.translatesAutoresizingMaskIntoConstraints = false
            wispView.addSubview($0)
        }.layout {
            $0.leading == wispView.leadingAnchor + 16
            $0.trailing == wispView.trailingAnchor - 16
            $0.top == wispView.topAnchor + 8
            $0.bottom <= wispView.bottomAnchor - 8
        }
        
        artContainerView = UIView()
        artContainerView.then {
            $0.backgroundColor = .black
            $0.layer.cornerRadius = 18
            $0.layer.cornerCurve = .continuous
            $0.layer.masksToBounds = false
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOffset = CGSize(width: 0, height: 4)
            $0.layer.shadowOpacity = 0.25
            $0.layer.shadowRadius = 16
            contentView.addSubview($0)
        }.layout {
            $0.leading == contentView.trailingAnchor - 330
            $0.bottom == wispView.topAnchor - 4
            $0.width == 120
            $0.height == 120
        }
        
        artImageView.then {
            $0.layer.allowsEdgeAntialiasing = true
            $0.layer.cornerCurve = .continuous
            $0.layer.masksToBounds = true
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.transform = CGAffineTransform(rotationAngle: -4 * .pi / 180)
            $0.layer.cornerRadius = 12
            artContainerView.addSubview($0)
        }.layout {
            $0.centerX == artContainerView.centerXAnchor
            $0.centerY == artContainerView.centerYAnchor
            $0.width == 88
            $0.height == 88
        }
        
        labelsStackView = UIStackView()
        labelsStackView.then {
            $0.axis = .vertical
            $0.alignment = .leading
            $0.translatesAutoresizingMaskIntoConstraints = false
            artContainerView.addSubview($0)
        }.layout {
            $0.bottom == artContainerView.bottomAnchor - 12
            $0.leading == artContainerView.trailingAnchor + 12
        }
        
        nameLabel.do {
            $0.font = .systemFont(ofSize: 15, weight: .bold)
            $0.textColor = UIColor.white.withAlphaComponent(0.75)
            $0.text = nameText
            $0.numberOfLines = 2
            $0.textAlignment = .left
            labelsStackView.addArrangedSubview($0)
        }
        
        artistNameLabel.do {
            $0.font = .systemFont(ofSize: 13, weight: .medium)
            $0.textColor = UIColor.white.withAlphaComponent(0.75)
            $0.text = artistText
            $0.numberOfLines = 1
            $0.textAlignment = .left
            labelsStackView.addArrangedSubview($0)
        }
        
        dot1View = UIView()
        dot1View.then {
            $0.backgroundColor = wispView.backgroundColor
            $0.layer.cornerRadius = 4
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }.layout {
            $0.width == 8
            $0.height == 8
            $0.bottom == wispView.bottomAnchor
            $0.leading == wispView.leadingAnchor
        }
        
        dot2View = UIView()
        dot2View.then {
            $0.backgroundColor = wispView.backgroundColor
            $0.layer.cornerRadius = 2
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }.layout {
            $0.width == 4
            $0.height == 4
            $0.trailing == wispView.leadingAnchor
            $0.bottom == wispView.bottomAnchor + 4
        }
    }
    
    
    // MARK: Artifact UI
    private func setupArtifact(nameText: String, rating: Double, username: String, text: String) {
        artContainerView = UIView()
        artContainerView.then {
            $0.backgroundColor = .black
            $0.layer.cornerRadius = 32
            $0.layer.cornerCurve = .continuous
            $0.layer.masksToBounds = false
            $0.transform = CGAffineTransform(rotationAngle: -4 * .pi / 180)
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOffset = CGSize(width: 0, height: 6)
            $0.layer.shadowOpacity = 0.3
            $0.layer.shadowRadius = 12
            contentView.addSubview($0)
        }.layout {
            $0.leading == contentView.leadingAnchor - 114
            $0.bottom == contentView.bottomAnchor - 24
            $0.width == 216
            $0.height == 304
        }

        artImageView.then {
            $0.layer.cornerRadius = 32
            $0.layer.cornerCurve = .continuous
            $0.layer.masksToBounds = true
            $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            $0.translatesAutoresizingMaskIntoConstraints = false
            artContainerView.addSubview($0)
        }.layout {
            $0.trailing == artContainerView.trailingAnchor
            $0.top == artContainerView.topAnchor
            $0.width == 216
            $0.height == 216
        }

        labelsStackView = UIStackView()
        labelsStackView.then {
            $0.axis = .vertical
            $0.alignment = .leading
            $0.spacing = 12
            $0.translatesAutoresizingMaskIntoConstraints = false
            artContainerView.addSubview($0)
        }.layout {
            $0.bottom == artContainerView.bottomAnchor - 24
            $0.leading == artContainerView.leadingAnchor + 24
        }

        nameLabel.do {
            $0.font = .systemFont(ofSize: 15, weight: .bold)
            $0.textColor = UIColor.white.withAlphaComponent(0.75)
            $0.text = nameText
            $0.numberOfLines = 2
            $0.textAlignment = .left
            labelsStackView.addArrangedSubview($0)
        }

        let rating = RatingView(rating: rating)
        hostRatingView = UIHostingController(rootView: rating)
        guard let ratingView = hostRatingView?.view else { return }
        ratingView.then {
            $0.backgroundColor = .clear
            $0.translatesAutoresizingMaskIntoConstraints = false
            labelsStackView.addArrangedSubview($0)
        }.layout {
            $0.width == 20
            $0.height == 20
        }

        usernameLabel = UILabel()
        usernameLabel.then {
            $0.textColor = UIColor.white.withAlphaComponent(0.75)
            $0.text = username
            $0.font = UIFont.systemFont(ofSize: 13, weight: .medium)
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }.layout {
            $0.bottom == contentView.bottomAnchor
            $0.leading == artContainerView.leadingAnchor + 24
        }

        cardView.do {
            contentView.fillWith($0)
            contentView.addSubview($0)
            $0.contentMode = .scaleAspectFill
            $0.layer.masksToBounds = false
            $0.backgroundColor = .black
            $0.layer.cornerRadius = 32
            $0.layer.cornerCurve = .continuous
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOffset = CGSize(width: 0, height: 8)
            $0.layer.shadowOpacity = 0.4
            $0.layer.shadowRadius = 24
        }

        textLabel = UILabel()
        textLabel.then {
            $0.text = text
            $0.textColor = .white.withAlphaComponent(0.75)
            $0.font = UIFont.systemFont(ofSize: 15)
            $0.numberOfLines = 0
            $0.textAlignment = .left
            $0.translatesAutoresizingMaskIntoConstraints = false
            cardView.addSubview($0)
        }.layout {
            $0.leading == cardView.leadingAnchor + 24
            $0.trailing == cardView.trailingAnchor - 24
            $0.top == cardView.topAnchor + 16
            $0.bottom <= cardView.bottomAnchor - 16
        }
    }
    
    private func setupAvatar() {
        let avatarSize: CGFloat = 40
        let tap = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))

        avatarImageView.do {
            $0.layer.cornerRadius = avatarSize / 2
            $0.clipsToBounds = true
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        avatarContainerView = UIView()
        avatarContainerView.then {
            $0.layer.cornerRadius = avatarSize / 2
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOffset = CGSize(width: 0, height: 2)
            $0.layer.shadowOpacity = 0.1
            $0.layer.shadowRadius = 8
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.addSubview(avatarImageView)
            $0.addGestureRecognizer(tap)
            addSubview($0)
        }.layout {
            $0.trailing == contentView.leadingAnchor - 130
            $0.bottom == bottomAnchor
            $0.width == 40
            $0.height == 40
        }

        avatarImageView.layout {
            $0.centerX == avatarContainerView.centerXAnchor
            $0.centerY == avatarContainerView.centerYAnchor
            $0.width == avatarSize
            $0.height == avatarSize
        }
    }
    
    @objc func avatarTapped() {
        NavigationManager.shared.navigateToUserScreen(withUserData: entry?.author)
    }
}

// MARK: Gestures

extension FeedCell {
    // Allow gestures outside of the cell bounds
    override func hitTest(_ point: CGPoint, with e: UIEvent?) -> UIView? {
        if let result = super.hitTest(point, with:e) {
            return result
        }
        for sub in self.subviews.reversed() {
            let pt = self.convert(point, to:sub)
            if let result = sub.hitTest(pt, with:e) {
                return result
            }
        }
        return nil
    }
    
    private func setupGesture() {
        // dial
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.25
        addGestureRecognizer(longPressGesture)
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: contentView)
        switch gesture.state {
        case .began:
            showDial(at: location)
        case .changed:
            dialView?.updateSelectedAction(at: gesture.location(in: dialView))
        case .ended:
            if let selectedAction = dialView?.selectedAction {
                performAction(selectedAction)
            }
            hideDial()
        default:
            break
        }
    }

    private func animateDialIn(_ dial: DialView) {
        dial.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        dial.alpha = 0
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.75,
                       initialSpringVelocity: 1,
                       options: .curveEaseInOut,
                       animations: {
                           dial.transform = .identity
                           dial.alpha = 1
                       },
                       completion: nil)
    }

    private func showDial(at point: CGPoint) {
        let dial = DialView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        dial.center = point
        contentView.addSubview(dial)
        dialView = dial
        animateDialIn(dial)
    }

    private func animateDialOut(_ dial: DialView, completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0,
                       options: .curveEaseInOut,
                       animations: {
                           dial.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                           dial.alpha = 0
                       },
                       completion: { _ in
                           completion()
                       })
    }

    private func hideDial() {
        if let dial = dialView {
            animateDialOut(dial) {
                dial.removeFromSuperview()
                self.dialView = nil
            }
        }
    }

    
    private func performAction(_ action: Int) {
        switch action {
        case 0:
            print("Create action selected")
        case 1:
            print("Go action selected")
        case 2:
            print("Heart action selected")
            commitHeartAction()
        default:
            break
        }
    }
    
    private func commitHeartAction() {
        guard let entry = entry else { return }
        
        PostAPI.createAction(authorId: entry.author.id, actionType: "heart", sourceId: entry.id, sourceType: "entry", soundId: entry.sound.id) { result in
            switch result {
            case .success:
                print("Heart action committed successfully")
            case .failure(let error):
                print("Error committing heart action: \(error)")
            }
        }
    }
}
