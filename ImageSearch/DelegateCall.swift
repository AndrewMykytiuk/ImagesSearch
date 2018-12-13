//
//  DelegateCall.swift
//  ImageSearch
//
//  Created by User on 13/04/2018.
//  Copyright © 2018 MPTechnologies. All rights reserved.
//

import Foundation
import UIKit

struct DelegatedCall<Input> {
    
    private(set) var callback: ((Input) -> Void)?
    
    mutating func delegate<Object : AnyObject>(to object: Object, with callback: @escaping (Object, Input) -> Void) {
        self.callback = { [weak object] input in
            guard let object = object else {
                return
            }
            callback(object, input)
        }
    }
}
