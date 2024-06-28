//
//  MoviesResponse.swift
//  MovieDBExplorer
//
//  Created by Tomasz Horowski on 26/06/2024.
//

import Foundation

struct MoviesResponse: Decodable {
    let results: [Movie]
}
