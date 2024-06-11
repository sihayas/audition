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
    private var entryTextHost: UIHostingController<AnimateTextOutView>?
    

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
        let circleView = CircleView(
            hexColor: appleData.artworkBgColor,
            width: 364,
            height: 364,
            startRadius: 0,
            endRadius: 364
        )
        
        circleHost = UIHostingController(rootView: circleView)
        guard let circleView = circleHost?.view else { return }
        
        circleView.backgroundColor = .clear
        contentView.insertSubview(circleView, at: 0)
        circleView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            circleView.topAnchor.constraint(equalTo: contentView.topAnchor),
            circleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
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
        
        blurEffectView.alpha = 0
        circleView.alpha = 0
        circleView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            blurEffectView.alpha = 1
            circleView.alpha = 1
            circleView.transform = CGAffineTransform.identity
        }
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

        let entryText = AnimateTextOutView(fontSize: 30, text: entry.text, weight: .regular)
        entryTextHost = UIHostingController(rootView: entryText)
        guard let entryTextView = entryTextHost?.view else { return }
        cardView.addSubview(entryTextView)
        entryTextView.backgroundColor = .clear
        entryTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            entryTextView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 32),
            entryTextView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 54),
            entryTextView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -54)
        ])
        
        setupEntry(appleData: appleData)
    }
    
    private func setupEntry(appleData: APIAppleSoundData) {
        let entryView = EntryView(entry: entry, appleData: appleData)
        let entryHost = UIHostingController(rootView: entryView)
        entryHost.view.backgroundColor = .clear
        
        contentView.addSubview(entryHost.view)
        entryHost.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            entryHost.view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            entryHost.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            entryHost.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
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
