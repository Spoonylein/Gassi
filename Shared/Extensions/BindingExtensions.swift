//
//  BindingExtensions.swift
//  Gassi
//
//  Created by Jan Löffel on 31.07.23.
//

import SwiftUI

extension Binding {
    
    public static func convertOptionalValue<T>(_ optionalValue: Binding<T?>, fallback: T) -> Binding<T> {
        return Binding<T>(get: {
            optionalValue.wrappedValue ?? fallback
        }, set: {
            optionalValue.wrappedValue = $0
        })
    }
    
    public static func convertOptionalString(_ optionalString: Binding<String?>, fallback: String = "") -> Binding<String> {
        convertOptionalValue(optionalString, fallback: fallback)
    }
    
}
