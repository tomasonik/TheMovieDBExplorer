//
//  Movie.swift
//  MovieDBExplorer
//
//  Created by Tomasz Horowski on 26/06/2024.
//

import Foundation

struct Movie: Decodable {

    typealias Id = Int
    
    let id: Id
    let title: String
    let posterPath: String?
    
}
