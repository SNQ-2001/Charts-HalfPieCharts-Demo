//
//  ViewController.swift
//  Charts-Demo
//
//  Created by TAISHIN MIYAMOTO on 2022/05/23.
//

import UIKit
import Charts
import Alamofire

class ViewController: UIViewController {

    @IBOutlet var chartView: PieChartView!

    public let viewModel = ViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        // 言語の使用割合グラフを表示
        self.setChart()
    }
}

extension ViewController: ChartViewDelegate {
    /// 言語の使用割合グラフを表示
    /// グラフの設定
    private func setChart() {
        chartView.drawEntryLabelsEnabled = false // グラフラのラベルを非表示
        chartView.chartDescription.enabled = false // グラフの説明文を非表示
        chartView.holeColor = .clear // 中央のくり抜き円の色
        chartView.holeRadiusPercent = 0.58 // 中央のくり抜き円の大きさ

        chartView.rotationEnabled = false // 回転無効化
        chartView.highlightPerTapEnabled = false // タップを無効化
        chartView.noDataTextColor = .clear // データなしの場合のテキストを透明にする

        // 半円用グラフ(これがないと円になる)
        chartView.maxAngle = 180
        chartView.rotationAngle = 180
        chartView.centerTextOffset = CGPoint(x: 0, y: -20)

        // 凡例の設定
        let l = chartView.legend
        l.textColor = .black
        l.horizontalAlignment = .center
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        l.xEntrySpace = 5
        l.yEntrySpace = 0

        // 使用言語を取得
        self.viewModel.getLanguages(
            url: "https://api.github.com/repos/apple/swift/languages"
        ) { (languagesNameArray, languagesValueArray)  in
            self.setData(languagesNameArray, languagesValueArray)
        }

        chartView.animate(xAxisDuration: 1.4, easingOption: .easeInOutCubic) // グラフに表示アニメーションを設定
    }


    /// 言語の使用割合グラフ
    /// データの作成
    private func setData(_ languagesNameArray: [String], _ languagesValueArray: [Int]) {

        let languagesArray = self.viewModel.createLanguageArray(languagesNameArray: languagesNameArray, languagesValueArray: languagesValueArray)

        // PieChartデータを作成
        let entries = (0..<languagesArray.0.count).map { (i) -> PieChartDataEntry in
            return PieChartDataEntry(
                value: Double(languagesArray.1[i % languagesArray.1.count]),
                label: languagesArray.0[i % languagesArray.0.count]
            )
        }

        let set = PieChartDataSet(entries: entries, label: "")
        set.sliceSpace = 0 // 項目間のスペースを0にする
        set.selectionShift = 20 // 縮小

        // 使用言語割合グラフに適用する言語カラー配列を作成する
        let colors = self.viewModel.createLanguageColorArray(languagesArray: languagesArray.0)
        set.colors = colors // グラフの色

        let data = PieChartData(dataSet: set)
        chartView.data = data

        // 言語が多いとゴチャゴチャになるので値の非表示
        for set in chartView.data! {
            set.drawValuesEnabled = !set.drawValuesEnabled
        }

        chartView.setNeedsDisplay()
    }
}
