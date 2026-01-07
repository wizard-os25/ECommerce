//
//  DoubleExtensions.swift
//  CoreUtilsKit
//
//  Created by NhoNH on 14/01/2024.
//  Copyright © 2024 ViettelPay App Team. All rights reserved.
//

public extension Double {
    func convertToString() -> String {
        let rounded = self.rounded()
        return String(format: "%.0lf", rounded)
    }
}
