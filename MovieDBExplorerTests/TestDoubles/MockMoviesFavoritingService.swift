//
//  MockMoviesFavoritingService.swift
//  MovieDBExplorerTests
//
//  Created by Tomek on 27/06/2024.
//

import Foundation
import Combine
@testable import MovieDBExplorer

class MockMoviesFavoritingService: Favouriting {
    
    typealias Id = Movie.Id
    
    private(set) var spyAddToFavourite = [Id]()
    private(set) var spyRemoveFromFavourite = [Id]()
    var stubFavouriteIds = Set<Id>()
    
    var stubChangesPublisher = PassthroughSubject<Id, Never>()
    
    func addToFavourite(id: MovieDBExplorer.Movie.Id) {
        spyAddToFavourite.append(id)
    }
    
    func removeFromFavourite(id: MovieDBExplorer.Movie.Id) {
        spyRemoveFromFavourite.append(id)
    }
    
    var favouriteIds: Set<MovieDBExplorer.Movie.Id> {
        stubFavouriteIds
    }
    
    var changesPublisher: AnyPublisher<MovieDBExplorer.Movie.Id, Never> {
        stubChangesPublisher.eraseToAnyPublisher()
    }
    
}
