import UIKit
import CoreData
import SwiftUI

class NavBar: UIView, UIGestureRecognizerDelegate, UISearchBarDelegate {
    var height: Double = 32 {
        didSet {
            resizeContainer()
        }
    }
    
    var onPresentSearchScreen: (() -> Void)?
    
    var user: User
    var searchModel: SearchModel?
    var userImageView: UIImageView?
    private var selectedSearchResultObserver: NSObjectProtocol?
    
    private var isExpanded = false
    
    private var containerView: UIView!
    private var searchBar: UISearchBar!
    private var notificationButton: UIButton!
    private var avatarButton: UIButton?
    

    private var heightConstraint: NSLayoutConstraint!
    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!
    private var bottomConstraint: NSLayoutConstraint!
    
    private var searchBarBottomCnst: NSLayoutConstraint!

    private var artworkImageView: UIImageView?
    
    // Form
    init(user: User) {
        self.user = user
        super.init(frame: .zero)
        setupSearchBar()
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
        guard let superview = self.superview else { return }
        
        translatesAutoresizingMaskIntoConstraints = false

        bottomConstraint = bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -32)
        leadingConstraint = leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 165)
        trailingConstraint = trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -165)
        heightConstraint = heightAnchor.constraint(equalToConstant: height)
        
        bottomConstraint?.isActive = true
        leadingConstraint?.isActive = true
        trailingConstraint?.isActive = true
        heightConstraint?.isActive = true
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
        containerView.layer.cornerRadius = 16
        containerView.layer.cornerCurve = .continuous
        
        searchBar = UISearchBar()
        searchBar.placeholder = "Arwen"
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.backgroundColor = UIColor.clear
        searchBar.searchTextField.font = UIFont.systemFont(ofSize: 15)
        searchBar.isUserInteractionEnabled = false
        searchBar.backgroundColor = .clear
        searchBar.delegate = self
        searchBar.searchTextField.textColor = .white.withAlphaComponent(0.75)
        
        containerView.addSubview(searchBar)
        addSubview(containerView)
        
        addGestures()
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchTextField.translatesAutoresizingMaskIntoConstraints = false
        
        searchBarBottomCnst = searchBar.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 16)
        
        NSLayoutConstraint.activate([
            searchBarBottomCnst,
            
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            searchBar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            searchBar.searchTextField.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),
            searchBar.searchTextField.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor, constant: 8),
            searchBar.searchTextField.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor, constant: -8),
        ])
    }

    
    deinit {
        if let observer = selectedSearchResultObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

}



// MARK: Search Input Behaviour

extension NavBar {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if NavBarManager.shared.selectedSearchResult == nil {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(performSearch), object: nil)
            self.perform(#selector(performSearch), with: nil, afterDelay: 0.25)
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if let selectedSound = NavBarManager.shared.selectedSearchResult {
            // Print the search text
            printSearchText(searchBar.text)
        } else {
            // Perform the default search behavior
            // ...
        }
    }
    
    private func printSearchText(_ text: String?) {
        guard let text = text, !text.isEmpty else {
            return
        }
        
        print("Search Text: \(text)")
    }
    
    @objc private func performSearch() {
        if NavBarManager.shared.selectedSearchResult == nil {
            self.searchModel?.search(query: self.searchBar.text ?? "")
        }
    }
}


// MARK: Dynamic Context Animations

extension NavBar {
    // If a search result is selected
    private func setupSelectedSearchResultObserver() {
        selectedSearchResultObserver = NotificationCenter.default.addObserver(forName: .selectedSearchResultDidChange, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            let selectedSound = NavBarManager.shared.selectedSearchResult != nil
            if (selectedSound){
                isExpanded = true
                height = 440
            }
            self.createForm(selectedSound: selectedSound)
        }
    }
    
    private func createForm(selectedSound: Bool) {
        if let searchResult = NavBarManager.shared.selectedSearchResult,
            case let .song(song) = searchResult,
            let artworkURL = URL(string: song.attributes.artwork.url.replacingOccurrences(of: "{w}x{h}", with: "600x600")) {
             
             DispatchQueue.global().async { [weak self] in
                 if let data = try? Data(contentsOf: artworkURL),
                    let image = UIImage(data: data) {
                     DispatchQueue.main.async {
                         let hostingController = UIHostingController(rootView: ArtworkImageView(image: image))
                         hostingController.view.frame = CGRect(x: 0, y: 0, width: 270, height: 270)
                         hostingController.view.backgroundColor = .clear
                         hostingController.view.translatesAutoresizingMaskIntoConstraints = false
                         self?.containerView.addSubview(hostingController.view)
                         
                         NSLayoutConstraint.activate([
                             hostingController.view.centerXAnchor.constraint(equalTo: self?.containerView.centerXAnchor ?? NSLayoutXAxisAnchor()),
                             hostingController.view.topAnchor.constraint(equalTo: self?.containerView.topAnchor ?? NSLayoutYAxisAnchor(), constant: 64),
                             hostingController.view.widthAnchor.constraint(equalToConstant: 270),
                             hostingController.view.heightAnchor.constraint(equalToConstant: 270)
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
                     }
                 }
             }
         }
    }


}

// MARK: Animations/Gestures

extension NavBar {
    
    func resizeContainer() {
        self.heightConstraint.constant = height
        
        let cornerRadiusAnimation = CABasicAnimation(keyPath: "cornerRadius")
        cornerRadiusAnimation.fromValue = containerView.layer.cornerRadius
        cornerRadiusAnimation.toValue = 24
        cornerRadiusAnimation.duration = 0.5
        cornerRadiusAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        containerView.layer.add(cornerRadiusAnimation, forKey: "cornerRadiusAnimation")
        containerView.layer.cornerRadius = 28
        
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.curveEaseInOut], animations: {
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    private func addGestures() {
        self.containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapInside)))
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown))
        swipeDownGesture.direction = .down
        self.containerView.addGestureRecognizer(swipeDownGesture)
    }
    
    @objc private func handleTapInside(_ gesture: UITapGestureRecognizer) {
        if !isExpanded {
            isExpanded = true
            searchBar.isUserInteractionEnabled = true
            
            height = 48
            self.leadingConstraint.constant = 16
            self.trailingConstraint.constant = -16
            self.containerView.layer.cornerRadius = 18
            self.searchBarBottomCnst.constant = 8
            
            UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {
                self.layoutIfNeeded()
                
                let scale = CGAffineTransform(scaleX: 0, y: 0)
                self.userImageView?.transform = scale
                self.notificationButton?.transform = scale
                
                if self.isExpanded {
                    self.searchBar.searchTextField.becomeFirstResponder()
                } else {
                    self.searchBar.searchTextField.resignFirstResponder()
                }
            }, completion: { _ in
                self.onPresentSearchScreen?()
            })
        }
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
            collapseSearchBar()
        }
    }

    @objc private func handleSwipeDown(_ gesture: UISwipeGestureRecognizer) {
        collapseSearchBar()
    }

    @objc func collapseSearchBar() {
        if isExpanded {
            isExpanded = false
            searchBar.isUserInteractionEnabled = false
            
            let height: CGFloat = 32
            let finalCornerRadius: CGFloat = height / 2
            
            self.leadingConstraint.constant = 165
            self.trailingConstraint.constant = -165
            self.heightConstraint.constant = height
            self.searchBarBottomCnst.constant = 16
            self.containerView?.layer.cornerRadius = finalCornerRadius
            
            UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {
                self.layoutIfNeeded()
                
                let scale = CGAffineTransform(scaleX: 1, y: 1)
                self.userImageView?.transform = scale
                self.notificationButton?.transform = scale
                
                self.searchBar.searchTextField.resignFirstResponder()
            }, completion: nil)
        }
    }

    
    @objc private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    // Translating logic
    @objc private func translateNavigationBar(upwards: Bool, distance: CGFloat) {
        let translationDistance: CGFloat = upwards ? -distance : 0
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {
            if let bottomConstraint = self.bottomConstraint {
                bottomConstraint.constant = translationDistance
                self.layoutIfNeeded()
            }
        }, completion: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.3
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: [.beginFromCurrentState], animations: { [weak self] in
            self?.bottomConstraint?.constant = -keyboardHeight - 32
            self?.superview?.layoutIfNeeded()
        }, completion: nil)
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.3
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: [.beginFromCurrentState], animations: { [weak self] in
            self?.bottomConstraint?.constant = -32
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
}


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
//        dotView.centerYAnchor.constraint(equalTo: notificationButton.centerYAnchor),
////            dotView.widthAnchor.constraint(equalToConstant: 8),
////            dotView.heightAnchor.constraint(equalToConstant: 8)
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
//        // Set up constraints for the container view and image view
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
