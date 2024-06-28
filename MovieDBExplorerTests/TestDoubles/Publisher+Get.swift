//
//  Publisher+Get.swift
//  MovieDBExplorerTests
//
//  Created by Tomasz Horowski on 27/06/2024.
//

import Foundation
import Combine
import XCTest


extension XCTestCase {
        
    @discardableResult
    func getOutput<P: Publisher>(
        from publisher: P,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> P.Output {
        var result: P.Output?
        let expectation = XCTestExpectation(description: "get publisher value")
        
        let cancellable = publisher
            .first()
            .sink { [expectation] _ in
                expectation.fulfill()
            } receiveValue: { output in
                result = output
            }
        

        wait(for: [expectation], timeout: 0.2)
        cancellable.cancel()
        
        return try XCTUnwrap(result, file: file, line: line)
    }
    
    @discardableResult
    func getNextOutput<P: Publisher>(
        from publisher: P,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> P.Output {
        try XCTUnwrap(getOutput(from: publisher.collect(2).first(), file: file, line: line).last)
    }
    
    func givenOutputUpdated<P: Publisher>(
        in publisher: P,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        try getOutput(from: publisher)
    }
    
    func givenNextOutputUpdated<P: Publisher>(
        in publisher: P,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        try getNextOutput(from: publisher)
    }
    
}
