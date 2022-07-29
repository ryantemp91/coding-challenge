//
//  APIClient.swift
//  TakeHome
//
//  Created by Ryan Cochrane on 7/28/22.
//

import Foundation

protocol APIClientProtocol {
    func performCall(endpoint: APIClient.Endpoint,
                     method: APIClient.Method,
                     bodyData: Data?) async -> Result<(Data, HTTPURLResponse?), APIClient.APIError>
}

class APIClient: APIClientProtocol {

    var session: NetworkingSession
    
    init(session: NetworkingSession = URLSession.shared) {
        self.session = session
    }
    
    enum ResponseHeaders: String {
        case paginatedPages = "x-pagination-pages"
    }

    enum Endpoint {
        case users(page: Int)
        case userById(id: Int)
        var url: String {
            let baseUrl = "https://gorest.co.in/public/v2"
            switch self {
            case .users(let page):
                return "\(baseUrl)/users?page=\(page)"
            case .userById(let id):
                return "\(baseUrl)/users/\(id)"
            }
        }
    }
    
    enum APIError: Error {
        case invalidUrl
        case failedApiRequest
        case failedToEncodeObject
        case failedToDecodeData(response: HTTPURLResponse?)
    }

    enum Method: String {
        case get = "GET"
        case patch = "PATCH"
        case delete = "DELETE"
    }
    
    func performCall(endpoint: Endpoint,
                     method: Method) async -> Result<(HTTPURLResponse?), APIError> {
        let result = await performCall(endpoint: endpoint, method: method, bodyData: nil)
        switch result {
        case .success(let res):
            let (_, response) = res
            return .success(response)
        case .failure(let error):
            return .failure(error)
        }
    }

    func performCallAndDecode<IN: Encodable, OUT: Decodable>(endpoint: Endpoint,
                                           method: Method,
                                           decodableType: OUT.Type,
                                           requestObj: IN) async -> Result<(OUT, HTTPURLResponse?), APIError> {
        guard let requestData = (try? JSONEncoder().encode(requestObj)) else {
            return .failure(.failedToEncodeObject)
        }
        let result = await performCall(endpoint: endpoint, method: method, bodyData: requestData)
        return decodeResponse(decodableResponse: result)
    }
    
    func performCallAndDecode<OUT: Decodable>(endpoint: Endpoint,
                                           method: Method,
                                           decodableType: OUT.Type) async -> Result<(OUT, HTTPURLResponse?), APIError> {
        let result = await performCall(endpoint: endpoint, method: method, bodyData: nil)
        return decodeResponse(decodableResponse: result)
    }
    
    private func decodeResponse<OUT: Decodable>(decodableResponse: Result<(Data, HTTPURLResponse?), APIError>) -> Result<(OUT, HTTPURLResponse?), APIError> {
        switch decodableResponse {
        case .success(let res):
            let (data, response) = res
            do {
                let obj = try JSONDecoder().decode(OUT.self, from: data)
                return .success((obj, response))
            } catch {
                return .failure(.failedToDecodeData(response: response))
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func performCall(endpoint: Endpoint,
                     method: Method,
                     bodyData: Data?) async -> Result<(Data, HTTPURLResponse?), APIError> {
        guard let url = URL(string: endpoint.url) else {
            return .failure(.invalidUrl)
        }
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer 3f94fb60bafe9bb0ecd39568573ee97e5d34050d00738067f7cd49838bb6fad4", forHTTPHeaderField: "Authorization")
        request.httpMethod = method.rawValue
        request.httpBody = bodyData
        do {
            let result = try await session.data(for: request)
            return .success((result.0, result.1 as? HTTPURLResponse))
        } catch {
            return .failure(.failedApiRequest)
        }
    }
}

protocol NetworkingSession {
    func data(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse)
}

extension NetworkingSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await data(for: request, delegate: nil)
    }
}

extension URLSession: NetworkingSession {}
