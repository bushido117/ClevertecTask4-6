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
    
    static func loadATMData(completionHandler: @escaping (Result<[ATMElement], APIError>) -> Void) {
        guard let url = URL(string: "https://belarusbank.by/api/atm") else { completionHandler(.failure(.invalidURL))
            return
        }
        let session = URLSession(configuration: .default)
        session.dataTask(with: url) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    completionHandler(.failure(.invalidResponseStatus))
                }
                return
            }
            guard error == nil else {
                DispatchQueue.main.async {
                    completionHandler(.failure(.dataTaskError))
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(.failure(.corruptData))
                }
                return
            }
            do {
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode([ATMElement].self, from: data)
                DispatchQueue.main.async {
                    completionHandler(.success(decodedData))
                }
            } catch {
                DispatchQueue.main.async {
                    completionHandler(.failure(.decodingError))
                }
                return
            }
        }
        .resume()
    }
}
