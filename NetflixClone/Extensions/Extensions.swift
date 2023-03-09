//
//  Extensions.swift
//  NetflixClone
//
//  Created by mac on 21/01/23.
//

import Foundation

extension String {
    func capitalizedFirstLetter() -> String {
        return self.prefix(1).uppercased() + self.lowercased().dropFirst()
    }
}
