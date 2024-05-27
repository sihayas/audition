import UIKit
import CoreData

class NavBar: UISearchBar, UISearchBarDelegate, UIGestureRecognizerDelegate {
    
    var user: User
    var searchModel: SearchModel?
    var searchScreen: SearchScreen?
    var userImageView: UIImageView?
    
    private var isExpanded = false
    private var searchBarView: UIView?
    private var notificationButton: UIButton?
    private var avatarButton: UIButton?
    
    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!
    private var heightConstraint: NSLayoutConstraint!
    private var bottomConstraint: NSLayoutConstraint!

    init(user: User) {
        self.user = user
        super.init(frame: .zero)
        setupSearchBar()
        self.delegate = self
        self.searchTextField.isHidden = true
        self.searchModel = SearchModel()
        setupAvatar(imageUrl: self.user.image)
        setupNotification()
        addTapGesture()
        setupKeyboardObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if superview != nil {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutside(_:)))
            tapGesture.cancelsTouchesInView = false
            superview?.addGestureRecognizer(tapGesture)
        }
    }

    private func fetchAuthUser(userId: String) -> User? {
        let fetchRequest = NSFetchRequest<User>(entityName: "User")
        fetchRequest.predicate = NSPredicate(format: "id == %@", userId)
        return try? CoreDataStack.shared.managedContext.fetch(fetchRequest).first
    }
    
    private func setupNotification() {
        notificationButton = UIButton()
        notificationButton?.translatesAutoresizingMaskIntoConstraints = false
        notificationButton?.layer.shadowColor = UIColor.black.cgColor
        notificationButton?.layer.shadowOpacity = 0.2
        notificationButton?.layer.shadowOffset = CGSize(width: 0, height: 2)
        notificationButton?.layer.shadowRadius = 4
        
        let blackView = UIView()
        blackView.translatesAutoresizingMaskIntoConstraints = false
        blackView.layer.cornerRadius = 16
        blackView.layer.cornerCurve = .continuous
        blackView.clipsToBounds = true
        blackView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        blackView.layer.borderColor = UIColor.white.withAlphaComponent(0.05).cgColor
        blackView.layer.borderWidth = 1
        
        notificationButton?.addSubview(blackView)
        
        let ringView = UIView()
        ringView.translatesAutoresizingMaskIntoConstraints = false
        ringView.backgroundColor = .clear
        ringView.layer.cornerRadius = 12
        ringView.layer.borderColor = UIColor.white.cgColor
        ringView.layer.borderWidth = 1
        ringView.alpha = 0.5
        
        notificationButton?.addSubview(ringView)
        
        let dotView = UIView()
        dotView.translatesAutoresizingMaskIntoConstraints = false
        dotView.backgroundColor = .white
        dotView.layer.cornerRadius = 4
        dotView.alpha = 0.75
        
        ringView.addSubview(dotView)
        
        addSubview(notificationButton!)
        
        NSLayoutConstraint.activate([
            notificationButton!.trailingAnchor.constraint(equalTo: searchBarView!.leadingAnchor, constant: -8),
            notificationButton!.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            notificationButton!.widthAnchor.constraint(equalToConstant: 32),
            notificationButton!.heightAnchor.constraint(equalToConstant: 32),
            blackView.topAnchor.constraint(equalTo: notificationButton!.topAnchor),
            blackView.leadingAnchor.constraint(equalTo: notificationButton!.leadingAnchor),
            blackView.trailingAnchor.constraint(equalTo: notificationButton!.trailingAnchor),
            blackView.bottomAnchor.constraint(equalTo: notificationButton!.bottomAnchor),
            ringView.centerXAnchor.constraint(equalTo: notificationButton!.centerXAnchor),
            ringView.centerYAnchor.constraint(equalTo: notificationButton!.centerYAnchor),
            ringView.widthAnchor.constraint(equalToConstant: 24),
            ringView.heightAnchor.constraint(equalToConstant: 24),
            dotView.centerXAnchor.constraint(equalTo: ringView.centerXAnchor),
            dotView.centerYAnchor.constraint(equalTo: ringView.centerYAnchor),
            dotView.widthAnchor.constraint(equalToConstant: 8),
            dotView.heightAnchor.constraint(equalToConstant: 8)
        ])
    }
    
    private func setupSearchBar() {
        self.placeholder = "Arwen"
        self.backgroundImage = UIImage()
        self.searchTextField.backgroundColor = UIColor.clear
        self.translatesAutoresizingMaskIntoConstraints = false
        
        searchBarView = UIView()
        searchBarView?.translatesAutoresizingMaskIntoConstraints = false
        searchBarView?.clipsToBounds = false
        searchBarView?.layer.shadowColor = UIColor.black.cgColor
        searchBarView?.layer.shadowOpacity = 0.2
        searchBarView?.layer.shadowOffset = CGSize(width: 0, height: 2)
        searchBarView?.layer.shadowRadius = 4
        
        let blackView = UIView()
        blackView.translatesAutoresizingMaskIntoConstraints = false
        blackView.layer.cornerRadius = 16
        blackView.layer.cornerCurve = .continuous
        blackView.clipsToBounds = true
        blackView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        blackView.layer.borderColor = UIColor.white.withAlphaComponent(0.05).cgColor
        blackView.layer.borderWidth = 1
        
        blackView.addSubview(searchTextField)
        searchBarView?.addSubview(blackView)
        addSubview(searchBarView!)
        
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        
        leadingConstraint = searchBarView?.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 165)
        trailingConstraint = searchBarView?.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -165)
        heightConstraint = searchBarView?.heightAnchor.constraint(equalToConstant: 32)
        
        NSLayoutConstraint.activate([
            searchTextField.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            searchTextField.leadingAnchor.constraint(equalTo: searchBarView!.leadingAnchor, constant: 8),
            searchTextField.trailingAnchor.constraint(equalTo: searchBarView!.trailingAnchor, constant: -8),
            leadingConstraint,
            trailingConstraint,
            searchBarView!.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            heightConstraint,
            blackView.topAnchor.constraint(equalTo: searchBarView!.topAnchor),
            blackView.leadingAnchor.constraint(equalTo: searchBarView!.leadingAnchor),
            blackView.trailingAnchor.constraint(equalTo: searchBarView!.trailingAnchor),
            blackView.bottomAnchor.constraint(equalTo: searchBarView!.bottomAnchor)
        ])
    }

    private func setupAvatar(imageUrl: String?) {
        avatarButton = UIButton()
        avatarButton?.translatesAutoresizingMaskIntoConstraints = false
        avatarButton?.layer.shadowColor = UIColor.black.cgColor
        avatarButton?.layer.shadowOpacity = 0.2
        avatarButton?.layer.shadowOffset = CGSize(width: 0, height: 2)
        avatarButton?.layer.shadowRadius = 4
        
        avatarButton?.addTarget(self, action: #selector(avatarButtonTapped), for: .touchUpInside)
        
        userImageView = UIImageView()
        userImageView?.translatesAutoresizingMaskIntoConstraints = false
        userImageView?.layer.cornerRadius = 16
        userImageView?.clipsToBounds = true
        userImageView?.layer.borderColor = UIColor.white.withAlphaComponent(0.05).cgColor
        userImageView?.layer.borderWidth = 1
        
        if let avatarButton = avatarButton {
            addSubview(avatarButton)
            avatarButton.addSubview(userImageView!)
            
            // Set up constraints for the container view and image view
            NSLayoutConstraint.activate([
                avatarButton.leadingAnchor.constraint(equalTo: searchBarView!.trailingAnchor, constant: 8),
                avatarButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                avatarButton.widthAnchor.constraint(equalToConstant: 32),
                avatarButton.heightAnchor.constraint(equalToConstant: 32),
                
                userImageView!.topAnchor.constraint(equalTo: avatarButton.topAnchor),
                userImageView!.leadingAnchor.constraint(equalTo: avatarButton.leadingAnchor),
                userImageView!.trailingAnchor.constraint(equalTo: avatarButton.trailingAnchor),
                userImageView!.bottomAnchor.constraint(equalTo: avatarButton.bottomAnchor)
            ])
        }
        
        userImageView?.loadImage(from: "https://i.pinimg.com/474x/8d/7f/a7/8d7fa70fa5ec7919737e3868afa96675.jpg")
    }

    func setupConstraints() {
        guard let superview = self.superview else { return }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        bottomConstraint = bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -24)
        bottomConstraint?.isActive = true
        
        leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
    }

}

// MARK: Animations/Gestures

extension NavBar {
    @objc private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapInside))
        addGestureRecognizer(tapGesture)
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown))
        swipeDownGesture.direction = .down
        addGestureRecognizer(swipeDownGesture)
    }
    
    @objc private func handleTapInside(_ gesture: UITapGestureRecognizer) {
        isExpanded.toggle()
        
        let finalHeight: CGFloat = isExpanded ? 48 : 32
        let finalCornerRadius: CGFloat = isExpanded ? 16 : finalHeight / 2
        
        let leadingConstant: CGFloat = isExpanded ? 24 : (self.bounds.width - 100) / 2
        let trailingConstant: CGFloat = isExpanded ? -24 : -(self.bounds.width - 100) / 2
        
        self.leadingConstraint.constant = leadingConstant
        self.trailingConstraint.constant = trailingConstant
        self.heightConstraint.constant = finalHeight
        self.searchBarView?.layer.cornerRadius = finalCornerRadius
        
        let scaleFactor: CGFloat = isExpanded ? 0 : 1
        
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {
            self.layoutIfNeeded()
            self.searchTextField.isHidden = !self.isExpanded
            
            // Scale and translate the image view
            let scale = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
            self.userImageView?.transform = scale
            self.notificationButton?.transform = scale
            
            if self.isExpanded {
                self.searchTextField.becomeFirstResponder()
            } else {
                self.searchTextField.resignFirstResponder()
            }
            self.searchScreen?.view.isHidden = !self.isExpanded
        }, completion: nil)
    }
    
    @objc private func handleTapOutside(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        if !bounds.contains(location) {
            if isExpanded {
                isExpanded = false
                
                let finalHeight: CGFloat = 32
                let finalCornerRadius: CGFloat = finalHeight / 2
                
                let leadingConstant: CGFloat = (self.bounds.width - 100) / 2
                let trailingConstant: CGFloat = -(self.bounds.width - 100) / 2
                
                self.leadingConstraint.constant = leadingConstant
                self.trailingConstraint.constant = trailingConstant
                self.heightConstraint.constant = finalHeight
                self.searchBarView?.layer.cornerRadius = finalCornerRadius
                
                UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {
                    self.layoutIfNeeded()
                    self.searchTextField.isHidden = true
                    
                    // Scale and translate the image view
                    let scale = CGAffineTransform(scaleX: 1, y: 1)
                    self.userImageView?.transform = scale
                    self.notificationButton?.transform = scale
                    
                    self.searchTextField.resignFirstResponder()
                    self.searchScreen?.view.isHidden = true
                }, completion: nil)
            }
        }
    }
    
    @objc private func handleSwipeDown(_ gesture: UISwipeGestureRecognizer) {
        if isExpanded {
            isExpanded = false
            
            let finalHeight: CGFloat = 32
            let finalCornerRadius: CGFloat = finalHeight / 2
            
            let leadingConstant: CGFloat = (self.bounds.width - 100) / 2
            let trailingConstant: CGFloat = -(self.bounds.width - 100) / 2
            
            self.leadingConstraint.constant = leadingConstant
            self.trailingConstraint.constant = trailingConstant
            self.heightConstraint.constant = finalHeight
            self.searchBarView!.layer.cornerRadius = finalCornerRadius
            
            UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {
                self.layoutIfNeeded()
                self.searchTextField.isHidden = true
                
                // Scale and translate the image view
                let scale = CGAffineTransform(scaleX: 1, y: 1)
                self.userImageView?.transform = scale
                self.notificationButton?.transform = scale
                
                self.searchTextField.resignFirstResponder()
                self.searchScreen?.view.isHidden = true
            }, completion: nil)
        }
    }
    
    @objc private func translateNavigationBar(upwards: Bool, distance: CGFloat) {
        let translationDistance: CGFloat = upwards ? -distance : 0
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {
            if let bottomConstraint = self.bottomConstraint {
                bottomConstraint.constant = translationDistance
                self.layoutIfNeeded()
            }
        }, completion: nil)
    }
    
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
            self?.bottomConstraint?.constant = -keyboardHeight
            self?.superview?.layoutIfNeeded()
        }, completion: nil)
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.3
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: [.beginFromCurrentState], animations: { [weak self] in
            self?.bottomConstraint?.constant = -24
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

// MARK: Search

extension NavBar {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(performSearch), object: nil)
        self.perform(#selector(performSearch), with: nil, afterDelay: 0.25)
    }
    
    @objc private func performSearch() {
        self.searchModel?.search(query: self.text ?? "")
    }
}
