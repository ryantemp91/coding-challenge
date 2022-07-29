//
//  ContentView.swift
//  Shared
//
//  Created by Ryan Cochrane on 7/28/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()
    
    var body: some View {
        ZStack {
            VStack {
                switch viewModel.viewState {
                case .notLoaded:
                    Button("Load Users", action: {
                        Task {
                            await viewModel.loadUsers(page: 3)
                        }
                    }).padding(5)
                case .loading:
                    ProgressView()
                case .loaded(let viewData):
                    loadedBody(viewData: viewData)
                case .error:
                    Text("There was an error loaded the data.")
                }
            }.padding(10)
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
    @ViewBuilder
    func loadedBody(viewData: ContentViewData) -> some View {
        Text("Total # of Pages = \(viewData.totalPages)")
        if let nonExistingUserStatusCode = viewData.nonExistingUserStatusCode {
            Text("Non-Existent Status Code \(nonExistingUserStatusCode)")
        } else {
            Button("GET Non-Existent User", action: {
                Task {
                    await viewModel.getNonExistentUser()
                }
            }).padding(5)
        }
        if viewData.sorted {
            if let deletedUserStatusCode = viewData.deletedUserStatusCode {
                Text("Deleted User Status Code \(deletedUserStatusCode)")
            } else {
                Text("Last User = \(viewData.userViewData.last?.name ?? "")")
                Button("Update Last Users Name", action: {
                    guard let lastUser = viewData.userViewData.last else { return }
                    Task {
                        await viewModel.updateUser(id: lastUser.id)
                    }
                })
                Button("Delete User", action: {
                    guard let lastUser = viewData.userViewData.last else { return }
                    Task {
                        await viewModel.deleteUser(id: lastUser.id)
                    }
                })
            }
        } else {
            Button("Sort Users", action: {
                viewModel.sortUsers()
            })
        }
        Divider()
        ScrollView {
            LazyVStack {
                ForEach(viewData.userViewData) { data in
                    Text(data.name).padding(5).tag(data.id)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ContentViewModel())
    }
}
