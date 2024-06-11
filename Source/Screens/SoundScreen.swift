//
//  SoundScreen.swift
//  InstagramTransition
//
//  Created by decoherence on 5/9/24.
//

import UIKit
import SwiftUI

struct SoundScreenDetails {
    var id: String
    var title: String
    var subtitle: String
    var imageUrl: URL?
    var color: String
}

class SoundScreen: UIViewController, UIGestureRecognizerDelegate {
    var details: SoundScreenDetails
    private var scrollView = UIScrollView()
    private var contentView = UIView()
    private var artView = ImageView()
    private var stackView = UIStackView()
    private let cardView = UIView()

    init(details: SoundScreenDetails) {
        self.details = details
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        setupView()
        setupScrollView()
        setupBlurEffect()
        setupArt()
        setupMetaData()
        setupCard()
        setupSpacer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    private func setupView() {
        view.backgroundColor = .black
    }
    
    private func setupScrollView() {
        scrollView.then {
            $0.alwaysBounceVertical = true
            view.addSubview($0)
        }.layout {
            $0.top == view.topAnchor
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
    
    private func setupBlurEffect() {
        let circleView = CircleView(hexColor: details.color, width: 760, height: 760, startRadius: 0, endRadius: 760)
        let circleHost = UIHostingController(rootView: circleView)
        circleHost.view.then {
            $0.backgroundColor = .clear
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }.layout {
            $0.centerX == view.centerXAnchor
            $0.top == view.topAnchor
        }

        let blurEffect = UIBlurEffect(style: .systemThickMaterialDark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }.layout {
            $0.top == view.topAnchor
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.bottom == view.bottomAnchor
        }
    }

    private func setupArt() {
        let containerView = UIView()
        containerView.then {
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOpacity = 0.3
            $0.layer.shadowOffset = CGSize(width: 5, height: 5)
            $0.layer.shadowRadius = 15
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }.layout {
            $0.centerX == contentView.centerXAnchor
            $0.top == contentView.topAnchor - 60
            $0.width == UIScreen.main.bounds.width
            $0.height == UIScreen.main.bounds.width
        }

        artView.then {
            $0.setImage(from: details.imageUrl ?? URL(string: "")!)
            $0.clipsToBounds = true
            $0.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview($0)
        }.layout {
            $0.centerX == containerView.centerXAnchor
            $0.centerY == containerView.centerYAnchor
            $0.width == containerView.widthAnchor
            $0.height == containerView.heightAnchor
        }
    }

    private func setupMetaData() {
        // rating and names
        let ratingView = RatingView(rating: 1)
        let ratingHost = UIHostingController(rootView: ratingView)
        ratingHost.view.then {
            $0.backgroundColor = .clear
            $0.alpha = 0.9
            $0.translatesAutoresizingMaskIntoConstraints = false
            addChild(ratingHost)
            ratingHost.didMove(toParent: self)
        }.layout {
            $0.width == 32
            $0.height == 32
        }

        let soundSubtitle = UILabel()
        soundSubtitle.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.font = .systemFont(ofSize: 13, weight: .regular)
            $0.text = details.subtitle
            $0.numberOfLines = 1
        }

        let soundTitle = UILabel()
        soundTitle.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.font = .systemFont(ofSize: 15, weight: .bold)
            $0.text = details.title
            $0.numberOfLines = 1
        }

        let titlesStackView = UIStackView(arrangedSubviews: [soundSubtitle, soundTitle])
        titlesStackView.do {
            $0.axis = .vertical
            $0.alignment = .leading
            $0.distribution = .equalSpacing
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.alpha = 0.9
        }

        stackView = UIStackView(arrangedSubviews: [titlesStackView, ratingHost.view])
        stackView.then {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.distribution = .equalSpacing
            $0.spacing = 16
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }.layout {
            $0.top == artView.bottomAnchor + 24
            $0.leading == view.leadingAnchor + 24
            $0.trailing == view.trailingAnchor - 24
        }

        // statistics
        let artifactCountTitle = UILabel()
        artifactCountTitle.then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.font = .systemFont(ofSize: 13, weight: .regular)
            $0.text = "artifacts"
            $0.numberOfLines = 1
            $0.alpha = 0.9
            scrollView.addSubview($0)
        }.layout {
            $0.top == stackView.bottomAnchor + 24
            $0.leading == scrollView.leadingAnchor + 24
        }

        let artifactCount = UILabel()
        artifactCount.then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.font = .systemFont(ofSize: 15, weight: .semibold)
            $0.text = "3478"
            $0.numberOfLines = 1
            $0.alpha = 0.9
            scrollView.addSubview($0)
        }.layout {
            $0.top == artifactCountTitle.bottomAnchor
            $0.leading == scrollView.leadingAnchor + 24
        }

        let essentialCountTitle = UILabel()
        essentialCountTitle.then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.font = .systemFont(ofSize: 13, weight: .regular)
            $0.text = "essentials"
            $0.numberOfLines = 1
            $0.alpha = 0.9
            scrollView.addSubview($0)
        }.layout {
            $0.top == artifactCount.bottomAnchor + 24
            $0.leading == scrollView.leadingAnchor + 24
        }

        let essentialCount = UILabel()
        essentialCount.then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.font = .systemFont(ofSize: 15, weight: .semibold)
            $0.text = "43"
            $0.numberOfLines = 1
            $0.alpha = 0.9
            contentView.addSubview($0)
        }.layout {
            $0.top == essentialCountTitle.bottomAnchor
            $0.leading == scrollView.leadingAnchor + 24
        }
    }
    
    private func setupCard() {
        cardView.then {
            $0.layer.cornerRadius = 24
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOpacity = 0.1
            $0.layer.shadowOffset = CGSize(width: 0, height: 4)
            $0.layer.shadowRadius = 8
            $0.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
            $0.layer.borderWidth = 1.0
            $0.backgroundColor = .systemGray6
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.transform = CGAffineTransform(rotationAngle: 4 * .pi / 180)
            contentView.addSubview($0)
        }.layout {
            $0.top == stackView.bottomAnchor + 40
            $0.trailing == view.trailingAnchor - 48
            $0.width == 216
            $0.height == 304
        }

        let textView = UILabel()
        textView.then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .clear
            $0.font = .systemFont(ofSize: 13, weight: .medium)
            $0.text = "Seemed interesting from the feature list and jean's admittedly cool art direction, but sadly this is kinda more tiktok zoomer not-rly-indie diet-alternative pop ... maybe a hair more interesting production-wise?? still, every time i hear this record's execution of lowest common denominator whoa-oh passages i cringe so hard, plus jean's delivery across the board comes across wicked corny. not the worst album of the year, but about as middle-of-the-road as u can get. i'm gettin too old for this shit lmao. why bill yrself as a genre-blending artist if yr "
            $0.numberOfLines = 15
            $0.alpha = 0.9
            $0.textAlignment = .left
            cardView.addSubview($0)
        }.layout {
            $0.top == cardView.topAnchor + 16
            $0.leading == cardView.leadingAnchor + 20
            $0.trailing == cardView.trailingAnchor - 20
        }
        
        let ratingView = RatingView(rating: 1)
        let ratingHost = UIHostingController(rootView: ratingView)
        ratingHost.view.then {
            $0.backgroundColor = .clear
            $0.alpha = 0.9
            $0.translatesAutoresizingMaskIntoConstraints = false
            addChild(ratingHost)
            ratingHost.didMove(toParent: self)
            cardView.addSubview($0)
        }.layout {
            $0.leading == cardView.leadingAnchor + 20
            $0.bottom == cardView.bottomAnchor - 20
            $0.width == 16
            $0.height == 16
        }
        
        let avatar = UIImageView()
        avatar.then {
            $0.layer.cornerRadius = 16
            $0.layer.borderColor = UIColor.systemGray6.cgColor
            $0.layer.borderWidth = 2
            $0.clipsToBounds = true
            $0.translatesAutoresizingMaskIntoConstraints = false
            cardView.addSubview($0)
        }.layout {
            $0.trailing == cardView.trailingAnchor + 8
            $0.top == cardView.topAnchor - 8
            $0.width == 32
            $0.height == 32
        }

        if let url = URL(string: "https://i.pinimg.com/474x/00/47/6a/00476aa6b476b9169a6e5e05e224c9ab.jpg") {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    avatar.image = UIImage(data: data)
                }
            }.resume()
        }
    }
        
    private func setupSpacer() {
        let spacerView = UIView()
        spacerView.then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }.layout {
            $0.top == cardView.bottomAnchor
            $0.width == contentView.widthAnchor
            $0.height == 500
            $0.centerX == contentView.centerXAnchor
            $0.bottom == contentView.bottomAnchor
        }
    }
}
