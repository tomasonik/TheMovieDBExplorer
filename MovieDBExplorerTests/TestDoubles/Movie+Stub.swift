//
//  Movie+Stub.swift
//  MovieDBExplorerTests
//
//  Created by Tomasz Horowski on 27/06/2024.
//

import Foundation
@testable import MovieDBExplorer

extension Movie {
    
    static func stub(
        id: Int = -1,
        title: String = "arbitrary",
        posterPath: String? = nil
    ) -> Self {
        Movie(
            id: id,
            title: title,
            posterPath: posterPath
        )
    }
    
}
