//
//  HorizontalLineAnnotation.swift
//  SciChartTest
//
//  Created by n.leontev on 15.06.2020.
//  Copyright © 2020 charttest. All rights reserved.
//

import SciChart.Protected.SCIAnnotationLabel
import SciChart.Protected.SCIAnnotationBase

class HorizontalLineAnnotation: SCIHorizontalLineAnnotation {
    
    private var initialAxisWidth: CGFloat?
    
    override func updateAnnotationCoordinates(_ annotationCoordinates: SCIAnnotationCoordinates!, insideFrame frame: CGRect, xCoordinateCalculator xCalc: ISCICoordinateCalculator!, andYCoordinateCalculator yCalc: ISCICoordinateCalculator!) {
        super.updateAnnotationCoordinates(annotationCoordinates, insideFrame: frame, xCoordinateCalculator:xCalc , andYCoordinateCalculator: yCalc)
        
        let yAxis = parentSurface.yAxes.firstObject
        
        if initialAxisWidth == nil {
            initialAxisWidth = yAxis.axisLayoutState.axisSize
        }
    
        let labelWidth = annotationLabels.firstObject.frame.width
        let offset = labelWidth - (labelWidth - initialAxisWidth!) / 2
        
        yAxis.axisTickLabelStyle = SCIAxisTickLabelStyle(alignment: .center, andMargins: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: offset))
    }
}
