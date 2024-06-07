//
//  UserScreen.swift
//  Audition
//
//  Created by decoherence on 5/27/24.
//

import UIKit
import SwiftUI

class UserScreen: UIViewController, UIGestureRecognizerDelegate {
    var details: User
    private var scrollView = UIScrollView()
    private var contentView = UIView()
    private var avatarImage = ImageView()
    private var userData: APIUser?

    init(details: User) {
        self.details = details
        super.init(nibName: nil, bundle: nil)
        
        guard let userId = details.id else {
            print("User ID not available")
            return
        }
    
        // Fetch up to date data
        UserAPI.fetchUserData(userId: userId, pageUserId: userId) { [weak self] result in
            switch result {
            case .success(let userResponse):
                self?.userData = userResponse.data
                print("found user \(userResponse.data)")
            case .failure(let error):
                print("Error fetching user data: \(error.localizedDescription)")
            }
        }
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
        setupAvatar()
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
    
    private func setupAvatar() {
        if let imageURL = URL(string: details.image ?? "") {
            avatarImage.setImage(from: imageURL)
            // Check if the image is set and then extract the dominant color
            checkImageSet {
                self.extractAndDisplayDominantColor()
            }
        } else {
            print("Invalid image URL")
        }
    }

    
    
    private func setupBlurEffect(with color: String) {
        let circleView = CircleView(hexColor: color, width: 760, height: 760, startRadius: 0, endRadius: 760)
        let circleHost = UIHostingController(rootView: circleView)
        circleHost.view.backgroundColor = .clear
        circleHost.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(circleHost.view)

        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThickMaterialDark))
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(blurEffectView)

        let avatarSize: CGFloat = 70
        avatarImage.layer.cornerRadius = avatarSize / 2
        avatarImage.clipsToBounds = true
        avatarImage.translatesAutoresizingMaskIntoConstraints = false

        let avatarContainerView = UIView(frame: CGRect(x: 0, y: 0, width: avatarSize, height: avatarSize))
        avatarContainerView.translatesAutoresizingMaskIntoConstraints = false
        avatarContainerView.addSubview(avatarImage)

        // Adjust the shadow properties to make the item appear even higher
        avatarContainerView.layer.shadowColor = UIColor.black.cgColor
        avatarContainerView.layer.shadowOpacity = 0.3
        avatarContainerView.layer.shadowOffset = CGSize(width: 0, height: 16)
        avatarContainerView.layer.shadowRadius = 24

        contentView.addSubview(avatarContainerView)

        NSLayoutConstraint.activate([
            circleHost.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            circleHost.view.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            blurEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            blurEffectView.leftAnchor.constraint(equalTo: view.leftAnchor),
            blurEffectView.rightAnchor.constraint(equalTo: view.rightAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            avatarContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            avatarContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            avatarContainerView.widthAnchor.constraint(equalToConstant: avatarSize),
            avatarContainerView.heightAnchor.constraint(equalToConstant: avatarSize),

            avatarImage.centerXAnchor.constraint(equalTo: avatarContainerView.centerXAnchor),
            avatarImage.centerYAnchor.constraint(equalTo: avatarContainerView.centerYAnchor),
            avatarImage.widthAnchor.constraint(equalTo: avatarContainerView.widthAnchor),
            avatarImage.heightAnchor.constraint(equalTo: avatarContainerView.heightAnchor)
        ])
    }
    
    private func setupEssentials() {
        let essentialSpacing: CGFloat = -40
        let essentialSize: CGFloat = 144

        let essentials = [userData?.essentialOne, userData?.essentialTwo, userData?.essentialThree]

        for (index, essential) in essentials.enumerated() {
            let essentialContainerView = UIView()
            essentialContainerView.translatesAutoresizingMaskIntoConstraints = false
            essentialContainerView.layer.shadowColor = UIColor.black.cgColor
            essentialContainerView.layer.shadowOpacity = 0.5
            essentialContainerView.layer.shadowOffset = CGSize(width: 0, height: 4)
            essentialContainerView.layer.shadowRadius = 6

            let essentialImageView = UIImageView()
            essentialImageView.translatesAutoresizingMaskIntoConstraints = false
            essentialImageView.contentMode = .scaleAspectFill
            essentialImageView.clipsToBounds = true
            essentialImageView.layer.cornerCurve = .continuous
            essentialImageView.layer.cornerRadius = 20
            essentialImageView.backgroundColor = .black

            if let artworkUrlString = essential?.appleData?.artworkUrl {
                let width = Int(essentialSize)
                let height = Int(essentialSize)
                guard let artworkUrl = URL(string: artworkUrlString.replacingOccurrences(of: "{w}", with: "\(width)").replacingOccurrences(of: "{h}", with: "\(height)")) else { return  }
                essentialImageView.setImage(from: artworkUrl)
            }

            essentialContainerView.addSubview(essentialImageView)
            contentView.addSubview(essentialContainerView)

            let centerXOffset: CGFloat = index % 2 == 0 ? 56 : -56
            let rotationAngle: CGFloat = index % 2 == 0 ? 4 : -4

            essentialContainerView.transform = CGAffineTransform(rotationAngle: rotationAngle * .pi / 180)

            NSLayoutConstraint.activate([
                essentialContainerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: centerXOffset),
                essentialContainerView.widthAnchor.constraint(equalToConstant: essentialSize),
                essentialContainerView.heightAnchor.constraint(equalToConstant: essentialSize),
                essentialContainerView.topAnchor.constraint(equalTo: index == 0 ? view.safeAreaLayoutGuide.topAnchor : contentView.subviews[contentView.subviews.count - 2].bottomAnchor, constant: index == 0 ? 8 : essentialSpacing),

                essentialImageView.leadingAnchor.constraint(equalTo: essentialContainerView.leadingAnchor),
                essentialImageView.trailingAnchor.constraint(equalTo: essentialContainerView.trailingAnchor),
                essentialImageView.topAnchor.constraint(equalTo: essentialContainerView.topAnchor),
                essentialImageView.bottomAnchor.constraint(equalTo: essentialContainerView.bottomAnchor)
            ])
        }
    }
   
    private func setupMetaData() {
        let metadataStackView = UIStackView()
        metadataStackView.axis = .vertical
        metadataStackView.spacing = 8
        metadataStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(metadataStackView)

        let artifactsStackView = createMetadataStackView(heading: "artifacts", statistic: "0")
        let soundsStackView = createMetadataStackView(heading: "sounds", statistic: "0")
        let followersStackView = createMetadataStackView(heading: "followers", statistic: "0")

        metadataStackView.addArrangedSubview(artifactsStackView)
        metadataStackView.addArrangedSubview(soundsStackView)
        metadataStackView.addArrangedSubview(followersStackView)

        NSLayoutConstraint.activate([
            metadataStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            metadataStackView.centerYAnchor.constraint(equalTo: avatarImage.centerYAnchor)
        ])
        
        let spacerView = UIView()
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(spacerView)

        NSLayoutConstraint.activate([
            spacerView.topAnchor.constraint(equalTo: metadataStackView.bottomAnchor),
            spacerView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            spacerView.heightAnchor.constraint(equalToConstant: 500),
            spacerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            spacerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
}

// MARK: Helpers
extension UserScreen {
    private func extractAndDisplayDominantColor() {
            guard let image = avatarImage.image else {
                print("failed")
                return }
            
            dominantColor(from: image) { [weak self] color in
                guard let self = self, let color = color else { return }
                
                DispatchQueue.main.async {
                    let hexString = color.toHexString()
                    self.setupBlurEffect(with: hexString)
                    self.setupEssentials()
                    self.setupMetaData()
                }
            }
        }
    
    private func createMetadataStackView(heading: String, statistic: String) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4

        let headingLabel = UILabel()
        headingLabel.text = heading
        headingLabel.font = UIFont.systemFont(ofSize: 13)
        headingLabel.textColor = .white
        stackView.addArrangedSubview(headingLabel)

        let statisticLabel = UILabel()
        statisticLabel.text = statistic
        statisticLabel.font = UIFont.boldSystemFont(ofSize: 15)
        statisticLabel.textColor = .white
        stackView.addArrangedSubview(statisticLabel)

        return stackView
    }
    
    private func checkImageSet(completion: @escaping () -> Void) {
        DispatchQueue.global().async {
            // Wait until the image is set
            var imageSet = false
            while !imageSet {
                // Pause briefly to avoid busy-waiting
                usleep(100_000) // 0.1 second
                
                // Check if the image is set on the main thread
                DispatchQueue.main.sync {
                    imageSet = self.avatarImage.image != nil
                }
            }
            
            // Once the image is set, call the completion handler on the main thread
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}
