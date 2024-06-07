//
//  EntryView.swift
//  vaela
//
//  Created by decoherence on 4/29/24.
//

import UIKit
import SwiftUI

class EntryScreen: UIViewController {

    // MARK: Private properties

    private var entry: APIEntry

    // MARK: UI Properties
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let cardView = UIView()
    private let artView = ImageView()
    private let avatarView = ImageView()
    
    
    private var circleHost: UIHostingController<CircleView>?
    private var albumTextOutHost: UIHostingController<AnimateTextOutView>?
    private var artistTextOutHost: UIHostingController<AnimateTextOutView>?
    private var artistTextInHost: UIHostingController<AnimateTextInView>?
    private var albumTextInHost: UIHostingController<AnimateTextInView>?
    private var bodyTextInHost: UIHostingController<AnimateTextInView>?
    private var ratingHost: UIHostingController<RatingView>?
    

    private lazy var recognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
    private let transitionAnimator = SharedTransitionAnimator()
    private var interactionController: SharedTransitionInteractionController?

    // MARK: Init

    init(entry: APIEntry) {
        self.entry = entry
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.delegate = self
    }
}

// MARK: - Setup

extension EntryScreen {
    private func setupUI() {
        guard let appleData = entry.sound.appleData else {
            return
        }
        
        setupView()
        setupScrollView()
        setupBlurEffect(appleData: appleData)
        setupPlaceholderCard(appleData: appleData)
        setupContent(appleData: appleData)
    }
    

    private func setupView() {
        view.backgroundColor = .black
        view.addGestureRecognizer(recognizer)
        recognizer.delegate = self
    }

    private func setupScrollView() {
        scrollView.then {
            $0.alwaysBounceVertical = true
            view.addSubview($0)
        }.layout {
            $0.top == view.topAnchor - 32
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.bottom == view.bottomAnchor
        }

        contentView.then {
            scrollView.addSubview($0)
            scrollView.fillWith($0)
        }.layout {
            $0.width == scrollView.widthAnchor
            $0.height >= scrollView.heightAnchor
        }
    }
    
    private func setupBlurEffect(appleData: APIAppleSoundData) {
        // blurred ambiance
        let circleView = CircleView(hexColor: appleData.artworkBgColor, width: 364, height: 364, startRadius: 0, endRadius: 364)
        circleHost = UIHostingController(rootView: circleView)
        guard let circleView = circleHost?.view else { return }
        circleView.backgroundColor = .clear
        contentView.insertSubview(circleView, at: 0)
        circleView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            circleView.topAnchor.constraint(equalTo: contentView.topAnchor),
            circleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        ])

        let blurEffect = UIBlurEffect(style: .systemThickMaterialDark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(blurEffectView)
        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            blurEffectView.leftAnchor.constraint(equalTo: view.leftAnchor),
            blurEffectView.rightAnchor.constraint(equalTo: view.rightAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupPlaceholderCard(appleData: APIAppleSoundData) {
        // setup card view
        cardView.then {
            contentView.addSubview($0)
            $0.contentMode = .scaleAspectFit
            $0.layer.masksToBounds = true
            cardView.backgroundColor = .clear
        }.layout {
            $0.leading == contentView.leadingAnchor
            $0.trailing == contentView.trailingAnchor
            $0.top == contentView.topAnchor
        }
        
        cardView.heightAnchor.constraint(
            equalTo: cardView.widthAnchor,
            multiplier: 1.4
        ).isActive = true
        
        // art
        setupArt(appleData: appleData)

        let artistTextView = AnimateTextOutView(fontSize: 19, text: appleData.artistName, weight: .medium)
        artistTextOutHost = UIHostingController(rootView: artistTextView)
        guard let artistView = artistTextOutHost?.view else { return }
        contentView.addSubview(artistView)
        artistView.backgroundColor = .clear
        artistView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            artistView.topAnchor.constraint(equalTo: artView.bottomAnchor, constant: 42),
            artistView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 42),
            artistView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -42)
        ])
        
        let albumTextView = AnimateTextOutView(fontSize: 19, text: appleData.name, weight: .bold)
        albumTextOutHost = UIHostingController(rootView: albumTextView)
        guard let albumView = albumTextOutHost?.view else { return }
        contentView.addSubview(albumView)
        albumView.backgroundColor = .clear
        albumView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            albumView.topAnchor.constraint(equalTo: artistView.bottomAnchor, constant: 0),
            albumView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 42),
            albumView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -42)
        ])
        
    }

    
    private func setupArt(appleData: APIAppleSoundData) {
        // art shadow container
        let containerView = UIView()
        contentView.addSubview(containerView)
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.2
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowRadius = 12
        containerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            containerView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 32),
            containerView.widthAnchor.constraint(equalToConstant: 364),
            containerView.heightAnchor.constraint(equalToConstant: 364)
        ])

        // art
        containerView.addSubview(artView)
        artView.contentMode = .scaleAspectFit
        
        let width = 600
        let height = 600
        guard let artworkUrl = URL(string: appleData.artworkUrl.replacingOccurrences(of: "{w}", with: "\(width)").replacingOccurrences(of: "{h}", with: "\(height)")) else { return }
        artView.setImage(from: artworkUrl)
        
        artView.layer.cornerRadius = 32
        artView.layer.cornerCurve = .continuous
        artView.layer.masksToBounds = true
        artView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            artView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            artView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            artView.topAnchor.constraint(equalTo: containerView.topAnchor),
            artView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        // animate avatar and art
        contentView.layoutIfNeeded()
        
        let translation = CGAffineTransform(translationX: containerView.bounds.width * ((1 - 0.6593) / 2) - 8, y: -containerView.bounds.height * (1 - 0.6593) / 2)
        let scale = CGAffineTransform(scaleX: 0.6593, y: 0.6593)

        containerView.transform = CGAffineTransform.identity
        UIView.animate(withDuration: 0.75,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.2,
                       options: [.curveEaseInOut],
                       animations: {
                            containerView.transform = scale.concatenating(translation)
                       }, completion: nil)
    }

    
    private func setupContent(appleData: APIAppleSoundData) {
        let starRatingView = RatingView(rating: entry.rating ?? 0)
        ratingHost = UIHostingController(rootView: starRatingView)
        guard let starRatingView = ratingHost?.view else { return }
        contentView.addSubview(starRatingView)
        starRatingView.backgroundColor = .clear
        starRatingView.alpha = 0.75
        starRatingView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            starRatingView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 48),
            starRatingView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -288),
            starRatingView.widthAnchor.constraint(equalToConstant: 24),
            starRatingView.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        let albumTextView = AnimateTextInView(fontSize: 15, text: appleData.name, weight: .bold)
        albumTextInHost = UIHostingController(rootView: albumTextView)
        guard let albumTextView = albumTextInHost?.view else { return }
        contentView.addSubview(albumTextView)
        albumTextView.backgroundColor = .clear
        albumTextView.alpha = 0.75
        albumTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            albumTextView.bottomAnchor.constraint(equalTo: contentView.topAnchor, constant: 256),
            albumTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -288),
            albumTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24)
        ])
        
        let artistTextView = AnimateTextInView(fontSize: 13, text: appleData.artistName, weight: .medium)
        artistTextInHost = UIHostingController(rootView: artistTextView)
        guard let artistTextView = artistTextInHost?.view else { return }
        contentView.addSubview(artistTextView)
        artistTextView.backgroundColor = .clear
        artistTextView.alpha = 0.75
        artistTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            artistTextView.bottomAnchor.constraint(equalTo: albumTextView.topAnchor, constant: 0),
            artistTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -288),
            artistTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24)
        ])
        
        // body text + avatar container
        // Outer view for shadow
        let shadowContainer = UIView()
        contentView.addSubview(shadowContainer)
        shadowContainer.backgroundColor = .clear
        shadowContainer.layer.shadowColor = UIColor.black.cgColor
        shadowContainer.layer.shadowOffset = CGSize(width: 0, height: 4)
        shadowContainer.layer.shadowOpacity = 0.1
        shadowContainer.layer.shadowRadius = 2
        shadowContainer.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            shadowContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 312),
            shadowContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            shadowContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28),
        ])

        // Inner view for corner radius
        let containerView = UIView()
        shadowContainer.addSubview(containerView)
        containerView.backgroundColor = UIColor.systemGray6
        containerView.layer.cornerRadius = 20
        containerView.layer.cornerCurve = .continuous
        containerView.clipsToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: shadowContainer.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: shadowContainer.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: shadowContainer.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: shadowContainer.bottomAnchor)
        ])


        let avatar = avatarView
        shadowContainer.addSubview(avatar)
        let imageURL = entry.author.image
        if let url = URL(string: imageURL) {
            avatar.setImage(from: url)
        } else {
            avatar.image = UIImage(named: "placeholder")
        }
        avatar.layer.cornerRadius = 20
        avatar.layer.borderColor = UIColor.systemGray6.cgColor
        avatar.layer.borderWidth = 2
        avatar.layer.masksToBounds = true
        avatar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            avatar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: -20),
            avatar.topAnchor.constraint(equalTo: containerView.topAnchor, constant: -20),
            avatar.widthAnchor.constraint(equalToConstant: 40),
            avatar.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        let username = UILabel()
        contentView.addSubview(username)
        username.text = entry.author.username
        username.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        username.alpha = 0.75
        username.backgroundColor = .clear
        username.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            username.bottomAnchor.constraint(equalTo: shadowContainer.topAnchor, constant: -8),
            username.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 8),
            username.trailingAnchor.constraint(equalTo: shadowContainer.trailingAnchor, constant: -24)
        ])

        let bodyTextView = AnimateTextInView(fontSize: 15, text: entry.text, weight: .regular)
        bodyTextInHost = UIHostingController(rootView: bodyTextView)
        guard let bodyTextView = bodyTextInHost?.view else { return }
        contentView.addSubview(bodyTextView)
        bodyTextView.backgroundColor = .clear
        bodyTextView.alpha = 0.75
        bodyTextView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            bodyTextView.topAnchor.constraint(equalTo: containerView.topAnchor),
            bodyTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            bodyTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            bodyTextView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0)
        ])
        
        avatar.alpha = 0
        avatar.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 1,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 1.0,
                       options: [.curveEaseOut],
                       animations: {
                            avatar.alpha = 1
                            avatar.transform = CGAffineTransform.identity
                       },
                       completion: nil)
        
        starRatingView.alpha = 0
        starRatingView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 1,
                       delay: 0.25,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 1.0,
                       options: [.curveEaseOut],
                       animations: {
            starRatingView.alpha = 1
            starRatingView.transform = CGAffineTransform.identity
                       },
                       completion: nil)
    }
}


// MARK: UIGestureRecognizerDelegate

extension EntryScreen: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        scrollView.isBouncing
    }
}

// MARK: - UINavigationControllerDelegate

extension EntryScreen: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard fromVC is Self, toVC is FeedScreen else { return nil }
        transitionAnimator.transition = .pop
        return transitionAnimator
    }

    func navigationController(
        _ navigationController: UINavigationController,
        interactionControllerFor animationController: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        interactionController
    }
}

// MARK: UIPanGestureRecognizer

extension EntryScreen {
    @objc
    func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let window = UIApplication.keyWindow!
        switch recognizer.state {
        case .began:
            let velocity = recognizer.velocity(in: window)
            guard abs(velocity.x) > abs(velocity.y) else { return }
            interactionController = SharedTransitionInteractionController()
            navigationController?.popViewController(animated: true)
        case .changed:
            interactionController?.update(recognizer)
        case .ended:
            if recognizer.velocity(in: window).x > 0 {
                interactionController?.finish()
            } else {
                interactionController?.cancel()
            }
            interactionController = nil
        default:
            interactionController?.cancel()
            interactionController = nil
        }
    }
}

// MARK: SharedTransitioning

extension EntryScreen: SharedTransitioning {
    var sharedFrame: CGRect {
        cardView.frameInWindow ?? .zero
    }
}
