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
        trimmingCharacters(in: CharacterSet(charactersIn: " "))
    }

    func left(idx: Int = 0) -> String {
        guard idx >= 0, idx < count else { return "" }
        return String(self[index(startIndex, offsetBy: idx)])
    }
}

/// Returns a localized string from the main bundle's string file.
/// - Parameters:
///   - key: The key to search for.
///   - standardString: The string to be used if `key` was not found.
///   - tableName: The name of the `*.strings` file. If `nil`, `Localizable.strings` will be used.
internal func localizedString(_ key: String, standardString: String? = nil, table tableName: String? = nil) -> String {
    Bundle.main.localizedString(forKey: key, value: standardString, table: tableName)
}
