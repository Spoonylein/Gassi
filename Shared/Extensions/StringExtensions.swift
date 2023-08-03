//
//  StringExtensions.swift
//  Gassi
//
//  Created by Jan Löffel on 31.07.23.
//

import Foundation

extension String {
    
    /// Trims the `String` by removing leading and trailing spaces.
    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet(charactersIn: " "))
    }
    
    func left(idx: Int = 0) -> String {
            String(self[index(startIndex, offsetBy: idx)])
        }
}

/// Returns a localized string from a main bundle's string file
/// - Parameters:
///   - key: The key to search for
///   - standardString: The string to be used if `key` was not found
///   - tableName: The name of the `*.strings` file. If `nil` then `Localizable.strings` will be used.
///
///   Copy this func to each bundle where you want to use localization.
internal func localizedString(_ key: String, standardString: String? = nil, table tableName: String? = nil) -> String {
    
    /// This is the identifier of the bundle to use for localization.
//    let bundleIdentifier = "Gassi"
    var result: String = standardString ?? key
    
//    if let bundle = Bundle.init(identifier: bundleIdentifier) {
//        result = bundle.localizedString(forKey: key, value: standardString, table: tableName)
//    }
//
//    return result

    // Use this for the main bundle.
    result = Bundle.main.localizedString(forKey: key, value: standardString, table: tableName)
    return result
}
