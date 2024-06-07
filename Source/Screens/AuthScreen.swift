//
//  AuthScreen.swift
//  InstagramTransition
//
//  Created by decoherence on 5/18/24.
//

//
//  SoundScreen.swift
//  InstagramTransition
//
//  Created by decoherence on 5/9/24.
//

import UIKit
import SwiftUI
import AuthenticationServices


class AuthScreen: UIViewController, UIGestureRecognizerDelegate {
    private var scrollView = UIScrollView()
    private var contentView = UIView()
    private let signInWithAppleButton = ASAuthorizationAppleIDButton()
    private let cardView = UIView()

    init() {
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
        setupCard()
        setupAppleSignInButton()
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
        let circleView = CircleView(hexColor: "FFFFFF", width: 760, height: 760, startRadius: 0, endRadius: 760)
        let circleHost = UIHostingController(rootView: circleView)
        circleHost.view.backgroundColor = .clear
        circleHost.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(circleHost.view)
        NSLayoutConstraint.activate([
            circleHost.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            circleHost.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThickMaterialDark))
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(blurEffectView)
        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            blurEffectView.leftAnchor.constraint(equalTo: view.leftAnchor),
            blurEffectView.rightAnchor.constraint(equalTo: view.rightAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupCard() {
        cardView.layer.cornerRadius = 32
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
            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.widthAnchor.constraint(equalToConstant: 256),
            cardView.heightAnchor.constraint(equalToConstant: 360)
        ])

        let bodyTextLabel = UILabel()
        bodyTextLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyTextLabel.backgroundColor = .clear
        bodyTextLabel.font = .systemFont(ofSize: 15, weight: .medium)
        bodyTextLabel.text = "Seemed interesting from the feature list and jean's admittedly cool art direction, but sadly this is kinda more tiktok zoomer not-rly-indie diet-alternative pop ... maybe a hair more interesting production-wise?? still, every time i hear this record's execution of lowest common denominator whoa-oh passages i cringe so hard, plus jean's delivery across the board comes across wicked corny. not the worst album of the year, but about as middle-of-the-road as u can get. i'm gettin too old for this shit lmao. why bill yrself as a genre-blending artist if yr "
        bodyTextLabel.numberOfLines = 16
        bodyTextLabel.alpha = 0.9
        bodyTextLabel.textAlignment = .left
        cardView.addSubview(bodyTextLabel)

        NSLayoutConstraint.activate([
            bodyTextLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            bodyTextLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            bodyTextLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24)
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
            ratingHost.view.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            ratingHost.view.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -24),
            ratingHost.view.widthAnchor.constraint(equalToConstant: 20),
            ratingHost.view.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        let avatar = UIImageView()
        avatar.layer.cornerRadius = 20
        avatar.layer.borderColor = UIColor.systemGray6.cgColor
        avatar.layer.borderWidth = 2
        avatar.clipsToBounds = true
        avatar.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(avatar)

        NSLayoutConstraint.activate([
            avatar.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: 8),
            avatar.topAnchor.constraint(equalTo: cardView.topAnchor, constant: -8),
            avatar.widthAnchor.constraint(equalToConstant: 40),
            avatar.heightAnchor.constraint(equalToConstant: 40)
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
    
    private func setupAppleSignInButton() {

        let buttonContainer = UIView()
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(buttonContainer)
        

        let buttonSize: CGFloat = 64
        NSLayoutConstraint.activate([
            buttonContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            buttonContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonContainer.heightAnchor.constraint(equalToConstant: buttonSize)
            // Remove the width constraint
        ])
        

        buttonContainer.layer.cornerRadius = buttonSize / 2
        buttonContainer.layer.backgroundColor = UIColor.init(hex: "#1C1C1E")?.cgColor
        buttonContainer.clipsToBounds = true
        

        let signInWithAppleButton = ASAuthorizationAppleIDButton()
        signInWithAppleButton.translatesAutoresizingMaskIntoConstraints = false
        buttonContainer.addSubview(signInWithAppleButton)
        
        
        NSLayoutConstraint.activate([
            signInWithAppleButton.topAnchor.constraint(equalTo: buttonContainer.topAnchor),
            signInWithAppleButton.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor),
            signInWithAppleButton.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor),
            signInWithAppleButton.trailingAnchor.constraint(equalTo: buttonContainer.trailingAnchor)
        ])
        

        let appleLogoImageView = UIImageView(image: UIImage(systemName: "applelogo"))
        appleLogoImageView.translatesAutoresizingMaskIntoConstraints = false
        appleLogoImageView.contentMode = .scaleAspectFit
        appleLogoImageView.tintColor = .white
        buttonContainer.addSubview(appleLogoImageView)
        

        NSLayoutConstraint.activate([
            appleLogoImageView.centerXAnchor.constraint(equalTo: buttonContainer.centerXAnchor),
            appleLogoImageView.centerYAnchor.constraint(equalTo: buttonContainer.centerYAnchor),
            appleLogoImageView.heightAnchor.constraint(equalToConstant: 32),
            appleLogoImageView.widthAnchor.constraint(equalToConstant: 32)
        ])
        

        signInWithAppleButton.addTarget(self, action: #selector(handleAppleSignIn), for: .touchUpInside)
    }
    
    @objc private func handleAppleSignIn() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

extension AuthScreen: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let identityToken = appleIDCredential.identityToken,
                  let authorizationCode = appleIDCredential.authorizationCode,
                  let idTokenString = String(data: identityToken, encoding: .utf8),
                  let authCodeString = String(data: authorizationCode, encoding: .utf8) else {
                print("Failed to decode identityToken or authorizationCode")
                return
            }
            
            let baseURL = "http://192.168.1.249:8000"

            let backendURL = URL(string: "\(baseURL)/_allauth/app/v1/auth/provider/token")!
            var request = URLRequest(url: backendURL)
            
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let parameters: [String: Any] = [
                "provider": "apple",
                "process": "login",
                "token": [
                    "client_id": "space.voir.voir",
                    "id_token": idTokenString,
                    "code": authCodeString,
                ]
            ]

            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                print("Error encoding parameters: \(error.localizedDescription)")
                return
            }
            
            // Validate body
            if let body = request.httpBody {
                print("Body: \(String(data: body, encoding: .utf8) ?? "Invalid body")")
            }

            // Send authentication request
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error sending request to backend: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                                print("Invalid response from backend")
                                return
                            }
                
                // Partial success, Apple Token authenticated, prompt for username
                if httpResponse.statusCode == 401 {
                    DispatchQueue.main.async {
                        print("Success, init sign up flow \(httpResponse.statusCode)")
                        if let data = data, let responseString = String(data: data, encoding: .utf8) {
                            print("Response body: \(responseString)")
                            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                               let meta = json["meta"] as? [String: Any],
                               let sessionToken = meta["session_token"] as? String {
                                self.promptForUsername(baseURL: baseURL, sessionToken: sessionToken)
                            }
                        }
                    }
                // Success/User exists, store session in keychain
                } else if (200...299).contains(httpResponse.statusCode) {
                    print("Success, signing user in: \(httpResponse.statusCode)")
                    self.handleSuccessfulResponse(data: data)
                // Error/Failed to create a user
                } else {
                    print("Backend returned an error: \(httpResponse.statusCode)")
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        print("Response body: \(responseString)")
                    }
                }
            }
            task.resume()
        }
    }
    
    // MARK: 200 - Successful sign-in.
    private func handleSuccessfulResponse(data: Data?) {
        guard let data = data else {
            return
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let data = json["data"] as? [String: Any],
               let userDict = data["user"] as? [String: Any],
               let meta = json["meta"] as? [String: Any],
               let sessionToken = meta["session_token"] as? String,
               let authUserId = userDict["id"] as? Int {
               print("Session Token: \(sessionToken), User Data: \(userDict)")
               
                DispatchQueue.main.async {
                    let session = Session(context: CoreDataStack.shared.managedContext)
                    session.sessionToken = sessionToken
                    session.authUserId = String(authUserId)
                    
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        appDelegate.digitize()
                    }
                }
            }
        } catch {
            print("Error parsing JSON response: \(error.localizedDescription)")
        }
    }
    
    //MARK: 401 - Successful authentication, prompt for username
    private func promptForUsername(baseURL: String, sessionToken: String) {
            let alert = UIAlertController(title: "Enter Username", message: nil, preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = "Username"
            }
            let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak alert] _ in
                guard let self = self, let textField = alert?.textFields?.first, let username = textField.text else { return }
                self.submitUsername(baseURL: baseURL, username: username, sessionToken: sessionToken)
            }
            alert.addAction(submitAction)
            self.present(alert, animated: true, completion: nil)
        }

    private func submitUsername(baseURL: String, username: String,  sessionToken: String) {
        let signupURL = URL(string: "\(baseURL)/_allauth/app/v1/auth/provider/signup")!
        var request = URLRequest(url: signupURL)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(sessionToken, forHTTPHeaderField: "X-Session-Token")

        let parameters: [String: Any] = [
            "username": username
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Error encoding parameters: \(error.localizedDescription)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending request to backend: \(error.localizedDescription)")
                return
            }
            
            // Successfully created user
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("Successfully created new user: \(responseString)")
                }
                return
            }

            self.handleSuccessfulResponse(data: data)
        }
        task.resume()
    }


    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Authorization failed: \(error.localizedDescription)")
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
