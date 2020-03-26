//
//  SCIGestureModifier.swift
//  SciChartTest
//
//  Created by n.leontev on 26.03.2020.
//  Copyright © 2020 charttest. All rights reserved.
//

import RxSwift
import SciChart.Protected.SCIGestureModifierBase

extension Reactive where Base: SCIGestureModifier {
    var enableScrollModifier: Observable<Bool> {
        return self.base.enableScrollModifier.asObserver()
    }
}

class SCIGestureModifier: SCIGestureModifierBase {
    
    fileprivate var enableScrollModifier = PublishSubject<Bool>()
 
    private let rolloverModifier: SCIRolloverModifier
    private let zoomPanModifier: SCIZoomPanModifier
    
    init(rolloverModifier: SCIRolloverModifier, zoomPanModifier: SCIZoomPanModifier){
        self.rolloverModifier = rolloverModifier
        self.zoomPanModifier = zoomPanModifier
        super.init()
    
        enableScrollModifier(isEnabled: true)
    }
    
    override func createGestureRecognizer() -> UIGestureRecognizer {
      return UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
    }
    
    private func enableScrollModifier(isEnabled: Bool) {
        self.enableScrollModifier.onNext(isEnabled)
        self.zoomPanModifier.isEnabled = isEnabled
        self.rolloverModifier.isEnabled = !isEnabled
        if self.rolloverModifier.modifierSurface != nil { // не убирать, тк может быть nil
            self.rolloverModifier.modifierSurface.isHidden = isEnabled
        }
    }
    
    @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        switch gestureReconizer.state {
        case .began: self.enableScrollModifier(isEnabled: false)
        case .ended: self.enableScrollModifier(isEnabled: true)
        
        default: break
        }
    }
}
