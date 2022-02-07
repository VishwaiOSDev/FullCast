//
//  Authentication.swift
//  FullCast
//
//  Created by Vishwa  R on 03/02/22.
//

import Foundation

struct Authentication {
    
    let url = "https://api.tikapp.ml/api/auth"
    
    struct Token: Decodable {
        var message : String
    }
    
    func sendSignUpRequestToServer(body : [String : String]) {
        let urlString = "\(url)/register"
        do {
            guard let url = URL(string: urlString) else { return }
            var request = URLRequest(url: url)
            let jsonBody = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpMethod = "POST"
            request.httpBody = jsonBody
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            performRequest(with: request)
        } catch {
            print("Error parsing the signup request \(error.localizedDescription)")
        }
    }
    
    func sendLoginRequestToServer(body : [String : String]) {
        let urlString = "\(url)/login"
        do {
            guard let url = URL(string: urlString) else { return }
            var request = URLRequest(url: url)
            let jsonBody = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpMethod = "POST"
            request.httpBody = jsonBody
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            performRequest(with: request)
        } catch {
            print("Error parsing the login request \(error.localizedDescription)")
        }
    }
    
    func performRequest(with request: URLRequest) {
        URLSession.shared.dataTask(with: request) { [self] data, _ , error in
            if let e = error {
                print(e.localizedDescription)
            }
            do {
                guard let safeData = data else { return }
                guard let token = parseJSON(safeData) else { return }
                print("This is the token from the Server. \(token)")
            }
        }.resume()
    }
    
    func parseJSON(_ data : Data) -> Token? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(Token.self, from: data)
            return decodedData
        } catch {
            print("Error parsing to JSON \(error.localizedDescription)")
            return nil
        }
    }
}
