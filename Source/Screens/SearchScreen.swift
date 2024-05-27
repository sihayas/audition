//
//  SearchScreen.swift
//  InstagramTransition
//
//  Created by decoherence on 5/7/24.
//

import UIKit
import SwiftUI
import Combine

class SearchScreen: UIViewController {
    var searchModel = SearchModel()
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBlurEffect()
        setupBindings()
        addSwiftUIContent()
    }
    
    private func setupBlurEffect() {
        let blurEffect = UIBlurEffect(style: .systemChromeMaterialDark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(blurEffectView, at: 0)

        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            blurEffectView.leftAnchor.constraint(equalTo: view.leftAnchor),
            blurEffectView.rightAnchor.constraint(equalTo: view.rightAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func addSwiftUIContent() {
        let searchResultsView = SearchResultsView(searchModel: searchModel)
        let hostingController = UIHostingController(rootView: searchResultsView)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        hostingController.didMove(toParent: self)
    }

    private func setupBindings() {
        searchModel.$searchResults
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                // No need to manually reload data, SwiftUI will handle it
            }
            .store(in: &cancellables)
        
        searchModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { isLoading in
//                print(isLoading ? "Loading..." : "Loading finished")
            }
            .store(in: &cancellables)
    }
}
