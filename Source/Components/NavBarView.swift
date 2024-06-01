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
            
            self.viewHeightCnst.constant = isExpanded ? height : 32
            self.containerHeightCnst.constant = isExpanded ? height : 32
            self.containerLeadingCnst.constant = isExpanded ? 16 : 165
            self.containerTrailingCnst.constant = isExpanded ? -16 : -165
            
            let scale = isExpanded ? CGAffineTransform(scaleX: 0, y: 0) : CGAffineTransform(scaleX: 1, y: 1)
            
            UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.curveEaseInOut], animations: {
                self.notificationButton?.transform = scale
                self.userImageView?.transform = scale
                self.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    var user: User
    var searchModel: SearchModel?
    var userImageView: UIImageView?
    private var selectedSearchResultObserver: NSObjectProtocol?
    
    private var containerView: UIView!
    private var searchBar: UISearchBar!
    private var defaultSearchIcon: UIImage?
    private var storedSearchText: String?
    private var notificationButton: UIButton!
    private var avatarButton: UIButton?
    private var dialView: DialView?
    
    private var artworkImageView: UIImageView?

    private var viewHeightCnst: NSLayoutConstraint! // Outer Container
    private var containerHeightCnst: NSLayoutConstraint! // Inner Container/Background
    private var containerLeadingCnst: NSLayoutConstraint!
    private var containerTrailingCnst: NSLayoutConstraint!
    private var containerBottomCnst: NSLayoutConstraint!
    
    private var searchBarBottomCnst: NSLayoutConstraint!

    init(user: User) {
        self.user = user
        super.init(frame: .zero)
        setupSearchBar()
//        setupAvatar(imageUrl: self.user.image)
//        setupNotification()
        setupKeyboardObservers()
        setupSelectedSearchResultObserver()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func fetchAuthUser(userId: String) -> User? {
        let fetchRequest = NSFetchRequest<User>(entityName: "User")
        fetchRequest.predicate = NSPredicate(format: "id == %@", userId)
        return try? CoreDataStack.shared.managedContext.fetch(fetchRequest).first
    }
    
    func setupConstraints() {
        guard let superview = superview else { return }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        containerBottomCnst = bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -32)
        containerBottomCnst?.isActive = true
        
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
    
    deinit {
        if let observer = selectedSearchResultObserver {
            NotificationCenter.default.removeObserver(observer)
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
            self?.containerBottomCnst?.constant = -keyboardHeight - 16
            self?.superview?.layoutIfNeeded()
        }, completion: nil)
    }
    @objc private func keyboardWillHide(_ notification: Notification) {
        let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.3
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: [.beginFromCurrentState], animations: { [weak self] in
            self?.containerBottomCnst?.constant = -32
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


// MARK: Dynamic Context Animations

extension NavBar {
    // if a search result is selected
    private func setupSelectedSearchResultObserver() {
        selectedSearchResultObserver = NotificationCenter.default.addObserver(forName: .selectedSearchResultDidChange, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            let selectedSound = NavBarManager.shared.selectedSearchResult != nil
            if (selectedSound){
                cornerRadius = 32
                height = 440
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
        if selectedSound {
            if let searchResult = NavBarManager.shared.selectedSearchResult,
                case let .song(song) = searchResult,
                let artworkURL = URL(string: song.attributes.artwork.url.replacingOccurrences(of: "{w}x{h}", with: "800x800")) {
                
                let task = URLSession.shared.dataTask(with: artworkURL) { [weak self] (data, response, error) in
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            let albumName = song.attributes.albumName ?? "Unknown Album"
                            let artistName = song.attributes.artistName
                            
                            let hostingController = UIHostingController(rootView: ArtworkImageView(image: image, albumName: albumName, artistName: artistName))
                            hostingController.view.frame = CGRect(x: 0, y: 0, width: 334, height: 334)
                            hostingController.view.backgroundColor = .clear
                            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
                            hostingController.view.tag = 999
                            
                            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self?.handleLongPress(_:)))
                            longPressGesture.minimumPressDuration = 0.25
                            hostingController.view.addGestureRecognizer(longPressGesture)
                            hostingController.view.isUserInteractionEnabled = true
                            
                            self?.containerView.addSubview(hostingController.view)
                            
                            NSLayoutConstraint.activate([
                                hostingController.view.centerXAnchor.constraint(equalTo: self?.containerView.centerXAnchor ?? NSLayoutXAxisAnchor()),
                                hostingController.view.topAnchor.constraint(equalTo: self?.containerView.topAnchor ?? NSLayoutYAxisAnchor(), constant: 48),
                                hostingController.view.widthAnchor.constraint(equalToConstant: 334),
                                hostingController.view.heightAnchor.constraint(equalToConstant: 334)
                            ])
                            
                            hostingController.view.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                            hostingController.view.alpha = 0
                            
                            UIView.animate(
                                withDuration: 3,
                                delay: 0,
                                usingSpringWithDamping: 0.7,
                                initialSpringVelocity: 0,
                                options: [.curveEaseOut],
                                animations: {
                                    hostingController.view.transform = CGAffineTransform(scaleX: 1, y: 1)
                                    hostingController.view.alpha = 1
                                }
                            )
                            
                            self?.storedSearchText = self?.searchBar.text
                            self?.searchBar.text = ""
                            
                            let configuration = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
                            let customIcon = UIImage(systemName: "pencil", withConfiguration: configuration)
                            let iconImageView = UIImageView(image: customIcon)
                            iconImageView.tintColor = UIColor.secondaryLabel
                            self?.searchBar.searchTextField.leftView = iconImageView
                        }
                    }
                }
                task.resume()
            }
        } else {
            if let viewToRemove = containerView.viewWithTag(999) {
                viewToRemove.removeFromSuperview()
            }
        
            if let defaultIcon = defaultSearchIcon {
                let iconImageView = UIImageView(image: defaultIcon)
                iconImageView.tintColor = UIColor.secondaryLabel
                iconImageView.frame = CGRect(x: 0, y: 0, width: 18, height: 16)
                searchBar.searchTextField.leftView = UIView(frame: iconImageView.frame)
                searchBar.searchTextField.leftView?.addSubview(iconImageView)
            }
            
            searchBar.text = storedSearchText
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
    
    @objc private func performSearch() {
        if NavBarManager.shared.selectedSearchResult == nil {
            self.searchModel?.search(query: self.searchBar.text ?? "")
        }
    }
}

//
//
//private func setupNotification() {
//    notificationButton = UIButton()
//    notificationButton.translatesAutoresizingMaskIntoConstraints = false
//    notificationButton.layer.shadowColor = UIColor.black.cgColor
//    notificationButton.layer.shadowOpacity = 0.2
//    notificationButton.layer.shadowOffset = CGSize(width: 0, height: 2)
//    notificationButton.layer.shadowRadius = 4
//    
//    let blackView = UIView()
//    blackView.translatesAutoresizingMaskIntoConstraints = false
//    blackView.layer.cornerRadius = 16
//    blackView.layer.cornerCurve = .continuous
//    blackView.clipsToBounds = true
//    blackView.backgroundColor = UIColor.black
//    blackView.layer.borderColor = UIColor.white.withAlphaComponent(0.05).cgColor
//    blackView.layer.borderWidth = 1
//    
//    let dotView = UIView()
//    dotView.translatesAutoresizingMaskIntoConstraints = false
//    dotView.backgroundColor = .white
//    dotView.layer.cornerRadius = 4
//    dotView.alpha = 0.75
//    
//    notificationButton.addSubview(blackView)
//    notificationButton.addSubview(dotView)
//
//    addSubview(notificationButton)
//    
//    NSLayoutConstraint.activate([
//        notificationButton.trailingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: -8),
//        notificationButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
//        notificationButton.widthAnchor.constraint(equalToConstant: 32),
//        notificationButton.heightAnchor.constraint(equalToConstant: 32),
//        blackView.topAnchor.constraint(equalTo: notificationButton.topAnchor),
//        blackView.leadingAnchor.constraint(equalTo: notificationButton.leadingAnchor),
//        blackView.trailingAnchor.constraint(equalTo: notificationButton.trailingAnchor),
//        blackView.bottomAnchor.constraint(equalTo: notificationButton.bottomAnchor),
//        dotView.centerXAnchor.constraint(equalTo: notificationButton.centerXAnchor),
//        dotView.centerYAnchor.constraint(equalTo: notificationButton.centerYAnchor)
//    ])
//}
//
//private func setupAvatar(imageUrl: String?) {
//    avatarButton = UIButton()
//    avatarButton?.translatesAutoresizingMaskIntoConstraints = false
//    avatarButton?.layer.shadowColor = UIColor.black.cgColor
//    avatarButton?.layer.shadowOpacity = 0.2
//    avatarButton?.layer.shadowOffset = CGSize(width: 0, height: 2)
//    avatarButton?.layer.shadowRadius = 4
//    
//    avatarButton?.addTarget(self, action: #selector(avatarButtonTapped), for: .touchUpInside)
//    
//    userImageView = UIImageView()
//    userImageView?.translatesAutoresizingMaskIntoConstraints = false
//    userImageView?.layer.cornerRadius = 16
//    userImageView?.clipsToBounds = true
//    userImageView?.layer.borderColor = UIColor.white.withAlphaComponent(0.05).cgColor
//    userImageView?.layer.borderWidth = 1
//    
//    if let avatarButton = avatarButton {
//        addSubview(avatarButton)
//        avatarButton.addSubview(userImageView!)
//        
//        NSLayoutConstraint.activate([
//            avatarButton.leadingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 8),
//            avatarButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
//            avatarButton.widthAnchor.constraint(equalToConstant: 32),
//            avatarButton.heightAnchor.constraint(equalToConstant: 32),
//            
//            userImageView!.topAnchor.constraint(equalTo: avatarButton.topAnchor),
//            userImageView!.leadingAnchor.constraint(equalTo: avatarButton.leadingAnchor),
//            userImageView!.trailingAnchor.constraint(equalTo: avatarButton.trailingAnchor),
//            userImageView!.bottomAnchor.constraint(equalTo: avatarButton.bottomAnchor)
//        ])
//    }
//    
//    userImageView?.loadImage(from: "https://i.pinimg.com/474x/8d/7f/a7/8d7fa70fa5ec7919737e3868afa96675.jpg")
//}
