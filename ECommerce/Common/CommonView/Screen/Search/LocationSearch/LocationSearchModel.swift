//
//  LocationSearchModel.swift
//  ECommerce
//
//  Created by wizard.os25 on 11/1/26.
//

import Foundation

public struct LocationSearchKeyword {
    public let id: String
    public let keyword: String
    public let timestamp: Date
    
    public init(
        id: String = UUID().uuidString,
        keyword: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.keyword = keyword
        self.timestamp = timestamp
    }
}
