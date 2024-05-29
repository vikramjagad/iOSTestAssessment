//
//  WebServices.swift
//  iOSTestAssessment
//
//  Created by Vikram Jagad on 29/05/24.
//

import Foundation

enum WebServiceResponse<T> {
    case failure(Error)
    case success(T)
}

final class WebServices: NSObject {
    static let shared = WebServices()
    private override init() {}

    // MARK: - Constants
    struct Constants {
        static let kApiUrl = "https://jsonplaceholder.typicode.com"
    }

    // MARK: - Enums
    enum HttpMethod: String {
        case get
    }

    enum Errors: Error, Equatable {
        case invalidURL
        case invalidResponse
        case invalidStatus(Int)
    }

    enum EndPoint: String {
        case posts
    }

    // MARK: - Private property
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.networkServiceType = .default
        return URLSession(configuration: config)
    }()

    // MARK: - Private Methods
    private func buildUrl(endPoint: EndPoint) throws -> URL {
        guard var baseUrl = URL(string: Constants.kApiUrl) else { throw Errors.invalidURL }
        baseUrl.appendPathComponent(endPoint.rawValue)
        return baseUrl
    }

    func sendRequest<T: Decodable>(endPoint: EndPoint, headers: [String: String] = [:], body: Data? = nil,
                                   method: HttpMethod = .get) async -> WebServiceResponse<T> {
        do {
            let url = try buildUrl(endPoint: endPoint)
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
            request.httpMethod = method.rawValue
            request.httpBody = body
            print("\nRequest: \(method) \(url.absoluteString)")
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
            if let headerFields = request.allHTTPHeaderFields {
                print("Headers: \(headerFields)")
            }
            if let body = body, let string = String(data: body, encoding: .utf8) {
                print("Body: \(string)")
            }
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw Errors.invalidResponse
            }
            print("StatusCode: \(httpResponse.statusCode)")
            if let string = String(data: data, encoding: .utf8) {
                print("Response: \(string)")
            }
            guard httpResponse.statusCode == 200 else {
                return .failure(Errors.invalidStatus(httpResponse.statusCode))
            }
            guard let responseModel = try? JSONDecoder().decode(T.self, from: data) else {
                return .failure(Errors.invalidResponse)
            }
            return .success(responseModel)
        } catch let error {
            return .failure(error)
        }
    }
}
