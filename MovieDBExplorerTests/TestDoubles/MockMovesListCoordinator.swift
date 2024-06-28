//
//  File.swift
//  MovieDBExplorerTests
//
//  Created by Tomasz Horowski on 27/06/2024.
//

import Foundation
@testable import MovieDBExplorer

class MockMovesListCoordinator: MoviesListCoordinating {
    
    private(set) var spyOnEnteringMovieId = [Movie.Id]()
    private(set) var spyOnEnteringMovieTitle = [String]()

    func onEnteringMovie(movieId: Movie.Id, title: String) {
        spyOnEnteringMovieTitle.append(title)
        spyOnEnteringMovieId.append(movieId)
    }
    
}
