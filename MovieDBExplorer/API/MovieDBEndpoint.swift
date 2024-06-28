//
//  MovieDB.swift
//  MovieDB
//
//  Created by Tomasz Horowski on 26/06/2024.
//

import Foundation
import Combine


enum MovieDBError: Error {
    case invalidUrl
}


enum MovieDBEndpoint {
    
    static let nowPlayingPath = "/movie/now_playing"
    static let details = "/movie/"
    
    static let posterBaseUrl = "https://image.tmdb.org/t/p/original"
    
    static let apiKey = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJmNTgwZjJiOTRhMWY4MWM4MTU1MTRjYzE3OGVmNjgzZiIsIm5iZiI6MTcxOTM4NDY1MS45MzY0NDcsInN1YiI6IjY2N2JiOGMyMzk0MDVjMzgyZmFhNmFkZCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.nRYPK4dCNymbFA34-IQIClJyG-Mf31n6YmPmZyoUIqc"
    static let baseUrl = "https://api.themoviedb.org/3"
    
    
    static var mowPlaying: AnyPublisher<MoviesResponse, Error> {
        request(path: nowPlayingPath)
    }
    
    
    static func moveDetails(id: Movie.Id) -> AnyPublisher<MovieDetails, Error> {
        request(path: details + String(id))
    }
    
    
    static func imageUrl(path: String) -> URL? {
        URL(string: posterBaseUrl + path)
    }
    
    
    static func request<Response: Decodable>(path: String, apiKey: String = apiKey) -> AnyPublisher<Response, Error> {
        guard let url = URL(string: baseUrl + path) else {
            return Fail<Response, Error>(error: MovieDBError.invalidUrl).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.authWithMovieDB()

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        // TODO: inject NSURLSession publisher; make it testable
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: Response.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
    
    
}

extension URLRequest {
    
    mutating func authWithMovieDB() {
        setValue("Bearer \(MovieDBEndpoint.apiKey)", forHTTPHeaderField: "Authorization")
    }
    
}
