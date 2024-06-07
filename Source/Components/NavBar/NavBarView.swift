import UIKit
import CoreData
import SwiftUI

class NavBar: UIView, UIGestureRecognizerDelegate, UISearchBarDelegate {
    // show search sheet
    var onPresentSearchScreen: (() -> Void)?
    private var isPresentingSearchScreen = false
    
    // handle dynamic sizing
    var height: Double = 32
    var cornerRadius: Double = 16
    
    var isExpanded: Bool = false {
        didSet {
            let cornerRadiusAnimation = CABasicAnimation(keyPath: "cornerRadius")
            cornerRadiusAnimation.fromValue = containerView.layer.cornerRadius
            cornerRadiusAnimation.toValue = isExpanded ? cornerRadius : 16
            cornerRadiusAnimation.duration = 0.5
            cornerRadiusAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            containerView.layer.cornerRadius = isExpanded ? cornerRadius : 16
            containerView.layer.add(cornerRadiusAnimation, forKey: "cornerRadiusAnimation")
            
            searchBar.isUserInteractionEnabled = isExpanded
            
            if (isExpanded) {
                if !isPresentingSearchScreen {
                    self.onPresentSearchScreen?()
                    isPresentingSearchScreen = true
                }
                self.searchBar.searchTextField.becomeFirstResponder()
                self.searchBarBottomCnst.constant = 8
            } else {
                isPresentingSearchScreen = false
                self.searchBar.searchTextField.resignFirstResponder()
                self.searchBarBottomCnst.constant = 16
            }
            
            self.containerHeightCnst.constant = isExpanded ? height : 32
            self.containerLeadingCnst.constant = isExpanded ? 16 : 165
            self.containerTrailingCnst.constant = isExpanded ? -16 : -165
            
            let scale = isExpanded ? CGAffineTransform(scaleX: 0, y: 0) : CGAffineTransform(scaleX: 1, y: 1)
            
            UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.curveEaseInOut], animations: {
                self.notificationButton?.transform = scale
                self.userImageView?.transform = scale
                self.layoutIfNeeded()
            }, completion: { _ in
                self.viewHeightCnst.constant = self.isExpanded ? self.height : 32
            })
        }
    }
    
    var user: User
    var searchModel: SearchModel?
    var userImageView: UIImageView?
    private var selectedSearchResultObserver: NSObjectProtocol?
    
    // initial setup views
    private var containerView: UIView!
    private var searchBar: UISearchBar!
    private var defaultSearchIcon: UIImage?
    private var storedSearchText: String?
    private var notificationButton: UIButton!
    private var avatarButton: AvatarView?
    
    // form views
    private var dialView: DialView?
    private var artworkImageView: UIImageView?
    private var rating: Int = 0

    private var viewHeightCnst: NSLayoutConstraint! // Outer Container
    private var containerHeightCnst: NSLayoutConstraint! // Inner Container/Background
    private var containerLeadingCnst: NSLayoutConstraint!
    private var containerTrailingCnst: NSLayoutConstraint!
    private var viewBottomCnst: NSLayoutConstraint!
    
    private var searchBarBottomCnst: NSLayoutConstraint!

    init(user: User) {
        self.user = user
        super.init(frame: .zero)
        setupSearchBar()
        setupAvatar(imageUrl: self.user.image ?? "")
        setupNotification()
        setupKeyboardObservers()
        setupSelectedSearchResultObserver()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        guard let superview = superview else { return }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        viewBottomCnst = bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -32)
        viewBottomCnst?.isActive = true
        
        viewHeightCnst = heightAnchor.constraint(equalToConstant: height)
        viewHeightCnst?.isActive = true
        
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor),
        ])
    }
    
    private func setupSearchBar() {
        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.clipsToBounds = false
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.4
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowRadius = 8
        containerView.backgroundColor = .black
        containerView.layer.cornerRadius = cornerRadius
        containerView.layer.cornerCurve = .continuous
        
        searchBar = UISearchBar()
        searchBar.placeholder = "Arwen"
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.backgroundColor = .clear
        searchBar.searchTextField.font = .systemFont(ofSize: 15)
        searchBar.isUserInteractionEnabled = false
        searchBar.backgroundColor = .clear
        searchBar.delegate = self
        searchBar.searchTextField.textColor = .white.withAlphaComponent(0.75)
        if let iconImageView = searchBar.searchTextField.leftView as? UIImageView {
            defaultSearchIcon = iconImageView.image
        }
        containerView.addSubview(searchBar)
        addSubview(containerView)
        
        addGestures()
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchTextField.translatesAutoresizingMaskIntoConstraints = false
        
        containerHeightCnst = containerView.heightAnchor.constraint(equalToConstant: height)
        containerLeadingCnst = containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 165)
        containerTrailingCnst = containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -165)
        searchBarBottomCnst = searchBar.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 16)
        
        NSLayoutConstraint.activate([
            containerLeadingCnst,
            containerTrailingCnst,
            containerHeightCnst,
            searchBarBottomCnst,
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            searchBar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            searchBar.searchTextField.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),
            searchBar.searchTextField.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor, constant: 8),
            searchBar.searchTextField.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor, constant: -8)
        ])
    }
    
    private func setupNotification() {
        notificationButton = UIButton()
        notificationButton.translatesAutoresizingMaskIntoConstraints = false
        notificationButton.layer.shadowColor = UIColor.black.cgColor
        notificationButton.layer.shadowOpacity = 0.2
        notificationButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        notificationButton.layer.shadowRadius = 4
    
        let blackView = UIView()
        blackView.translatesAutoresizingMaskIntoConstraints = false
        blackView.layer.cornerRadius = 16
        blackView.layer.cornerCurve = .continuous
        blackView.clipsToBounds = true
        blackView.backgroundColor = UIColor.black
        blackView.layer.borderColor = UIColor.white.withAlphaComponent(0.05).cgColor
        blackView.layer.borderWidth = 1
    
        let dotView = UIView()
        dotView.translatesAutoresizingMaskIntoConstraints = false
        dotView.backgroundColor = .white
        dotView.layer.cornerRadius = 4
        dotView.alpha = 0.75
    
        notificationButton.addSubview(blackView)
        notificationButton.addSubview(dotView)
    
        addSubview(notificationButton)
    
        NSLayoutConstraint.activate([
            notificationButton.trailingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: -8),
            notificationButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            notificationButton.widthAnchor.constraint(equalToConstant: 32),
            notificationButton.heightAnchor.constraint(equalToConstant: 32),
            blackView.topAnchor.constraint(equalTo: notificationButton.topAnchor),
            blackView.leadingAnchor.constraint(equalTo: notificationButton.leadingAnchor),
            blackView.trailingAnchor.constraint(equalTo: notificationButton.trailingAnchor),
            blackView.bottomAnchor.constraint(equalTo: notificationButton.bottomAnchor),
            dotView.centerXAnchor.constraint(equalTo: notificationButton.centerXAnchor),
            dotView.centerYAnchor.constraint(equalTo: notificationButton.centerYAnchor)
        ])
    }
    
    private func setupAvatar(imageUrl: String) {
        let avatarView = AvatarView(imageUrl: imageUrl)
        let hostingController = UIHostingController(rootView: avatarView)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear
        
        addSubview(hostingController.view)
        
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 8),
            hostingController.view.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }

    deinit {
        if let observer = selectedSearchResultObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

}

// MARK: Form Context Animations

extension NavBar {
    // if a search result is selected
    private func setupSelectedSearchResultObserver() {
        selectedSearchResultObserver = NotificationCenter.default.addObserver(forName: .selectedSearchResultDidChange, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            let selectedSound = NavBarManager.shared.selectedSearchResult != nil
            if (selectedSound){
                cornerRadius = 32
                height = 456
                isExpanded = true
            } else {
                cornerRadius = 18
                height = 48
                createForm(selectedSound: false)
                isExpanded = true
            }
            self.createForm(selectedSound: selectedSound)
        }
    }
    
    private func createForm(selectedSound: Bool) {
        if selectedSound, let searchResult = NavBarManager.shared.selectedSearchResult {
            var artworkURL: URL?
            var albumName: String?
            var artistName: String?
            
            switch searchResult {
            case .song(let song):
                artworkURL = URL(string: song.attributes.artwork.url.replacingOccurrences(of: "{w}x{h}", with: "800x800"))
                albumName = song.attributes.albumName
                artistName = song.attributes.artistName
            case .album(let album):
                artworkURL = URL(string: album.attributes.artwork.url.replacingOccurrences(of: "{w}x{h}", with: "800x800"))
                albumName = album.attributes.name
                artistName = album.attributes.artistName
            case .user:
                break
            }
            
            if let artworkURL = artworkURL {
                URLSession.shared.dataTask(with: artworkURL) { [weak self] (data, response, error) in
                    if let data = data, let image = UIImage(data: data), let self = self {
                        DispatchQueue.main.async {
                            let hostingController = UIHostingController(rootView: ArtworkImageView(image: image, albumName: albumName ?? "Unknown Album", artistName: artistName ?? "Unknown Artist"))
                            hostingController.view.frame = CGRect(x: 0, y: 0, width: 332, height: 332)
                            hostingController.view.backgroundColor = .clear
                            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
                            hostingController.view.tag = 999
                            
                            self.storedSearchText = self.searchBar.text
                            self.searchBar.text = ""
                            
                            // Add caret icon
                            let customIcon = UIImage(named: "caret")?.withRenderingMode(.alwaysTemplate)
                            let iconImageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 18, height: 18)))
                            iconImageView.contentMode = .scaleAspectFit
                            iconImageView.image = customIcon
                            iconImageView.tintColor = .secondaryLabel
                            let containerView = UIView(frame: iconImageView.frame)
                            containerView.addSubview(iconImageView)
                            self.searchBar.searchTextField.leftView = containerView
                            self.searchBar.searchTextField.leftViewMode = .always
                            
                            // Add long press gesture
                            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(_:)))
                            longPressGesture.minimumPressDuration = 0.25
                            hostingController.view.addGestureRecognizer(longPressGesture)
                            hostingController.view.isUserInteractionEnabled = true
                            
                            // Add send button
                            let sendButton = UIButton(type: .system)
                            sendButton.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
                            sendButton.tintColor = .secondaryLabel
                            sendButton.translatesAutoresizingMaskIntoConstraints = false
                            sendButton.tag = 999
                            sendButton.addAction(UIAction { [weak self] _ in
                                guard let self = self, var userId = self.user.id else { return }
                                userId = userId.trimmingCharacters(in: .whitespacesAndNewlines)
                                userId = userId.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                                let text = self.searchBar.text ?? ""
                                let simpleSoundable = SimpleSoundable(searchResult: searchResult)
                                
                                PostAPI.submitPost(text: text, rating: self.rating, userId: userId, sound: simpleSoundable) { result in
                                    DispatchQueue.main.async {
                                        if case .success = result {
                                            self.searchBar.text = ""
                                            self.rating = 0
                                            NavBarManager.shared.selectedSearchResult = nil
                                        }
                                    }
                                }
                            }, for: .touchUpInside)
                            
                            self.searchBar.addSubview(sendButton)
                            self.containerView.addSubview(hostingController.view)
                            
                            NSLayoutConstraint.activate([
                                hostingController.view.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor),
                                hostingController.view.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 56),
                                hostingController.view.widthAnchor.constraint(equalToConstant: 334),
                                hostingController.view.heightAnchor.constraint(equalToConstant: 334),
                                sendButton.trailingAnchor.constraint(equalTo: self.searchBar.trailingAnchor, constant: -12),
                                sendButton.centerYAnchor.constraint(equalTo: self.searchBar.centerYAnchor),
                                sendButton.widthAnchor.constraint(equalToConstant: 24),
                                sendButton.heightAnchor.constraint(equalToConstant: 24)
                            ])
                            
                            hostingController.view.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                            hostingController.view.alpha = 0
                            UIView.animate(withDuration: 3, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 2, options: [.curveEaseOut]) {
                                hostingController.view.transform = .identity
                                hostingController.view.alpha = 1
                            }
                        }
                    }
                }.resume()
            }
        } else {
            if let containerView = containerView.viewWithTag(999) {
                UIView.animate(withDuration: 0.3, animations: {
                    containerView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                    containerView.alpha = 0.0
                }) { _ in
                    containerView.removeFromSuperview()
                }
            }

            if let defaultIcon = defaultSearchIcon {
                let iconImageView = UIImageView(image: defaultIcon)
                iconImageView.tintColor = .secondaryLabel
                iconImageView.frame = CGRect(x: 0, y: 0, width: 18, height: 16)
                searchBar.searchTextField.leftView = iconImageView
            }

            searchBar.text = storedSearchText

            // Remove the send icon if it exists
            if let sendButton = searchBar.viewWithTag(999) as? UIButton {
                sendButton.removeFromSuperview()
            }
        }
    }
}

// MARK: Animations/Gestures

extension NavBar {
    private func addGestures() {
        self.containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapInside)))
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown))
        swipeDownGesture.direction = .down
        self.containerView.addGestureRecognizer(swipeDownGesture)
    }
    
    @objc private func handleTapInside(_ gesture: UITapGestureRecognizer) {
        cornerRadius = cornerRadius == 16 ? 18 : cornerRadius
        height = height == 32 ? 48 : height
        isExpanded = true
    }

    // Collapsing logic
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if superview != nil {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutside(_:)))
            tapGesture.cancelsTouchesInView = false
            superview?.addGestureRecognizer(tapGesture)
        }
    }
    @objc private func handleTapOutside(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        if !bounds.contains(location) {
            isExpanded = false
        }
    }
    @objc private func handleSwipeDown(_ gesture: UISwipeGestureRecognizer) {
        if NavBarManager.shared.selectedSearchResult != nil {
            NavBarManager.shared.selectedSearchResult = nil
        }
    }
    @objc func collapseSearchBar() {
        isExpanded = false
    }

    
    // Translating logic
    @objc private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.3
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: [.beginFromCurrentState], animations: { [weak self] in
            self?.viewBottomCnst?.constant = -keyboardHeight - 16
            self?.superview?.layoutIfNeeded()
        }, completion: nil)
    }
    @objc private func keyboardWillHide(_ notification: Notification) {
        let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.3
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: [.beginFromCurrentState], animations: { [weak self] in
            self?.viewBottomCnst?.constant = -32
            self?.superview?.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc private func avatarButtonTapped() {
        guard let username = user.username,
              let image = user.image else {
            return
        }
        
        user.username = username.trimmingCharacters(in: .whitespacesAndNewlines)
        user.username = username.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        
        user.image = image.trimmingCharacters(in: .whitespacesAndNewlines)
        user.image = image.trimmingCharacters(in: CharacterSet(charactersIn: "\""))

        NavigationManager.shared.navigateToUserScreen(withDetails: user)
    }
    
    // Rating dial
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: containerView)
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
        addSubview(dial)
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
            rating = -1
            print(rating)
        case 1:
            rating = 0
            print(rating)
        case 2:
            rating = 1
            print(rating)
        default:
            break
        }
    }
}


// MARK: Search Input Behaviour

extension NavBar {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if NavBarManager.shared.selectedSearchResult == nil {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(performSearch), object: nil)
            self.perform(#selector(performSearch), with: nil)
        }
    }
    
    @objc private func performSearch() {
        if NavBarManager.shared.selectedSearchResult == nil {
            self.searchModel?.search(query: self.searchBar.text ?? "")
        }
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if NavBarManager.shared.selectedSearchResult != nil {
            printSearchText(searchBar.text)
        } else {
            
        }
    }
    
    private func printSearchText(_ text: String?) {
        guard let text = text, !text.isEmpty else {
            return
        }
    }
    
}

//
//
