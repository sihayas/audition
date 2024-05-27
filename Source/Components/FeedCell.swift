//
//  FeedCell.swift
//  vaela
//
//  Created by decoherence on 4/30/24.
//

import UIKit
import SwiftUI

class FeedCell: UICollectionViewCell {

    // MARK: UI Properties

    private var ratingHost: UIHostingController<RatingView>?
    private let avatarImage = ImageView()
    private let cardView = UIView()
    private let artImage = ImageView()
    private let artistLabel = UILabel()
    private let nameLabel = UILabel()
    private let containerView = UIView()
    private var dialView: DialView?
    
    // MARK: Data
    private var entry: APIEntry?
    
    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    


    // MARK: Data

    func setup(with entry: APIEntry) {
        self.entry = entry
        
        artImage.setImage(from: entry.soundData.formattedArtworkUrl ?? URL(string: "")!)
        avatarImage.setImage(from: entry.author.image ?? URL(string: "https://example.com/placeholder.png")!)
        setupMetaData(artistText: entry.soundData.artistName, nameText: entry.soundData.name, rating: entry.rating)
        setupAttribution(username: entry.author.username)
    }
    
    
    @objc private func avatarTapped() {
        print("tapped")
        guard let entry = entry else { return }
//        let details = UserScreenDetails (
//            id: entry.author.id,
//            username: entry.author.username,
//            image: entry.author.image ?? URL(string: "https://example.com/placeholder.png")!,
//            essentials: entry.author.essentials
//        )
//        NavigationManager.shared.navigateToUserScreen(withDetails: details)
    }
}


// MARK: - Reuse

extension FeedCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        ratingHost?.view.removeFromSuperview()
        ratingHost = nil
        dialView?.removeFromSuperview()
        dialView = nil
        avatarImage.image = nil
        artImage.image = nil
        artistLabel.text = ""
        nameLabel.text = ""
    }
}

// MARK: - Setup

extension FeedCell {
    private func setupUI() {
        setupView()
        setupCardView()
        setupArtView()
    }
    
    private func setupView() {
        contentView.backgroundColor = .clear
    }
    
    private func setupCardView() {
        cardView.do {
            contentView.fillWith($0)
            contentView.addSubview($0)
            $0.contentMode = .scaleAspectFill
            $0.layer.masksToBounds = false
            $0.backgroundColor = .systemGray6
            $0.layer.cornerRadius = 32
            $0.layer.cornerCurve = .continuous
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOffset = CGSize(width: 0, height: 4)
            $0.layer.shadowOpacity = 0.25
            $0.layer.shadowRadius = 16
            $0.alpha = 1
            
            // Add a white border with opacity of 0.1
            $0.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
            $0.layer.borderWidth = 1.0
        }
    }
    
    private func setupArtView() {
        cardView.addSubview(artImage)
        artImage.contentMode = .scaleAspectFit
        artImage.layer.borderColor = UIColor.black.withAlphaComponent(0.05).cgColor
        artImage.layer.borderWidth = 1
        artImage.layer.cornerRadius = 32
        artImage.layer.cornerCurve = .continuous
        artImage.layer.masksToBounds = true
        artImage.translatesAutoresizingMaskIntoConstraints = false

        artImage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        NSLayoutConstraint.activate([
            artImage.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: 0),
            artImage.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 0),
            artImage.widthAnchor.constraint(equalToConstant: 256),
            artImage.heightAnchor.constraint(equalToConstant: 256)
        ])
    }

    private func setupMetaData(artistText: String, nameText: String, rating: Double) {

        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(containerView)

        let starRatingView = RatingView(rating: rating)
        ratingHost = UIHostingController(rootView: starRatingView)
        guard let starRatingViewView = ratingHost?.view else { return }
        starRatingViewView.backgroundColor = .clear
        starRatingViewView.alpha = 0.75
        starRatingViewView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(starRatingViewView)

        let labelsStackView = UIStackView()
        labelsStackView.axis = .vertical
        labelsStackView.spacing = 4
        labelsStackView.alignment = .trailing // Align items to the right
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(labelsStackView)

        artistLabel.font = .systemFont(ofSize: 13, weight: .medium)
        artistLabel.textColor = UIColor.white.withAlphaComponent(0.75)
        artistLabel.text = artistText
        artistLabel.numberOfLines = 1
        artistLabel.textAlignment = .right
        labelsStackView.addArrangedSubview(artistLabel)

        nameLabel.font = .systemFont(ofSize: 15, weight: .bold)
        nameLabel.textColor = UIColor.white.withAlphaComponent(0.75)
        nameLabel.text = nameText
        nameLabel.numberOfLines = 2
        nameLabel.textAlignment = .right
        labelsStackView.addArrangedSubview(nameLabel)


        NSLayoutConstraint.activate([
            containerView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -24),
            containerView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            containerView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),

            labelsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            labelsStackView.leadingAnchor.constraint(equalTo: starRatingViewView.trailingAnchor, constant: 12),
            labelsStackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            labelsStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            starRatingViewView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            starRatingViewView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor,constant: -8),
            starRatingViewView.widthAnchor.constraint(equalToConstant: 20),
            starRatingViewView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func setupAttribution(username: String) {
        let borderSize: CGFloat = 4
        let avatarSize: CGFloat = 40

        let containerView = UIView()
        containerView.layer.cornerRadius = (avatarSize / 2) + borderSize
        containerView.layer.borderWidth = borderSize
        containerView.layer.borderColor = UIColor.systemGray6.cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false

        avatarImage.layer.cornerRadius = avatarSize / 2
        avatarImage.clipsToBounds = true
        avatarImage.translatesAutoresizingMaskIntoConstraints = false
        
        
        let usernameLabel = UILabel().then {
          $0.textColor = UIColor.white.withAlphaComponent(0.75)
          $0.text = username
          $0.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        }
        
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(avatarImage)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            avatarImage.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            avatarImage.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            avatarImage.widthAnchor.constraint(equalToConstant: avatarSize),
            avatarImage.heightAnchor.constraint(equalToConstant: avatarSize),
            
            containerView.trailingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.widthAnchor.constraint(equalToConstant: avatarSize + 2 * borderSize),
            containerView.heightAnchor.constraint(equalToConstant: avatarSize + 2 * borderSize),
            
            usernameLabel.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 6),
            usernameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24)
        ])
    }


}

// MARK: Gestures

extension FeedCell {
    private func setupGesture() {
        // dial
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.25
        artImage.addGestureRecognizer(longPressGesture)
        artImage.isUserInteractionEnabled = true
        
        // avatar
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
        avatarImage.addGestureRecognizer(tapGesture)
        avatarImage.isUserInteractionEnabled = true
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
            print("Pin action selected")
        case 1:
            print("Save action selected")
        case 2:
            print("Share action selected")
        default:
            break
        }
    }
}


extension UIFont {
    class func rounded(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)

        guard #available(iOS 13.0, *), let descriptor = systemFont.fontDescriptor.withDesign(.rounded) else { return systemFont }
        return UIFont(descriptor: descriptor, size: size)
    }
}
