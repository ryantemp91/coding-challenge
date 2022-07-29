//
//  UserServiceTests.swift
//  TakeHomeTests
//
//  Created by Ryan Cochrane on 7/28/22.
//

import XCTest
@testable import TakeHome

class UserServiceTests: XCTestCase {

    let mockUrlStr = "https://gorest.co.in"

    func testGettingUsersResponse() async throws {
        guard let path = Bundle(for: type(of: self)).path(forResource: "users", ofType: "json"),
              let mockUsersData = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe),
              let mockUrl = URL(string: mockUrlStr),
              let mockResponse = HTTPURLResponse(url: mockUrl, statusCode: 200, httpVersion: nil, headerFields: [APIClient.ResponseHeaders.paginatedPages.rawValue: "355"]) else {
            XCTFail()
            return
        }
        let networkingSession = NetworkingSessionMock(result: .success(mockUsersData), response: mockResponse)
        let mockApiClient = APIClient(session: networkingSession)
        let service = UserService(client: mockApiClient)
        guard let result = await service.getUsers(page: 3) else {
            XCTFail()
            return
        }
        XCTAssertEqual(result.users.count, 10)
        XCTAssertEqual(result.totalPages, "355")
    }
    
    func testUpdateUser() async throws {
        guard let path = Bundle(for: type(of: self)).path(forResource: "user", ofType: "json"),
              let mockUserData = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe) else {
            XCTFail()
            return
        }
        let networkingSession = NetworkingSessionMock(result: .success(mockUserData))
        let mockApiClient = APIClient(session: networkingSession)
        let service = UserService(client: mockApiClient)
        guard let result = await service.updateUser(id: 3417, name: "A new name") else {
            XCTFail()
            return
        }
        XCTAssertEqual(result.name, "A new name")
    }
    
    func testDeleteUser() async throws {
        guard let mockUrl = URL(string: mockUrlStr),
              let mockResponse = HTTPURLResponse(url: mockUrl, statusCode: 204, httpVersion: nil, headerFields: nil) else {
            XCTFail()
            return
        }
        let networkingSession = NetworkingSessionMock(result: .success(Data()), response: mockResponse)
        let mockApiClient = APIClient(session: networkingSession)
        let service = UserService(client: mockApiClient)
        guard let result = await service.deleteUser(id: 3417) else {
            XCTFail()
            return
        }
        XCTAssertEqual(result, 204)
    }
    
    func testGetUserNonExistent() async throws {
        guard let mockUrl = URL(string: mockUrlStr),
              let mockResponse = HTTPURLResponse(url: mockUrl, statusCode: 404, httpVersion: nil, headerFields: nil) else {
            XCTFail()
            return
        }
        let networkingSession = NetworkingSessionMock(result: .success(Data()), response: mockResponse)
        let mockApiClient = APIClient(session: networkingSession)
        let service = UserService(client: mockApiClient)
        let result = await service.getUser(id: 5555)
        XCTAssertEqual(result.1, 404)
    }
    
    func testGetUserExistent() async throws {
        guard let path = Bundle(for: type(of: self)).path(forResource: "user", ofType: "json"),
              let mockUserData = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe) else {
            XCTFail()
            return
        }
        let networkingSession = NetworkingSessionMock(result: .success(mockUserData))
        let mockApiClient = APIClient(session: networkingSession)
        let service = UserService(client: mockApiClient)
        let result = await service.getUser(id: 5555)
        XCTAssertEqual(result.0?.id, 3417)
    }
}
