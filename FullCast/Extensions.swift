//
//  Extensions.swift
//  FullCast
//
//  Created by Vishwa  R on 06/02/22.
//

import Foundation

extension Date {
    func toString( dateFormat format  : String ) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}

extension URL {
    static var documents : URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
