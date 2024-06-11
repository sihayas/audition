//
//  UserScreen.swift
//  Audition
//
//  Created by decoherence on 5/27/24.
//

import UIKit
import SwiftUI

class UserScreen: UIViewController, UIGestureRecognizerDelegate {
    private var scrollView = UIScrollView()
    private var contentView = UIView()
    private var avatarImage = ImageView()
    
    private var userData: APIUser?
    private var userResult: UserResult?
    private var fetchedUserData: APIUser?

    init(userData: APIUser? = nil, userResult: UserResult? = nil) {
        self.userData = userData
        self.userResult = userResult
        super.init(nibName: nil, bundle: nil)
        
        let userIdToFetch = userResult?.id ?? userData?.id
        
        guard let userIdToFetch = userIdToFetch else {
            print("User ID not available")
            return
        }
        
        // Fetch up to date data
        UserAPI.fetchUserData(userId: userIdToFetch, pageUserId: userIdToFetch) { [weak self] result in
            switch result {
            case .success(let userResponse):
                self?.fetchedUserData = userResponse.data
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
        if let imageURL = URL(string: userData?.image ?? "") {
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
        circleHost.view.then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .clear
            $0.layer.masksToBounds = true
            contentView.addSubview($0)
        }.layout {
            $0.centerX == contentView.centerXAnchor
            $0.centerY == contentView.centerYAnchor
        }

        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThickMaterialDark))
        blurEffectView.then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }.layout {
            $0.top == view.topAnchor
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.bottom == view.bottomAnchor
        }
        
        
        let avatarContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        avatarContainerView.translatesAutoresizingMaskIntoConstraints = false
        avatarContainerView.addSubview(avatarImage)

        avatarContainerView.then {
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOpacity = 0.3
            $0.layer.shadowOffset = CGSize(width: 0, height: 16)
            $0.layer.shadowRadius = 24
            contentView.addSubview($0)
        }.layout {
            $0.centerX == contentView.centerXAnchor
            $0.centerY == contentView.centerYAnchor
            $0.width == 70
            $0.height == 70
        }

        avatarImage.then{
            $0.layer.cornerRadius = 70 / 2
            $0.clipsToBounds = true
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }.layout {
            $0.centerX == avatarContainerView.centerXAnchor
            $0.centerY == avatarContainerView.centerYAnchor
            $0.width == avatarContainerView.widthAnchor
            $0.height == avatarContainerView.heightAnchor
        }
    }
    
    private func setupEssentials() {
        let essentialSpacing: CGFloat = -40
        let essentialSize: CGFloat = 144
        
        let essentials = [userData?.essentialOne, userData?.essentialTwo, userData?.essentialThree]
        
        for (index, essential) in essentials.enumerated() {
            let essentialContainerView = UIView()
            essentialContainerView.then {
                $0.translatesAutoresizingMaskIntoConstraints = false
                $0.layer.shadowColor = UIColor.black.cgColor
                $0.layer.shadowOpacity = 0.5
                $0.layer.shadowOffset = CGSize(width: 0, height: 4)
                $0.layer.shadowRadius = 6
                contentView.addSubview($0)
            }.layout {
                let centerXOffset: CGFloat = index % 2 == 0 ? 56 : -56
                $0.centerX == contentView.centerXAnchor + centerXOffset
                $0.width == essentialSize
                $0.height == essentialSize
                
                if index == 0 {
                    $0.top == contentView.safeAreaLayoutGuide.topAnchor + 8
                } else {
                    $0.top == contentView.subviews[contentView.subviews.count - 2].bottomAnchor + essentialSpacing
                }
            }
            
            let rotationAngle: CGFloat = index % 2 == 0 ? 4 : -4
            essentialContainerView.transform = CGAffineTransform(rotationAngle: rotationAngle * .pi / 180)
            
            let essentialImageView = UIImageView()
            essentialImageView.then {
                $0.translatesAutoresizingMaskIntoConstraints = false
                $0.contentMode = .scaleAspectFill
                $0.clipsToBounds = true
                $0.layer.cornerCurve = .continuous
                $0.layer.cornerRadius = 20
                $0.backgroundColor = .black
                essentialContainerView.addSubview($0)
            }.layout {
                $0.leading == essentialContainerView.leadingAnchor
                $0.trailing == essentialContainerView.trailingAnchor
                $0.top == essentialContainerView.topAnchor
                $0.bottom == essentialContainerView.bottomAnchor
            }
            
            if let artworkUrlString = essential?.appleData?.artworkUrl {
                let width = Int(essentialSize)
                let height = Int(essentialSize)
                guard let artworkUrl = URL(string: artworkUrlString.replacingOccurrences(of: "{w}", with: "\(width)").replacingOccurrences(of: "{h}", with: "\(height)")) else { return }
                essentialImageView.setImage(from: artworkUrl)
            }
        }
    }
   
    private func setupMetaData() {
        let metadataStackView = UIStackView()
        metadataStackView.then {
            $0.axis = .vertical
            $0.spacing = 8
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }.layout {
            $0.leading == contentView.leadingAnchor + 24
            $0.centerY == avatarImage.centerYAnchor
        }

        let artifactsStackView = createMetadataStackView(heading: "artifacts", statistic: "0")
        let soundsStackView = createMetadataStackView(heading: "sounds", statistic: "0")
        let followersStackView = createMetadataStackView(heading: "followers", statistic: "0")

        metadataStackView.addArrangedSubview(artifactsStackView)
        metadataStackView.addArrangedSubview(soundsStackView)
        metadataStackView.addArrangedSubview(followersStackView)

        let spacerView = UIView()
        spacerView.then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }.layout {
            $0.top == metadataStackView.bottomAnchor
            $0.width == contentView.widthAnchor
            $0.height == 500
            $0.centerX == contentView.centerXAnchor
            $0.bottom == contentView.bottomAnchor
        }
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
