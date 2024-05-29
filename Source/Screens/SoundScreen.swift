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
        circleHost.view.backgroundColor = .clear
        circleHost.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(circleHost.view)
        NSLayoutConstraint.activate([
            circleHost.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            circleHost.view.topAnchor.constraint(equalTo: view.topAnchor)
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
    
    private func setupArt() {
        let containerView = UIView()
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.3
        containerView.layer.shadowOffset = CGSize(width: 5, height: 5)
        containerView.layer.shadowRadius = 15
        containerView.translatesAutoresizingMaskIntoConstraints = false

        artView.setImage(from: details.imageUrl ?? URL(string: "")!)
        artView.clipsToBounds = true
        artView.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(artView)
        contentView.addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -60),
            containerView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
            containerView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),

            artView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            artView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            artView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            artView.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        ])
    }

   
    private func setupMetaData() {
        // rating and names
        let ratingView = RatingView(rating: 1)
        let ratingHost = UIHostingController(rootView: ratingView)
        ratingHost.view.backgroundColor = .clear
        ratingHost.view.alpha = 0.9
        ratingHost.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(ratingHost)
        ratingHost.didMove(toParent: self)

        let soundSubtitle = UILabel()
        soundSubtitle.translatesAutoresizingMaskIntoConstraints = false
        soundSubtitle.font = .systemFont(ofSize: 13, weight: .regular)
        soundSubtitle.text = details.subtitle
        soundSubtitle.numberOfLines = 1

        let soundTitle = UILabel()
        soundTitle.translatesAutoresizingMaskIntoConstraints = false
        soundTitle.font = .systemFont(ofSize: 15, weight: .bold)
        soundTitle.text = details.title
        soundTitle.numberOfLines = 1

        let titlesStackView = UIStackView(arrangedSubviews: [soundSubtitle, soundTitle])
        titlesStackView.axis = .vertical
        titlesStackView.alignment = .leading
        titlesStackView.distribution = .equalSpacing
        titlesStackView.translatesAutoresizingMaskIntoConstraints = false
        titlesStackView.alpha = 0.9

        stackView = UIStackView(arrangedSubviews: [titlesStackView, ratingHost.view])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: artView.bottomAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            ratingHost.view.widthAnchor.constraint(equalToConstant: 32),
            ratingHost.view.heightAnchor.constraint(equalToConstant: 32),
        ])
        
        // statistics
        let artifactCountTitle = UILabel()
        artifactCountTitle.translatesAutoresizingMaskIntoConstraints = false
        artifactCountTitle.font = .systemFont(ofSize: 13, weight: .regular)
        artifactCountTitle.text = "artifacts"
        artifactCountTitle.numberOfLines = 1
        artifactCountTitle.alpha = 0.9
        scrollView.addSubview(artifactCountTitle)

        let artifactCount = UILabel()
        artifactCount.translatesAutoresizingMaskIntoConstraints = false
        artifactCount.font = .systemFont(ofSize: 15, weight: .semibold)
        artifactCount.text = "3478"
        artifactCount.numberOfLines = 1
        artifactCount.alpha = 0.9
        scrollView.addSubview(artifactCount)

        let essentialCountTitle = UILabel()
        essentialCountTitle.translatesAutoresizingMaskIntoConstraints = false
        essentialCountTitle.font = .systemFont(ofSize: 13, weight: .regular)
        essentialCountTitle.text = "essentials"
        essentialCountTitle.numberOfLines = 1
        essentialCountTitle.alpha = 0.9
        scrollView.addSubview(essentialCountTitle)

        let essentialCount = UILabel()
        essentialCount.translatesAutoresizingMaskIntoConstraints = false
        essentialCount.font = .systemFont(ofSize: 15, weight: .semibold)
        essentialCount.text = "43"
        essentialCount.numberOfLines = 1
        essentialCount.alpha = 0.9
        contentView.addSubview(essentialCount)

        NSLayoutConstraint.activate([
            artifactCountTitle.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 24),
            artifactCountTitle.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 24),
            artifactCount.topAnchor.constraint(equalTo: artifactCountTitle.bottomAnchor),
            artifactCount.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 24),
            essentialCountTitle.topAnchor.constraint(equalTo: artifactCount.bottomAnchor, constant: 24),
            essentialCountTitle.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 24),
            essentialCount.topAnchor.constraint(equalTo: essentialCountTitle.bottomAnchor),
            essentialCount.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 24)
        ])
    }
    
    private func setupCard() {
        cardView.layer.cornerRadius = 24
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowRadius = 8
        cardView.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        cardView.layer.borderWidth = 1.0
        cardView.backgroundColor = .systemGray6
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)
        cardView.transform = CGAffineTransform(rotationAngle: 4 * .pi / 180)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 40),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -48),
            cardView.widthAnchor.constraint(equalToConstant: 216),
            cardView.heightAnchor.constraint(equalToConstant: 304)
        ])

        let textView = UILabel()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .clear
        textView.font = .systemFont(ofSize: 13, weight: .medium)
        textView.text = "Seemed interesting from the feature list and jean's admittedly cool art direction, but sadly this is kinda more tiktok zoomer not-rly-indie diet-alternative pop ... maybe a hair more interesting production-wise?? still, every time i hear this record's execution of lowest common denominator whoa-oh passages i cringe so hard, plus jean's delivery across the board comes across wicked corny. not the worst album of the year, but about as middle-of-the-road as u can get. i'm gettin too old for this shit lmao. why bill yrself as a genre-blending artist if yr "
        textView.numberOfLines = 15
        textView.alpha = 0.9
        textView.textAlignment = .left
        cardView.addSubview(textView)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20)
        ])
        
        let ratingView = RatingView(rating: 1)
        let ratingHost = UIHostingController(rootView: ratingView)
        addChild(ratingHost)
        ratingHost.didMove(toParent: self)
        cardView.addSubview(ratingHost.view)

        ratingHost.view.backgroundColor = .clear
        ratingHost.view.alpha = 0.9
        ratingHost.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            ratingHost.view.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            ratingHost.view.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20),
            ratingHost.view.widthAnchor.constraint(equalToConstant: 16),
            ratingHost.view.heightAnchor.constraint(equalToConstant: 16)
        ])
        
        let avatar = UIImageView()
        avatar.layer.cornerRadius = 16
        avatar.layer.borderColor = UIColor.systemGray6.cgColor
        avatar.layer.borderWidth = 2
        avatar.clipsToBounds = true
        avatar.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(avatar)

        NSLayoutConstraint.activate([
            avatar.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: 8),
            avatar.topAnchor.constraint(equalTo: cardView.topAnchor, constant: -8),
            avatar.widthAnchor.constraint(equalToConstant: 32),
            avatar.heightAnchor.constraint(equalToConstant: 32)
        ])

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
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(spacerView)

        NSLayoutConstraint.activate([
            spacerView.topAnchor.constraint(equalTo:cardView.bottomAnchor),
            spacerView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            spacerView.heightAnchor.constraint(equalToConstant: 500),
            spacerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            spacerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

}
