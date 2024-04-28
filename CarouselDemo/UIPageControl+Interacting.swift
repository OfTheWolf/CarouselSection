//
//  UIPageControl+Interacting.swift
//  CarouselDemo
//
//  Created by Ugur Bozkurt on 28/04/2024.
//

import UIKit

extension UIPageControl {
    /// Returns true if the page control is long pressed and interacting continously to change the page.
    var isInteracting: Bool {
        let longPress = gestureRecognizers?.first {$0 is UILongPressGestureRecognizer}
        let state = longPress?.state
        return state == .changed
    }
}
