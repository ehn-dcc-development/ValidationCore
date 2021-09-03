//
//  SignedData.swift
//  
//
//  Created by Dominik Mocher on 30.08.21.
//

import Foundation

public protocol SignedData : Codable {
    var hash: Data? { get set }
    var isEmpty: Bool { get }
    init()
}
