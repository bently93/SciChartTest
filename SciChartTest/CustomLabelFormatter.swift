//
//  CustomLabelFormatter.swift
//  SciChartTest
//
//  Created by n.leontev on 26.03.2020.
//  Copyright © 2020 charttest. All rights reserved.
//

import SciChart
import SciChart.Protected.SCIDefaultAxisInfoProvider
import SciChart.Protected.SCIAxisTooltip


class CustomLabelFormatter: ISCILabelFormatter {
    private let dateFormat: String
     var labelIndex = 0
    init(dateFormat: String) {
        self.dateFormat = dateFormat
    }
    
    func formatLabel(_ dataValue: Double) -> ISCIString! {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dMMM HH:MM"
//        let valueToFormat = SCIComparableUtil.toDate(dataValue as ISCIComparable)
//        return dateFormatter.string(from: valueToFormat ?? Date()) as ISCIString
        let dateFormat = labelIndex % 2 == 0 ? "MMM d" : "HH:mm"
            labelIndex += 1
            let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
                     let valueToFormat = SCIComparableUtil.toDate(dataValue as ISCIComparable)
            let datetext = dateFormatter.string(from: valueToFormat ?? Date()) as ISCIString
            print(datetext)
        return datetext
    }
    func formatCursorLabel(_ dataValue: Double) -> ISCIString! {
       formatLabel(dataValue)
    }
    
    func update(_ axis: ISCIAxisCore!) {
         labelIndex = 0
    }
}
