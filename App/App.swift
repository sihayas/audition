//
//  igApp.swift
//  InstagramTransition
//
//  Created by decoherence on 4/30/24.
import UIKit
import SwiftUI
import CoreData

class PassThroughWindow: UIWindow {
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    // Get view from superclass.
    guard let hitView = super.hitTest(point, with: event) else { return nil }
    // If the returned view is the `UIHostingController`'s view, ignore.
    return rootViewController?.view == hitView ? nil : hitView
  }
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var keyWindow: UIWindow?
    var secondaryWindow: UIWindow?
    var navigationController: UINavigationController!
    var bottomConstraint: NSLayoutConstraint?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        keyWindow = UIWindow(frame: UIScreen.main.bounds)
        keyWindow?.backgroundColor = .black
        
        digitize()
        
        return true
    }
    
    // Set up the feed screen
    func setupFeedScreen(user: User) {
        guard let userId = user.id else {
            return
        }
        
        navigationController = UINavigationController(rootViewController: FeedScreen(userId: userId))
        NavigationManager.shared.navigationController = navigationController
        
        keyWindow?.rootViewController = navigationController
        keyWindow?.makeKeyAndVisible()
        
        let navBar = NavBar(user: user)
        NavBarManager.shared.navBar = navBar
        
        let searchScreen = SearchScreen()
        searchScreen.modalPresentationStyle = .pageSheet
        navBar.searchModel = searchScreen.searchModel
        
        searchScreen.onDismiss = { [weak self] in
            self?.navigationController?.dismiss(animated: true, completion: {
                NavBarManager.shared.navBar?.collapseSearchBar()
            })
        }
        
        navBar.onPresentSearchScreen = { [weak self] in
            self?.navigationController?.present(searchScreen, animated: true, completion: nil)
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
              let userId = authSession.userId,
              let authToken = authSession.sessionToken else {
            DispatchQueue.main.async {
                self.setupAuthScreen()
            }
            return
        }
        
        // Fetch latest user profile data
        UserAPI.fetchUserData(userId: userId) { [weak self] result in
            guard let self = self else { return }
            
            if case .success(let userResponse) = result {
                let userData = userResponse.data
                
                let fetchRequest = User.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %@", userId)
                
                let user = (try? CoreDataStack.shared.managedContext.fetch(fetchRequest).first) ?? User(context: CoreDataStack.shared.managedContext)
                user.id = userData.id
                user.username = userData.username
                user.bio = userData.bio
                user.image = userData.image
                
                do {
                    try CoreDataStack.shared.managedContext.save()
                    DispatchQueue.main.async {
                        self.setupFeedScreen(user: user)
                    }
                } catch {
                    print("Error saving User to Core Data: \(error.localizedDescription)")
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
        keyWindow?.rootViewController = navigationController
        keyWindow?.makeKeyAndVisible()
    }

    func fetchAuthSession() -> Session? {
        let fetchRequest = NSFetchRequest<Session>(entityName: "Session")
        return try? CoreDataStack.shared.managedContext.fetch(fetchRequest).first
    }
}
