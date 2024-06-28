//
//  MovieDetails+Stub.swift
//  MovieDBExplorerTests
//
//  Created by Tomasz Horowski on 28/06/2024.
//

import Foundation
@testable import MovieDBExplorer

extension MovieDetails {
    
    static func stub(
        id: Int = -1,
        title: String = "arbitrary",
        releaseDate: String? = nil,
        revenue: Int? = nil,
        productionCountries: [Country]? = nil,
        genres: [Genre]? = nil,
        originalTitle: String? = nil,
        backdropPath: String? = nil,
        posterPath: String? = nil
    ) -> Self {
        MovieDetails(
            id: id,
            title: title,
            releaseDate: releaseDate,
            revenue: revenue,
            productionCountries: productionCountries,
            genres: genres,
            originalTitle: originalTitle,
            backdropPath: backdropPath,
            posterPath: posterPath
        )
    }
    
}
