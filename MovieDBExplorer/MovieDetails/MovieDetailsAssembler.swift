//
//  MovieDetailsAssembler.swift
//  MovieDBExplorer
//
//  Created by Tomasz Horowski on 26/06/2024.
//

import Foundation
import UIKit


protocol MovieDetailsAssembling {
    
    func assemble(movieId: Movie.Id, title: String) -> UIViewController
    
}

final class MovieDetailsAssembler: MovieDetailsAssembling {
    
    func assemble(movieId: Movie.Id, title: String) -> UIViewController {
        let viewModel = MovieDetailsViewModel(
            title: title,
            movieId: movieId,
            movieDetailsProvider: MovieDBEndpoint.moveDetails(id: movieId), 
            moviesFavouriting: Dependencies.moviesFavouritingService
        )
        
       return MovieDetailsViewController(viewModel: viewModel)
    }
    
    
}
