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
        wispView.do {
            $0.backgroundColor = .black
            $0.layer.cornerRadius = 18
            $0.layer.cornerCurve = .continuous
            $0.layer.masksToBounds = true
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOffset = CGSize(width: 0, height: 4)
            $0.layer.shadowOpacity = 0.25
            $0.layer.shadowRadius = 16
        }
        
        contentView.addSubview(wispView)
        wispView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            wispView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            wispView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            wispView.widthAnchor.constraint(equalToConstant: 330),
            wispView.heightAnchor.constraint(lessThanOrEqualTo: contentView.heightAnchor)
        ])
        
        textLabel = UILabel()
        textLabel.do {
            $0.text = text
            $0.textColor = .white.withAlphaComponent(0.75)
            $0.font = UIFont.systemFont(ofSize: 15)
            $0.numberOfLines = 10
            $0.textAlignment = .left
        }
        
        wispView.addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: wispView.leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: wispView.trailingAnchor, constant: -16),
            textLabel.topAnchor.constraint(equalTo: wispView.topAnchor, constant: 8),
            textLabel.bottomAnchor.constraint(lessThanOrEqualTo: wispView.bottomAnchor, constant: -8)
        ])
        
        // Art card, make sure its rotated to the left 4 deg
        artContainerView = UIView()
        artContainerView.do {
            $0.backgroundColor = .black
            $0.layer.cornerRadius = 18
            $0.layer.cornerCurve = .continuous
            $0.layer.masksToBounds = false
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOffset = CGSize(width: 0, height: 4)
            $0.layer.shadowOpacity = 0.25
            $0.layer.shadowRadius = 16
        }

        contentView.addSubview(artContainerView)
        artContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            artContainerView.leadingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -330),
            artContainerView.bottomAnchor.constraint(equalTo: wispView.topAnchor, constant: -4),
            artContainerView.widthAnchor.constraint(equalToConstant: 120),
            artContainerView.heightAnchor.constraint(equalToConstant: 120),
        ])
        
        // Artwork
        artContainerView.addSubview(artImageView)
        artImageView.do {
            $0.layer.allowsEdgeAntialiasing = true
            $0.layer.cornerCurve = .continuous
            $0.layer.masksToBounds = true
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.transform = CGAffineTransform(rotationAngle: -4 * .pi / 180)
            $0.layer.cornerRadius = 12
        }

        NSLayoutConstraint.activate([
            artImageView.centerXAnchor.constraint(equalTo: artContainerView.centerXAnchor),
            artImageView.centerYAnchor.constraint(equalTo: artContainerView.centerYAnchor),
            artImageView.widthAnchor.constraint(equalToConstant: 88),
            artImageView.heightAnchor.constraint(equalToConstant: 88)
        ])
        
        // Labels
        labelsStackView = UIStackView()
        labelsStackView.do {
            $0.axis = .vertical
            $0.alignment = .leading
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        nameLabel.do {
            $0.font = .systemFont(ofSize: 15, weight: .bold)
            $0.textColor = UIColor.white.withAlphaComponent(0.75)
            $0.text = nameText
            $0.numberOfLines = 2
            $0.textAlignment = .left
        }
        artistNameLabel.do {
            $0.font = .systemFont(ofSize: 13, weight: .medium)
            $0.textColor = UIColor.white.withAlphaComponent(0.75)
            $0.text = artistText
            $0.numberOfLines = 1
            $0.textAlignment = .left
        }

        artContainerView.addSubview(labelsStackView)
        labelsStackView.addArrangedSubview(nameLabel)
        labelsStackView.addArrangedSubview(artistNameLabel)
        
        NSLayoutConstraint.activate([
            labelsStackView.bottomAnchor.constraint(equalTo: artContainerView.bottomAnchor, constant: -12),
            labelsStackView.leadingAnchor.constraint(equalTo: artContainerView.trailingAnchor, constant: 12)
        ])
    
        dot1View = UIView()
        dot1View.do {
            $0.backgroundColor = wispView.backgroundColor
            $0.layer.cornerRadius = 4
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        dot2View = UIView()
        dot2View.do {
            $0.backgroundColor = wispView.backgroundColor
            $0.layer.cornerRadius = 2
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        contentView.addSubview(dot1View)
        contentView.addSubview(dot2View)

        // Constraints for the first dot (8x8)
        NSLayoutConstraint.activate([
            dot1View.widthAnchor.constraint(equalToConstant: 8),
            dot1View.heightAnchor.constraint(equalToConstant: 8),
            dot1View.bottomAnchor.constraint(equalTo: wispView.bottomAnchor),
            dot1View.leadingAnchor.constraint(equalTo: wispView.leadingAnchor)
        ])
        
        // Constraints for the second dot (4x4)
        NSLayoutConstraint.activate([
            dot2View.widthAnchor.constraint(equalToConstant: 4),
            dot2View.heightAnchor.constraint(equalToConstant: 4),
            dot2View.trailingAnchor.constraint(equalTo: wispView.leadingAnchor),
            dot2View.bottomAnchor.constraint(equalTo: wispView.bottomAnchor, constant: 4)
        ])
    }
    
    
    // MARK: Artifact UI
    private func setupArtifact(nameText: String, rating: Double, username: String, text: String) {
            
        // Art card, make sure its rotated to the left 4 deg
        artContainerView = UIView()
        artContainerView.do {
            $0.backgroundColor = .black
            $0.layer.cornerRadius = 32
            $0.layer.cornerCurve = .continuous
            $0.layer.masksToBounds = false
            $0.transform = CGAffineTransform(rotationAngle: -4 * .pi / 180)
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOffset = CGSize(width: 0, height: 2)
            $0.layer.shadowOpacity = 0.1
            $0.layer.shadowRadius = 8
        }

        contentView.addSubview(artContainerView)
        artContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            artContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: -114),
            artContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            artContainerView.widthAnchor.constraint(equalToConstant: 216),
            artContainerView.heightAnchor.constraint(equalToConstant: 304),
        ])
        
        // Artwork
        artImageView.do {
            $0.layer.cornerRadius = 32
            $0.layer.cornerCurve = .continuous
            $0.layer.masksToBounds = true
            $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        artContainerView.addSubview(artImageView)
        NSLayoutConstraint.activate([
            artImageView.trailingAnchor.constraint(equalTo: artContainerView.trailingAnchor),
            artImageView.topAnchor.constraint(equalTo: artContainerView.topAnchor),
            artImageView.widthAnchor.constraint(equalToConstant: 216),
            artImageView.heightAnchor.constraint(equalToConstant: 216)
        ])
        
        labelsStackView = UIStackView()
        labelsStackView.do {
            $0.axis = .vertical
            $0.alignment = .leading
            $0.spacing = 12
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        artContainerView.addSubview(labelsStackView)

        nameLabel.do {
            $0.font = .systemFont(ofSize: 15, weight: .bold)
            $0.textColor = UIColor.white.withAlphaComponent(0.75)
            $0.text = nameText
            $0.numberOfLines = 2
            $0.textAlignment = .left
        }
        labelsStackView.addArrangedSubview(nameLabel)

        let rating = RatingView(rating: rating)
        hostRatingView = UIHostingController(rootView: rating)
        guard let ratingView = hostRatingView?.view else { return }
        ratingView.backgroundColor = .clear
        ratingView.translatesAutoresizingMaskIntoConstraints = false
        labelsStackView.addArrangedSubview(ratingView)
        NSLayoutConstraint.activate([
            labelsStackView.bottomAnchor.constraint(equalTo: artContainerView.bottomAnchor, constant: -24),
            labelsStackView.leadingAnchor.constraint(equalTo: artContainerView.leadingAnchor, constant: 24),
            
            ratingView.widthAnchor.constraint(equalToConstant: 20),
            ratingView.heightAnchor.constraint(equalToConstant: 20)
        ])

        
        usernameLabel = UILabel()
        usernameLabel.do {
            $0.textColor = UIColor.white.withAlphaComponent(0.75)
            $0.text = username
            $0.font = UIFont.systemFont(ofSize: 13, weight: .medium)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        contentView.addSubview(usernameLabel)
        NSLayoutConstraint.activate([
            usernameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            usernameLabel.leadingAnchor.constraint(equalTo: artContainerView.leadingAnchor, constant: 24)
        ])
        
        // Card View / Transition Base
        cardView.do {
            contentView.fillWith($0)
            contentView.addSubview($0)
            $0.contentMode = .scaleAspectFill
            $0.layer.masksToBounds = false
            $0.backgroundColor = .black
            $0.layer.cornerRadius = 32
            $0.layer.cornerCurve = .continuous
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOffset = CGSize(width: 0, height: 4)
            $0.layer.shadowOpacity = 0.25
            $0.layer.shadowRadius = 16
        }
        
        textLabel = UILabel()
        textLabel.do {
            $0.text = text
            $0.textColor = .white.withAlphaComponent(0.75)
            $0.font = UIFont.systemFont(ofSize: 15)
            $0.numberOfLines = 0
            $0.textAlignment = .left
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        cardView.addSubview(textLabel)
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            textLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            textLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            textLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -16)
        ])
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
        avatarContainerView.do {
            $0.layer.cornerRadius = avatarSize / 2
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOffset = CGSize(width: 0, height: 2)
            $0.layer.shadowOpacity = 0.1
            $0.layer.shadowRadius = 8
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
            $0.addSubview(avatarImageView)
            $0.addGestureRecognizer(tap)
        }

        NSLayoutConstraint.activate([
            avatarImageView.centerXAnchor.constraint(equalTo: avatarContainerView.centerXAnchor),
            avatarImageView.centerYAnchor.constraint(equalTo: avatarContainerView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: avatarSize),
            avatarImageView.heightAnchor.constraint(equalToConstant: avatarSize),

            avatarContainerView.trailingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: -130),
            avatarContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            avatarContainerView.widthAnchor.constraint(equalToConstant: 40),
            avatarContainerView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc func avatarTapped() {
        NavigationManager.shared.navigateToUserScreen(withUserData: entry?.author)
    }
}

// MARK: Gestures

extension FeedCell {
    private func showDial(at point: CGPoint) {
        let dial = DialView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        dial.center = point
        contentView.addSubview(dial)
        dialView = dial
        dial.animateDialIn()
    }
    
    private func hideDial() {
        dialView?.hideDial()
        dialView = nil
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: contentView)
        switch gesture.state {
        case .began:
            showDial(at: location)
        case .ended, .cancelled, .failed:
            hideDial()
        default:
            break
        }
    }
    
    private func setupGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.25
        addGestureRecognizer(longPressGesture)
    }
    
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
}
