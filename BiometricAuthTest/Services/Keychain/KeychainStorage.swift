//
//  KeychainStorage.swift
//  BiometricAuthTest
//
//  Created by Florentin Lupascu on 23/09/2021.
//

import Foundation

enum KeychainStorage {
    static let key = "BiometricAuthTestService"
    
    static func getCredentials() -> Credentials? {
        if let myCredentialsString = KeychainWrapper.standard.string(forKey: Self.key) {
            return Credentials.decode(myCredentialsString)
        } else {
            return nil
        }
    }
    
    static func saveCredentials(_ credentials: Credentials) -> Bool {
        if KeychainWrapper.standard.set(credentials.encoded(), forKey: Self.key) {
            return true
        } else {
            return false
        }
    }
}

enum KeychainError: Error {
    case errorStatus(OSStatus)
}
