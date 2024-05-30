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
    
    func navigateToUserScreen(withDetails details: User) {
        let userScreen = UserScreen(details: details)
        navigationController?.pushViewController(userScreen, animated: true)
    }
}

class NavBarManager {
    static let shared = NavBarManager()
    
    var navBar: NavBar?
    
    private init() {}
}
