//
//  APIClientTests.swift
//  TakeHomeTests
//
//  Created by Ryan Cochrane on 7/27/22.
//

import XCTest
@testable import TakeHome

class APIClientTests: XCTestCase {
    func testDecoding() async throws {
        guard let path = Bundle.main.path(forResource: "users", ofType: "json") else { return }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let networkingSession = NetworkingSessionMock(result: .success(data))
            let client = APIClient(session: networkingSession)
            let result = await client.performCallAndDecode(endpoint: .users(page: 3), method: .get, decodableType: [UserResponse].self)
            let users = try result.get()
            XCTAssertEqual(users.0.count, 10)
          } catch {}
    }
}

class NetworkingSessionMock: NetworkingSession {
    var result: Result<Data, Error>
    var response: URLResponse
    
    init(result: Result<Data, Error>, response: URLResponse = URLResponse()) {
        self.result = result
        self.response = response
    }
    
    func data(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
        try (result.get(), response)
    }
}
