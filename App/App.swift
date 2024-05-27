//
//  igApp.swift
//  InstagramTransition
//
//  Created by decoherence on 4/30/24.

import UIKit
import SwiftUI
import CoreData

 
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var navigationController: UINavigationController!
    var bottomConstraint: NSLayoutConstraint?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .black
        
        digitize()
        
        return true
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
        AuthUserAPI.fetchUserData(userId: userId) { [weak self] result in
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
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    // Set up the feed screen
    func setupFeedScreen(user: User) {
        guard let userId = user.id else {
            return
        }
        
        navigationController = UINavigationController(rootViewController: FeedScreen(userId: userId))
        NavigationManager.shared.navigationController = navigationController
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        let navBar = NavBar(user: user)
        let searchScreen = SearchScreen()
        searchScreen.view.isHidden = true
        
        window?.addSubview(navBar)
        window?.addSubview(searchScreen.view)
        window?.bringSubviewToFront(navBar)
        navBar.setupConstraints()
        navBar.searchModel = searchScreen.searchModel
        navBar.searchScreen = searchScreen
    }

    func fetchAuthSession() -> Session? {
        let fetchRequest = NSFetchRequest<Session>(entityName: "Session")
        return try? CoreDataStack.shared.managedContext.fetch(fetchRequest).first
    }

}

