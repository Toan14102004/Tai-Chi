//
//  EnvironmentValues.swift
//  Taichi
//
//  Created by Toan Nguyen on 4/12/24.
//

import Foundation
import SwiftUI

extension EnvironmentValues {
    var dismissLegacy: () -> Void {
        {
            if #available(iOS 15, *) {
                dismiss.callAsFunction()
            } else {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
