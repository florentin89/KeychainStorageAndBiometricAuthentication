//
//  Credentials.swift
//  BiometricAuthTest
//
//  Created by Florentin Lupascu on 22/09/2021.
//

import Foundation

struct Credentials: Codable {
    var memberCode: String = ""
    var memberPin: String = ""
    func encoded() -> String {
        let encoder = JSONEncoder()
        let credentialsData = try! encoder.encode(self)
        return String(data: credentialsData, encoding: .utf8)!
    }

    static func decode(_ credentialsString: String) -> Credentials {
        let decoder = JSONDecoder()
        let jsonData = credentialsString.data(using: .utf8)
        return try! decoder.decode((Credentials.self), from: jsonData!)
    }
}
