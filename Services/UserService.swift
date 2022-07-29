//
//  UserService.swift
//  TakeHome
//
//  Created by Ryan Cochrane on 7/28/22.
//

import Foundation

class UserService {
    var client: APIClient
    
    init(client: APIClient = APIClient()) {
        self.client = client
    }
    
    func setClient(client: APIClient) {
        self.client = client
    }

    func getUsers(page: Int) async -> UserDataResponse? {
        let result = await client.performCallAndDecode(endpoint: .users(page: page),
                                                       method: .get,
                                                       decodableType: [UserResponse].self)
        switch result {
        case .success((let users, let response)):
            var userDataResponse = UserDataResponse(users: users)
            if let response = response, let totalPages = response.allHeaderFields[APIClient.ResponseHeaders.paginatedPages.rawValue] as? String {
                userDataResponse.totalPages = totalPages
            }
            return userDataResponse
        case .failure:
            return nil
        }
    }
    
    func updateUser(id: Int, name: String) async -> UserResponse? {
        let result = await client.performCallAndDecode(endpoint: .userById(id: id),
                                                       method: .patch,
                                                       decodableType: UserResponse.self,
                                                       requestObj: ["name": name])
        switch result {
        case .success((let user, _)):
            return user
        case .failure:
            return nil
        }
    }
    
    func deleteUser(id: Int) async -> Int? {
        let result = await client.performCall(endpoint: .userById(id: id), method: .delete)
        switch result {
        case .success(let response):
            return response?.statusCode
        case .failure:
            return nil
        }
    }
    
    func getUser(id: Int) async -> (UserResponse?, Int?) {
        let result = await client.performCallAndDecode(endpoint: .userById(id: id),
                                                       method: .get,
                                                       decodableType: UserResponse.self)
        switch result {
        case .success((let user, let response)):
            return (user, response?.statusCode)
        case .failure(let error):
            switch error {
            case .failedToDecodeData(let response):
                return (nil, response?.statusCode)
            default: return (nil, nil)
            }
        }
    }
}

struct UserDataResponse {
    let users: [UserResponse]
    var totalPages: String?
    
    init(users: [UserResponse]) {
        self.users = users
    }
}
