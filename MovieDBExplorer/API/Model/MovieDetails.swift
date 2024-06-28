//
//  MovieDetails.swift
//  MovieDBExplorer
//
//  Created by Tomek on 26/06/2024.
//

import Foundation

struct Genre: Decodable {
    let name: String
}

struct Country: Decodable {
    let name: String
}

struct MovieDetails: Decodable {
    
    let id: Movie.Id
    let title: String
    let releaseDate: String?
    let revenue: Int?
    let productionCountries: [Country]?
    let genres: [Genre]?
    let originalTitle: String?
    let backdropPath: String?
    let posterPath: String?

}
