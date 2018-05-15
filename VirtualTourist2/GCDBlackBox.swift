//
//  GCDBlackBox.swift
//  CaptivateSpace
//
//  Created by Joshua Schindler on 4/22/18.
//  Copyright © 2018 Joshua Schindler. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
