//
//  ContentViewTests.swift
//  TakeHomeTests
//
//  Created by Ryan Cochrane on 7/28/22.
//

import XCTest
import ViewInspector
@testable import TakeHome

extension ContentView: Inspectable {}

class ContentViewTests: XCTestCase {
    
    let mockUrlStr = "https://gorest.co.in"
    
    func testNoUsersLoadedState() async throws {
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
        let viewModel = ContentViewModel(service: service)
        let subject = await ContentView(viewModel: viewModel)
        let button = try subject.inspect().find(button: "Load Users")
        XCTAssertNotNil(button)
    }

    func testLoadingUsers() async throws {
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
        let viewModel = ContentViewModel(service: service)
        let subject = await ContentView(viewModel: viewModel)
        await viewModel.loadUsers(page: 3)
        let username = try subject.inspect().find(viewWithTag: 3427).text().string()
        XCTAssertEqual(username, "Sharda Adiga")
    }
}
