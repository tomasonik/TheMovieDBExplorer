//
//  Routing.swift
//  MovieDBExplorer
//
//  Created by Tomasz Horowski on 26/06/2024.
//

import Foundation
import UIKit

protocol NavigationRouting: AnyObject {
    
    func push(viewController: UIViewController)
    
}


extension UINavigationController: NavigationRouting {
    
    func push(viewController: UIViewController) {
        pushViewController(viewController, animated: true)
    }
    
}
