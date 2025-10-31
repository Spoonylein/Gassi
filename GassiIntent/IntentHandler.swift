//
//  IntentHandler.swift
//  GassiIntent
//
//  Created by Jan Löffel on 11.08.22.
//

import Intents

class AddPooIntentHandler: NSObject, AddPooIntentHandling {
    func handle(intent: AddPooIntent, completion: @escaping (AddPooIntentResponse) -> Void) {
        let response = AddPooIntentResponse(code: .success, userActivity: nil)
        completion(response)
    }
    
}

class AddPeeIntentHandler: NSObject, AddPeeIntentHandling {
    func handle(intent: AddPeeIntent, completion: @escaping (AddPeeIntentResponse) -> Void) {
        let response = AddPeeIntentResponse(code: .success, userActivity: nil)
        completion(response)
    }
    
}
