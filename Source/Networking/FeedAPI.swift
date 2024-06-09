//
//  FeedAPI.swift
//  InstagramTransition
//
//  Created by decoherence on 5/23/24.
//

import Foundation
import Combine

class FeedAPI: ObservableObject {
    @Published var entries: [APIEntry] = []
    @Published var isLoading: Bool = false
    @Published var currentPage = 1
    @Published var canLoadMore = true
    var userId: String = ""
    
    func fetchEntries() {
        guard !isLoading && canLoadMore else { return }
        isLoading = true
        
        let urlString = "http://192.168.1.249:8000/api/feed?page=\(currentPage)&userId=\(userId)"
        print("URL String: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("Error: Invalid URL")
            isLoading = false
            canLoadMore = false
            return
        }
        
        print("Sending API request to: \(url)")
        
        APIClient.shared.sendRequest(url: url) { [weak self] (result: Result<APIFeedResponse, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    print("Fetched \(response.entries.count) new entries")
                    self.entries.append(contentsOf: response.entries)
                    if let nextPage = response.pagination.nextPage {
                        self.currentPage = nextPage
                    } else {
                        self.currentPage += 1
                    }
                    
                    self.canLoadMore = response.pagination.hasNextPage
                    self.isLoading = false
                case .failure(let error):
                    print("Error fetching items: \(error.localizedDescription)")
                    self.isLoading = false
                    self.canLoadMore = false
                }
            }
        }
    }
}
