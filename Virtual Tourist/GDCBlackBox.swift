//
//  GDCBlackBox.swift
//  On The Map
//
//  Created by Hayne Park on 11/5/16.
//  Copyright © 2016 Alexander Bui. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(updates: @escaping () -> Void) {
    OperationQueue.main.addOperation {
        updates()
    }
}
