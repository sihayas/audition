//
//  UINavigationManager.swift
//  InstagramTransition
//
//  Created by decoherence on 5/24/24.
//


import UIKit


class NavigationManager {
    static let shared = NavigationManager()
    
    var navigationController: UINavigationController?
    
    private init() {}
    
    func navigateToSoundScreen(withDetails details: SoundScreenDetails) {
        let soundScreen = SoundScreen(details: details)
        navigationController?.pushViewController(soundScreen, animated: true)
    }
    
    func navigateToUserScreen(withUserData userData: APIUser? = nil, withUserResult userResult: UserResult? = nil) {
        let userScreen = UserScreen(userData: userData, userResult: userResult)
        navigationController?.pushViewController(userScreen, animated: true)
    }
}

class NavBarManager {
    static let shared = NavBarManager()
    
    var navBar: NavBar?
    
    private init() {}
    
    func setSelectedSearchResult(_ result: SearchModel.SearchResult) {
        selectedSearchResult = result
    }
    
    var selectedSearchResult: SearchModel.SearchResult? {
        didSet {
            NotificationCenter.default.post(name: .selectedSearchResultDidChange, object: nil)
        }
    }
}

extension Notification.Name {
    static let selectedSearchResultDidChange = Notification.Name("selectedSearchResultDidChange")
}
