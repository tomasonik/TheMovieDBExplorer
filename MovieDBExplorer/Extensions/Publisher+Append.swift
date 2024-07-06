//
//  Publisher+Append.swift
//  MovieDBExplorer
//
//  Created by Tomek on 05/07/2024.
//

import Foundation
import Combine

extension Publisher {
    
    func append<Root: AnyObject>(to keyPath: ReferenceWritableKeyPath<Root, [Self.Output]>, on root: Root) -> Cancellable {
        sink(receiveCompletion: { _ in }) { [weak root] value in
            root?[keyPath: keyPath].append(value)
        }
    }
    
}
