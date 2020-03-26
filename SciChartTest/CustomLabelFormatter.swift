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


class CustomLabelFormatter: SCICategoryDateAxis, ISCILabelFormatter {
    func formatLabel(_ dataValue: Double) -> ISCIString! {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dMMM HH:MM"
        let valueToFormat = SCIComparableUtil.toDate(dataValue as ISCIComparable)
        return dateFormatter.string(from: valueToFormat ?? Date()) as ISCIString
    }
    func formatCursorLabel(_ dataValue: Double) -> ISCIString! {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dMMM HH:MM"
        let valueToFormat = SCIComparableUtil.toDate(dataValue as ISCIComparable)
        return dateFormatter.string(from: valueToFormat ?? Date()) as ISCIString
    }
    func update(_ axis: ISCIAxisCore!) {
    }
}
