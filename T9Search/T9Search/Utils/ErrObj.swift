//
//  ErrObj.swift
//  T9Search
//
//  Created by George Vashakidze on 3/1/19.
//  Copyright © 2019 Toptal. All rights reserved.
//

import Foundation

protocol ErrorProtocol: LocalizedError {
    var title: String? { get }
    var code: Int { get }
}

struct CustomError: ErrorProtocol {
    
    var title: String?
    var code: Int
    var errorDescription: String? { return _description }
    var failureReason: String? { return _description }
    
    private var _description: String
    
    init(title: String? = nil, description: String, code: Int) {
        self.title = title ?? "Error"
        self._description = description
        self.code = code
    }
}
