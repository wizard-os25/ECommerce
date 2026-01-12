//
//  LocationSearchController.swift
//  ECommerce
//
//  Created by wizard.os25 on 11/1/26.
//

import Foundation
import UIKit

protocol LocationSearchControllerInput {
    func didSearch(keyword: String)
    func didSelectKeyword(_ keyword: String)
    func didClearSearch()
}

protocol LocationSearchControllerOutput {
    var searchSuggestions: Observable<[LocationSearchKeyword]> { get }
    var recentSearches: Observable<[LocationSearchKeyword]> { get }
    var screenTitle: String { get }
}

typealias LocationSearchController = LocationSearchControllerInput & LocationSearchControllerOutput & EcoController

final class DefaultLocationSearchController: LocationSearchController {
    
    // MARK: - OUTPUT
    
    let searchSuggestions: Observable<[LocationSearchKeyword]> = Observable([])
    let recentSearches: Observable<[LocationSearchKeyword]> = Observable([])
    let screenTitle = "Search Location"
    
    // MARK: - EcoController Output
    
    let loading: Observable<Bool> = Observable(false)
    let error: Observable<Error?> = Observable(nil)
    let navigationState: Observable<EcoNavigationState> = Observable(.init())
    
    // MARK: - Private
    
    private var searchTask: Cancellable? { willSet { searchTask?.cancel() } }
    private let maxRecentSearches = 10
    
    // MARK: - Navigation Bar Configuration
    
    var navigationBarTitle: String? {
        return nil // No title, only search field
    }
    
    var navigationBarShowsSearch: Bool {
        return true
    }
    
    var navigationBarSearchState: EcoSearchState {
        return EcoSearchState(
            text: "",
            placeholder: "Search location",
            isEditing: false,
            showsClearButton: true,
            showsCameraButton: false
        )
    }
    
    var navigationBarBackground: EcoNavigationBackground {
        return .solid(.white)
    }
    
    var navigationBarBackgroundColor: UIColor? {
        return .white
    }
    
    var navigationBarInitialHeight: CGFloat {
        return 80
    }
    
    var navigationBarCollapsedHeight: CGFloat {
        return 80
    }
    
    // MARK: - Init
    
    init() {
        loadRecentSearches()
    }
    
    // MARK: - Private
    
    private func loadRecentSearches() {
        // Load from UserDefaults or CoreData
        // For now, use empty array
        recentSearches.value = []
    }
    
    private func saveRecentSearch(_ keyword: String) {
        var searches = recentSearches.value
        // Remove if already exists
        searches.removeAll { $0.keyword.lowercased() == keyword.lowercased() }
        // Add to beginning
        searches.insert(LocationSearchKeyword(keyword: keyword), at: 0)
        // Keep only max items
        if searches.count > maxRecentSearches {
            searches = Array(searches.prefix(maxRecentSearches))
        }
        recentSearches.value = searches
        // TODO: Save to UserDefaults or CoreData
    }
}

// MARK: - INPUT Implementation

extension DefaultLocationSearchController {
    
    func didSearch(keyword: String) {
        guard !keyword.isEmpty else {
            searchSuggestions.value = []
            return
        }
        
        // Use MapController to search
        // For now, create mock suggestions
        // In real implementation, this would call MapController.search()
        let suggestions = [
            LocationSearchKeyword(keyword: "\(keyword) - Location 1"),
            LocationSearchKeyword(keyword: "\(keyword) - Location 2"),
            LocationSearchKeyword(keyword: "\(keyword) - Location 3")
        ]
        searchSuggestions.value = suggestions
    }
    
    func didSelectKeyword(_ keyword: String) {
        saveRecentSearch(keyword)
        // Handle selection - will be implemented later
    }
    
    func didClearSearch() {
        searchSuggestions.value = []
    }
}

// MARK: - EcoController Implementation

extension DefaultLocationSearchController {
    
    func onViewDidLoad() {
        navigationState.value = EcoNavigationState(
            title: navigationBarTitle,
            showsSearch: navigationBarShowsSearch,
            searchState: navigationBarShowsSearch ? navigationBarSearchState : nil,
            leftItem: nil,
            rightItems: [],
            background: navigationBarBackground,
            backgroundColor: navigationBarBackgroundColor,
            height: navigationBarInitialHeight,
            collapsedHeight: navigationBarCollapsedHeight,
            scrollBehavior: .default
        )
    }
    
    func onViewWillAppear() {
        // Handle view will appear if needed
    }
    
    func onViewDidDisappear() {
        // Handle view did disappear if needed
    }
}
