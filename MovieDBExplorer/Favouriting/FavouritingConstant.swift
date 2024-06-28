//
//  FavouritingConstant.swift
//  MovieDBExplorer
//
//  Created by Tomasz Horowski on 27/06/2024.
//

import Foundation
import UIKit

enum FavouritingConstant {
    
    static func tooglingIcon(isFavourite: Bool) -> UIImage {
        UIImage(systemName: isFavourite ? "star.fill" : "star") ?? UIImage()
    }
    
}
