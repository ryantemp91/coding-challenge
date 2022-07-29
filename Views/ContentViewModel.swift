//
//  ContentViewModel.swift
//  TakeHome
//
//  Created by Ryan Cochrane on 7/28/22.
//

import Foundation
import Combine

class ContentViewModel: ObservableObject {
    let service: UserService
    
    init(service: UserService = UserService()) {
        self.service = service
    }

    @Published var viewState: ViewState<ContentViewData> = .notLoaded

    func loadUsers(page: Int) async {
        viewState = .loading
        guard let userDataResponse = await service.getUsers(page: 3) else {
            self.viewState = .error(.dataError)
            return
        }
        let userViewData = userDataResponse.users.map { UserViewData(id: $0.id, name: $0.name) }
        DispatchQueue.main.async {
            self.viewState = .loaded(ContentViewData(totalPages: userDataResponse.totalPages ?? "",
                                                     sorted: false,
                                                     userViewData: userViewData))
        }
    }
    
    func sortUsers() {
        guard var viewData = getLoadedViewData() else { return }
        viewData.userViewData = viewData.userViewData.sorted(by: { $0.name < $1.name })
        viewData.sorted = true
        self.viewState = .loaded(viewData)
    }
    
    private func getLoadedViewData() -> ContentViewData? {
        switch viewState {
        case .loaded(let viewData): return viewData
        default:
            return nil
        }
    }
    
    func updateUser(id: Int) async {
        guard let updatedUser = await service.updateUser(id: id, name: "A new name") else { return }
        DispatchQueue.main.async {
            guard var viewData = self.getLoadedViewData() else { return }
            viewData.userViewData[viewData.userViewData.count-1] = UserViewData(id: updatedUser.id, name: updatedUser.name)
            self.viewState = .loaded(viewData)
        }
    }
    
    func deleteUser(id: Int) async {
        let result = await service.deleteUser(id: id)
        DispatchQueue.main.async {
            guard var viewData = self.getLoadedViewData() else { return }
            viewData.deletedUserStatusCode = result
            if result == 204 {
                viewData.userViewData = viewData.userViewData.dropLast()
            }
            self.viewState = .loaded(viewData)
        }
    }
    
    func getNonExistentUser() async {
        let result = await service.getUser(id: 5555)
        DispatchQueue.main.async {
            guard var viewData = self.getLoadedViewData() else { return }
            viewData.nonExistingUserStatusCode = result.1
            self.viewState = .loaded(viewData)
        }
    }
}

struct ContentViewData {
    let totalPages: String
    var sorted: Bool
    var nonExistingUserStatusCode: Int?
    var deletedUserStatusCode: Int?
    var userViewData: [UserViewData]
}

class UserViewData: ObservableObject, Identifiable, Codable {
    let id: Int
    let name: String
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}
