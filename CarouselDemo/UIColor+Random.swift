//
//  UIColor+Random.swift
//  CarouselDemo
//
//  Created by Ugur Bozkurt on 28/04/2024.
//

import UIKit

extension UIColor {
    static var random: UIColor {
        return .init(red: .random(in: 0.5...1), green: .random(in: 0.5...1), blue: .random(in: 0.5...1), alpha: 1)
    }
}
