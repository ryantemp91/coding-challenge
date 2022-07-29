//
//  ContentViewModelTests.swift
//  TakeHomeTests
//
//  Created by Ryan Cochrane on 7/28/22.
//

import XCTest
import Combine
@testable import TakeHome

class ContentViewModelTests: XCTestCase {
    let mockUrlStr = "https://gorest.co.in"

    func testLoadUsers() async throws {
        guard let path = Bundle(for: type(of: self)).path(forResource: "users", ofType: "json"),
              let mockUsersData = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe),
              let mockUrl = URL(string: mockUrlStr),
              let mockResponse = HTTPURLResponse(url: mockUrl, statusCode: 200, httpVersion: nil, headerFields: [APIClient.ResponseHeaders.paginatedPages.rawValue: "355"]) else {
            XCTFail()
            return
        }
        var cancellables = Set<AnyCancellable>()
        let networkingSession = NetworkingSessionMock(result: .success(mockUsersData), response: mockResponse)
        let mockApiClient = APIClient(session: networkingSession)
        let service = UserService(client: mockApiClient)
        let viewModel = ContentViewModel(service: service)
        XCTAssertEqual(viewModel.viewState, .notLoaded)
        let expectation = XCTestExpectation(description: "publishes view state")
        viewModel.$viewState.sink { _ in expectation.fulfill() } .store(in: &cancellables)
        await viewModel.loadUsers(page: 3)
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(viewModel.viewState, .loaded(ContentViewData(totalPages: "355",
                                                                    sorted: false,
                                                                    nonExistingUserStatusCode: nil,
                                                                    deletedUserStatusCode: nil,
                                                                    userViewData: [])))
    }
    
    func testSortUsers() async throws {
        guard let path = Bundle(for: type(of: self)).path(forResource: "users", ofType: "json"),
              let mockUsersData = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe),
              let mockUrl = URL(string: mockUrlStr),
              let mockResponse = HTTPURLResponse(url: mockUrl, statusCode: 200, httpVersion: nil, headerFields: [APIClient.ResponseHeaders.paginatedPages.rawValue: "355"]) else {
            XCTFail()
            return
        }
        let expectation = XCTestExpectation(description: "publishes view state")
        var cancellables = Set<AnyCancellable>()
        let networkingSession = NetworkingSessionMock(result: .success(mockUsersData), response: mockResponse)
        let mockApiClient = APIClient(session: networkingSession)
        let service = UserService(client: mockApiClient)
        let viewModel = ContentViewModel(service: service)
        viewModel.$viewState.sink { _ in expectation.fulfill() } .store(in: &cancellables)
        await viewModel.loadUsers(page: 3)
        wait(for: [expectation], timeout: 1)
        viewModel.sortUsers()
        switch viewModel.viewState {
        case .loaded(let viewData):
            XCTAssertEqual(viewData.sorted, true)
        default: XCTFail()
        }
    }
    
    func testUpdateUser() async throws {
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
        await viewModel.loadUsers(page: 3)
        guard let path = Bundle(for: type(of: self)).path(forResource: "user", ofType: "json"),
              let mockUsersData = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe) else {
            XCTFail()
            return
        }
        viewModel.service.setClient(client: APIClient(session: NetworkingSessionMock(result: .success(mockUsersData))))
        let expectation = XCTestExpectation(description: "publishes view state")
        var cancellables = Set<AnyCancellable>()
        viewModel.$viewState.sink { _ in expectation.fulfill() } .store(in: &cancellables)
        await viewModel.updateUser(id: 3417)
        wait(for: [expectation], timeout: 1)
        switch viewModel.viewState {
        case .loaded(let viewData):
            XCTAssertEqual(viewData.userViewData.last?.name, "A new name")
        default: XCTFail()
        }
    }
    
    func testDeleteUser() async throws {
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
        await viewModel.loadUsers(page: 3)
        guard let mockUrl = URL(string: mockUrlStr),
              let mockResponse = HTTPURLResponse(url: mockUrl, statusCode: 204, httpVersion: nil, headerFields: nil) else {
            XCTFail()
            return
        }
        viewModel.service.setClient(client: APIClient(session: NetworkingSessionMock(result: .success(Data()),response: mockResponse)))
        let expectation = XCTestExpectation(description: "publishes view state")
        var cancellables = Set<AnyCancellable>()
        viewModel.$viewState.sink { _ in expectation.fulfill() } .store(in: &cancellables)
        await viewModel.deleteUser(id: 3417)
        wait(for: [expectation], timeout: 1)
        switch viewModel.viewState {
        case .loaded(let viewData):
            XCTAssertEqual(viewData.deletedUserStatusCode, 204)
            XCTAssertEqual(viewData.userViewData.count, 9)
        default: XCTFail()
        }
    }
    
    func testGetUser() async throws {
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
        await viewModel.loadUsers(page: 3)
        guard let mockUrl = URL(string: mockUrlStr),
              let mockResponse = HTTPURLResponse(url: mockUrl, statusCode: 404, httpVersion: nil, headerFields: nil) else {
            XCTFail()
            return
        }
        viewModel.service.setClient(client: APIClient(session: NetworkingSessionMock(result: .success(Data()),response: mockResponse)))
        let expectation = XCTestExpectation(description: "publishes view state")
        var cancellables = Set<AnyCancellable>()
        viewModel.$viewState.sink { _ in expectation.fulfill() } .store(in: &cancellables)
        await viewModel.getNonExistentUser()
        wait(for: [expectation], timeout: 1)
        switch viewModel.viewState {
        case .loaded(let viewData):
            XCTAssertEqual(viewData.nonExistingUserStatusCode, 404)
        default: XCTFail()
        }
    }
}
