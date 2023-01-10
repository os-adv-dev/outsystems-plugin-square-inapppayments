//
//  ChargeAPI.swift
//  TestApp
//
//  Created by Andre Grillo on 06/01/2023.
//

import Foundation

class ChargeApi {
    static public func processPayment(_ nonce: String, completion: @escaping (String?, String?) -> Void) {
        let url = URL(string: Constants.Square.CHARGE_URL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let json = ["nonce": nonce]
        let httpBody = try? JSONSerialization.data(withJSONObject: json)
        request.addValue("Application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error as NSError?{
                if error.domain == NSURLErrorDomain {
                    DispatchQueue.main.async {
                        completion("", "Could not contact host")
                    }
                } else {
                    DispatchQueue.main.async {
                        completion("", "Something went wrong")
                    }
                }
            } else if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                        DispatchQueue.main.async {
                            completion("success", nil)
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion("", json["errorMessage"] as? String)
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion("", "Failure")
                    }
                }
            }
        }.resume()
    }
}
