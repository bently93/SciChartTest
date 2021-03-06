//
//  ViewController.swift
//  SciChartTest
//
//  Created by n.leontev on 26.03.2020.
//  Copyright © 2020 charttest. All rights reserved.
//

import UIKit
import SnapKit
import SciChart
import RxCocoa
import RxSwift

class ViewController: UIViewController {
    
    private var surface: SCIChartSurface = SCIChartSurface()
   
    private let candleDataSeries = SCIOhlcDataSeries(xType: .date, yType: .double)
    private var endDate = Date()
    private let disposeBag = DisposeBag()
    
   private let scatterDataSeries = SCIXyDataSeries(xType: .date, yType: .double)
    
    private lazy var xAxis: SCICategoryDateAxis = {
        let xAxis: SCICategoryDateAxis = getAxisBase()
        xAxis.growBy = SCIDoubleRange(min: 0.01, max: 0.01)
        xAxis.axisInfoProvider = CandleAxisSeriesInfoProvider()
        return xAxis
    }()
    
    private lazy var yAxis: SCINumericAxis = {
        let yAxis: SCINumericAxis = getAxisBase()
        yAxis.growBy = SCIDoubleRange(min: 0.04, max: 0.16)
        yAxis.autoRange = .always
        //        yAxis.textFormatting = "#.######"
        return yAxis
    }()
    
    private lazy var horizontalLine: HorizontalLineAnnotation = {
        let horizontalLine = HorizontalLineAnnotation()
        horizontalLine.horizontalAlignment = .right
        horizontalLine.stroke = SCISolidPenStyle(color: UIColor.orange, thickness: 2)
        let annotationLabel = (self.createLabelWith(text: "Right Aligned Aligned", labelPlacement: .axis))
        horizontalLine.annotationLabels.add(annotationLabel)
        return horizontalLine
    }()
    
    private(set) var gestureModifier: SCIGestureModifier?
    private(set) var rolloverModifier: SCIRolloverModifier?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(surface)
        
        surface.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let reloadBtn = UIButton()
        reloadBtn.setTitle("Reload", for: .normal)
        self.view.addSubview(reloadBtn)
        
        reloadBtn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50)
            make.left.equalToSuperview().offset(8)
        }
        
        reloadBtn.rx.tap
            .subscribe(onNext: { [unowned self] _ in
                self.updateXDateFormat()
                self.candleDataSeries.clear()
                self.removeSeries()
                self.addCandleSeries()
                self.endDate = Date()
                self.addDataSeries()
            })
            .disposed(by: self.disposeBag)
        
        let loadNextBtn = UIButton()
        loadNextBtn.setTitle("Insert data", for: .normal)
        self.view.addSubview(loadNextBtn)
        
        loadNextBtn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50)
            make.left.equalTo(reloadBtn.snp.right).offset(8)
        }
        
        loadNextBtn.rx.tap
            .subscribe(onNext: { [unowned self] _ in
                self.addDataSeries()
            })
            .disposed(by: self.disposeBag)
        
       setupChart()
    }
    
    private func setupChart() {
        
        let zoomPan = SCIZoomPanModifier()
        zoomPan.receiveHandledEvents = true
        //определяем границле x y
        zoomPan.clipModeX = .clipAtExtents
       
        SCIUpdateSuspender.usingWith(surface) {
            self.surface.xAxes.add(self.xAxis)
            self.surface.yAxes.add(self.yAxis)
            self.surface.chartModifiers.add(self.createDefaultModifiers())
        }
        addCandleSeries()
        addDataSeries()
        updateXDateFormat()
    }
    
    private func createDefaultModifiers() -> SCIModifierGroup {
        //для скрола по осям
        let zoomPan = SCIZoomPanModifier()
        zoomPan.receiveHandledEvents = true
        //определяем границле x y
        zoomPan.clipModeX = .clipAtExtents
        
        
        let modifierGroup = SCIModifierGroup()
        modifierGroup.childModifiers.add(zoomPan)
        self.rolloverModifier = SCIRolloverModifier()
        
        rolloverModifier?.verticalLineStyle = SCISolidPenStyle(color: .gray, thickness: 1.0, strokeDashArray: [4.0, 8.0, 4.0, 8.0])
        
        modifierGroup.childModifiers.add(rolloverModifier!) // точки на графике
        self.gestureModifier = SCIGestureModifier(rolloverModifier: rolloverModifier!, zoomPanModifier: zoomPan)
        
        modifierGroup.childModifiers.add(gestureModifier!)
        return modifierGroup
    }
    
    func updateXDateFormat(){
        var dateFormat = ""
        switch Int.random(in: 0..<4) {
        case 0: dateFormat = "HH:mm:ss"
        case 1: dateFormat = "yyyy"
        case 2: dateFormat = "d MMM HH:mm"
        case 3: dateFormat = "dMMM"
        default: dateFormat = "HH:mm"
        }
        
        self.xAxis.labelProvider = SCITradeChartAxisLabelProvider(labelFormatter: CustomLabelFormatter(dateFormat: dateFormat))
      }
      
     private func removeSeries() {
            SCIUpdateSuspender.usingWith(self.surface) { [weak self] in
                guard let self = self else { return }
                self.surface.xAxes.clear()
                self.surface.xAxes.add(items: self.xAxis)
                self.surface.renderableSeries.clear()
            }
        }
    
    func addCandleSeries(){
        let series = SCIFastCandlestickRenderableSeries()
        series.dataSeries = self.candleDataSeries
        
        series.strokeUpStyle = SCISolidPenStyle(color: .green, thickness: 1) // цвет линий зеленой свечки
        series.strokeDownStyle = SCISolidPenStyle(color: .red, thickness: 1) // цвет линий красной свечки
        
        series.fillUpBrushStyle = SCISolidBrushStyle(color: .green) // цвет заливки самой свечи зеленой
        series.fillDownBrushStyle = SCISolidBrushStyle(color: .red) // цвет заливки красной свечи
        series.dataPointWidth = 0.5
        

        let pointMarker = SCISpritePointMarker(drawer: CustomPointMarkerDrawer(image: #imageLiteral(resourceName: "buyPoint.pdf")))
        pointMarker.size = CGSize(width: 40, height: 40)
        
        let rSeries = SCIXyScatterRenderableSeries()
        rSeries.dataSeries = scatterDataSeries
        rSeries.pointMarker = pointMarker
        
         
        
        SCIUpdateSuspender.usingWith(self.surface) { [weak self] in
            guard let self = self else { return }
            self.surface.renderableSeries.add(items: series, rSeries)
            self.surface.zoomExtentsY()
            self.xAxis.updateMeasurements()
        }
    }
    
    func addDataSeries(){
        SCIUpdateSuspender.usingWith(self.surface) { [weak self] in
            let marketDataService = SCDMarketDataService(start: self?.endDate ?? Date(), timeFrameMinutes: Double.random(in: 0..<1000), tickTimerIntervals: 0.005)
            let data = marketDataService.getHistoricalData( Int.random(in: 100..<1000))
            self?.endDate = data.dateData.getValueAt(data.dateData.count - 1)
            self?.visibleRange(dataCount: data.count)
            self?.candleDataSeries.insert(x: data.dateData, open: data.openData, high: data.highData, low: data.lowData, close: data.closeData, at: 0)
    
            
            for i in 0..<data.dateData.count {
                if i % 3 == 0 {
                    let date = data.dateData.getValueAt(i)
                    let closePrrice =  data.closeData.getValueAt(i)
                    self?.scatterDataSeries.insert(x: date, y: closePrrice, at: 0)
                }
            }
            
            self?.xAxis.updateMeasurements()
            
            guard let self = self else { return }
            
            self.horizontalLine.set(x1: 1)
            self.horizontalLine.set(y1: data.highData.itemsArray.first ?? 0)
            self.surface.annotations = SCIAnnotationCollection(collection: [self.horizontalLine])
        }
    }
    
    func visibleRange(dataCount: Int) {
        let rangeRight = dataCount
        let rangeLeft = dataCount - Int.random(in: 30..<45)
        
        self.xAxis.visibleRange = SCIDoubleRange(min: Double(rangeLeft), max: Double(rangeRight))
    }
    
    private func getAxisBase<T>()-> T where T: SCIAxisBase<ISCIComparable> {
        let axis = T()
        axis.drawMajorBands = false // Убирает цвет группы
        
        axis.drawMinorTicks = false // нижние линии на оси
        axis.drawMajorTicks = false// нижние линии на оси
        
        axis.drawMajorGridLines = true
        axis.drawMinorGridLines = false
        axis.majorGridLineStyle = SCISolidPenStyle(color: UIColor.gray.withAlphaComponent(0.5), thickness: 1.0)
        axis.tickLabelStyle = SCIFontStyle(fontDescriptor: UIFont.systemFont(ofSize: 12).fontDescriptor, andTextColor: UIColor.gray)
        return axis
    }
    
     fileprivate func createLabelWith(text: String?, labelPlacement: SCILabelPlacement) -> SCIAnnotationLabel {
            let annotationLabel = SCIAnnotationLabel()
            if (text != nil) {
                annotationLabel.text = text!
            }
            annotationLabel.labelPlacement = labelPlacement
    
            return annotationLabel
        }
}


class CustomPointMarkerDrawer: ISCISpritePointMarkerDrawer {
    
    let image: UIImage
    
    init(image: UIImage) {
        self.image = image
    }
    
    func onDraw(_ bitmap: SCIBitmap!, with penStyle: SCIPenStyle!, andBrushStyle brushStyle: SCIBrushStyle!) {
        bitmap.context.saveGState()
        let rect = CGRect(origin: .zero, size: CGSize(width: CGFloat(bitmap.width), height: CGFloat(bitmap.height)))
        bitmap.context.translateBy(x: 0.0, y: CGFloat(bitmap.context.height))
        bitmap.context.scaleBy(x: 1.0, y: -1.0)
        bitmap.context.draw(image.cgImage!, in: rect)
        bitmap.context.restoreGState()
    }
}
