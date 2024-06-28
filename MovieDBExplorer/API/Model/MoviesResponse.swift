//
//  MoviesResponse.swift
//  MovieDBExplorer
//
//  Created by Tomek on 26/06/2024.
//

import Foundation

struct MoviesResponse: Decodable {
    let results: [Movie]
}
