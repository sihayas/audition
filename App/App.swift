import UIKit
import SwiftUI
import CoreData

class PassThroughWindow: UIWindow {
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    guard let hitView = super.hitTest(point, with: event) else { return nil }
    return rootViewController?.view == hitView ? nil : hitView
  }
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var secondaryWindow: UIWindow?
    var navigationController: UINavigationController!
    var bottomConstraint: NSLayoutConstraint?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .black
        
        digitize()
        
        return true
    }
    
    
    func setupFeedScreen(user: User) {
        guard let userId = user.id else {
            print("User ID is nil")
            return
        }
        
        
        window?.makeKeyAndVisible()
        navigationController = UINavigationController(rootViewController: FeedScreen(userId: userId))
        NavigationManager.shared.navigationController = navigationController
        window?.rootViewController = navigationController

        let navBar = NavBar(user: user)
        NavBarManager.shared.navBar = navBar
        
        let searchModel = SearchModel()
        var searchResultsView = SearchScreen(searchModel: searchModel)
        searchResultsView.onDismiss = {
            NavBarManager.shared.navBar?.collapseSearchBar()
        }
        let hostingController = UIHostingController(rootView: searchResultsView)
        hostingController.view.backgroundColor = .clear
        hostingController.modalPresentationStyle = .pageSheet
        
        if let sheet = hostingController.presentationController as?
            UISheetPresentationController {
            sheet.prefersGrabberVisible = true
        }
        
        navBar.searchModel = searchModel
        
        navBar.onPresentSearchScreen = { [weak self] in
            self?.navigationController?.present(hostingController, animated: true, completion: nil)
        }
        
        secondaryWindow = PassThroughWindow(frame: UIScreen.main.bounds)
        secondaryWindow?.rootViewController = UIViewController()
        secondaryWindow?.rootViewController?.view.addSubview(navBar)
        navBar.setupConstraints()
        secondaryWindow?.isHidden = false
    }

    // Check for an auth session, if it exists get user data and log them in.
    func digitize() {
        guard let authSession = fetchAuthSession(),
              let authToken = authSession.sessionToken else {
            DispatchQueue.main.async {
                self.setupAuthScreen()
            }
            return
        }
        
        let authUserID = authSession.authUserId ?? ""
        let userId = authSession.userId ?? ""
        
        // Fetch latest user profile data
        UserAPI.fetchAuthUserData(authUserId: authUserID) { [weak self] result in
            guard let self = self else { return }
            
            if case .success(let userResponse) = result {
                let userData = userResponse.data
                
                print("User data from auth user response \(userData)")
                
                let fetchRequest = User.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %@", userData.id)
                
                // Update stored user data with latest information.
                let user = (try? CoreDataStack.shared.managedContext.fetch(fetchRequest).first) ?? User(context: CoreDataStack.shared.managedContext)
                user.id = userData.id
                user.username = userData.username
                user.bio = userData.bio
                user.image = userData.image
                user.followersCount = userData.followersCount
                user.artifactsCount = userData.artifactsCount
                
                // Save the user.id to the Session Core Data entity using the authUserId if userId doesn't exist
                if userId.isEmpty {
                    authSession.userId = userData.id
                }
                
                do {
                    try CoreDataStack.shared.managedContext.save()
                    DispatchQueue.main.async {
                        self.setupFeedScreen(user: user)
                    }
                } catch {
                    print("Error saving User and Session to Core Data: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.setupAuthScreen()
                    }
                }
            } else if case .failure(let error) = result {
                print("Error fetching user data: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.setupAuthScreen()
                }
            }
        }
    }

    // Set up the auth screen
    func setupAuthScreen() {
        navigationController = UINavigationController(rootViewController: AuthScreen())
        NavigationManager.shared.navigationController = navigationController
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    func fetchAuthSession() -> Session? {
        let fetchRequest = NSFetchRequest<Session>(entityName: "Session")
        return try? CoreDataStack.shared.managedContext.fetch(fetchRequest).first
    }
}
