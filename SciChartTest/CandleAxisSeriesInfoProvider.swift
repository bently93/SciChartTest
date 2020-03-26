//
//  CandleAxisSeriesInfoProvider.swift
//  SciChartTest
//
//  Created by n.leontev on 26.03.2020.
//  Copyright © 2020 charttest. All rights reserved.
//

import SciChart
import SciChart.Protected.SCIDefaultAxisInfoProvider
import SciChart.Protected.SCIAxisTooltip

class CandleAxisSeriesInfoProvider: SCIDefaultAxisInfoProvider {
    class CustomAxisTooltip: SCIAxisTooltip {
        override func updateInternal(with axisInfo: SCIAxisInfo) -> Bool {
            self.text = axisInfo.axisFormattedDataValue.rawString
            self.backgroundColor = UIColor.black
            self.textAlignment = .center
            return true
        }
    }
    
    override func getAxisTooltipInternal(_ axisInfo: SCIAxisInfo, modifierType: AnyClass) -> ISCIAxisTooltip {
        if modifierType == SCIRolloverModifier.self {
            return CustomAxisTooltip(axisInfo: axisInfo)
        } else {
            return super.getAxisTooltipInternal(axisInfo, modifierType: modifierType)
        }
    }
}

