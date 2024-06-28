//
//  Publisher+Get.swift
//  MovieDBExplorerTests
//
//  Created by Tomek on 27/06/2024.
//

import Foundation
import Combine
import XCTest


extension XCTestCase {
        
    @discardableResult
    func awayResult<P: Publisher>(from publisher: P) throws -> P.Output {
        var result: P.Output?
        let expectation = XCTestExpectation(description: "get publisher value")
        
        let cancellable = publisher.sink { [expectation] _ in
            expectation.fulfill()
        } receiveValue: { output in
            result = output
        }

        wait(for: [expectation], timeout: 0.1)
        cancellable.cancel()
        return try XCTUnwrap(result)
    }
    
}
