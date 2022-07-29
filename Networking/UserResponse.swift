//
//  UserResponse.swift
//  TakeHome
//
//  Created by Ryan Cochrane on 7/28/22.
//

import Foundation

struct UserResponse: Codable {
    let id: Int
    let name: String
    let email: String
    let gender: String
    let status: String
}
