//
//  APIService.swift
//  Task4
//
//  Created by Вадим Сайко on 9.01.23.
//

import Foundation

struct APIService {
    
    enum APIError: Error {
        case invalidURL
        case invalidResponseStatus
        case dataTaskError
        case corruptData
        case decodingError
    }
    
    static func loadData<T: Codable>(for url: String,
                                     type: T,
                                     completionHandler: @escaping (Result<T, APIError>) -> Void) {
        guard let url = URL(string: url) else { completionHandler(.failure(.invalidURL))
            return
        }
        let session = URLSession(configuration: .default)
        session.dataTask(with: url) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                    completionHandler(.failure(.invalidResponseStatus))
                return
            }
            guard error == nil else {
                    completionHandler(.failure(.dataTaskError))
                return
            }
            guard let data = data else {
                    completionHandler(.failure(.corruptData))
                return
            }
            do {
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(T.self, from: data)
                    completionHandler(.success(decodedData))
            } catch {
                    completionHandler(.failure(.decodingError))
                return
            }
        }
        .resume()
    }
}
