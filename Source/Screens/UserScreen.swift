//
//  UserScreen.swift
//  InstagramTransition
//
//  Created by decoherence on 5/12/24.
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
        AuthUserAPI.fetchUserData(userId: userId) { [weak self] result in
            switch result {
            case .success(let userResponse):
                self?.userData = userResponse.data
                print("found user \(userResponse.data)")
                
                DispatchQueue.main.async {
                           self?.setupEssentials()
                       }
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
        setupMetaData()
        setupCards()
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
    
    private func extractAndDisplayDominantColor() {
            guard let image = avatarImage.image else { 
                print("failed")
                return }
            
            dominantColor(from: image) { [weak self] color in
                guard let self = self, let color = color else { return }
                
                DispatchQueue.main.async {
                    let hexString = color.toHexString()
                    self.setupBlurEffect(with: hexString)
                }
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
        contentView.addSubview(avatarImage)
        
        NSLayoutConstraint.activate([
            circleHost.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            circleHost.view.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            blurEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            blurEffectView.leftAnchor.constraint(equalTo: view.leftAnchor),
            blurEffectView.rightAnchor.constraint(equalTo: view.rightAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            avatarImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            avatarImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            avatarImage.widthAnchor.constraint(equalToConstant: avatarSize),
            avatarImage.heightAnchor.constraint(equalToConstant: avatarSize)
        ])
    }
    
    private func setupEssentials() {
        let essentialSpacing: CGFloat = -32
        let essentialSize: CGFloat = 144
        
        for i in 0..<3 {
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
            
            if let userData = userData,
               let essential = userData.essentials.first(where: { $0.rank == i }),
               let artworkURL = essential.soundData.formattedArtworkUrl {
                essentialImageView.setImage(from: artworkURL)
            }
            
            essentialContainerView.addSubview(essentialImageView)
            contentView.addSubview(essentialContainerView)
            
            let centerXOffset: CGFloat = i % 2 == 0 ? 48 : -48
            let rotationAngle: CGFloat = i % 2 == 0 ? 4 : -4
            
            essentialContainerView.transform = CGAffineTransform(rotationAngle: rotationAngle * .pi / 180)
            
            NSLayoutConstraint.activate([
                essentialContainerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: centerXOffset),
                essentialContainerView.widthAnchor.constraint(equalToConstant: essentialSize),
                essentialContainerView.heightAnchor.constraint(equalToConstant: essentialSize),
                essentialContainerView.topAnchor.constraint(equalTo: i == 0 ? view.safeAreaLayoutGuide.topAnchor : contentView.subviews[contentView.subviews.count - 2].bottomAnchor, constant: i == 0 ? 0 : essentialSpacing),
                
                essentialImageView.leadingAnchor.constraint(equalTo: essentialContainerView.leadingAnchor),
                essentialImageView.trailingAnchor.constraint(equalTo: essentialContainerView.trailingAnchor),
                essentialImageView.topAnchor.constraint(equalTo: essentialContainerView.topAnchor),
                essentialImageView.bottomAnchor.constraint(equalTo: essentialContainerView.bottomAnchor)
            ])
        }
    }
   
    private func setupMetaData() {
    }
    
    private func setupCards() {
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
