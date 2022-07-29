//
//  ViewState.swift
//  TakeHome
//
//  Created by Ryan Cochrane on 7/28/22.
//

import Foundation

enum ViewState<T>: Equatable {
    static func == (lhs: ViewState<T>, rhs: ViewState<T>) -> Bool {
        switch lhs {
        case .notLoaded:
            switch rhs {
            case .notLoaded: return true
            default: return false
            }
        case .loaded:
            switch rhs {
            case .loaded: return true
            default: return false
            }
        default: return false
        }
    }
    
    case notLoaded
    case loading
    case loaded(T)
    case error(ViewStateError)
}

enum ViewStateError {
    case dataError
}
