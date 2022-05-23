//
//  ViewModel.swift
//  Charts-Demo
//
//  Created by 宮本大新 on 2022/05/23.
//

import UIKit
import Alamofire

class ViewModel: NSObject {
    /// リポジトリで使用されている言語を取得
    /// ↓
    /// 使用割合の高い順に並び替え
    ///
    /// - parameters:
    ///  - url: 言語情報の取得可能なAPIをリポジトリ情報から指定
    ///  - completion: 言語リストと言語割合リストを返す
    ///
    /// EX) https://api.github.com/repos/apple/swift/languages
    ///
    public func getLanguages(
        url: String,
        completion: @escaping ([String], [Int]) -> Void
    ) {
        var languagesNameArray: [String] = []
        var languagesValueArray: [Int] = []

        AF.request(url, method: .get).responseData { response in
            do {
                guard let data = response.data else { return }
                let languages = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Int]
                guard let languagesDict = languages else { return }

                // 使用割合の高い言語順に並び替える
                let languagesSort = languagesDict.sorted { $0.1 > $1.1 } .map { $0 }

                for language in languagesSort {
                    languagesNameArray.append(language.key)
                    languagesValueArray.append(language.value)
                }
                completion(languagesNameArray, languagesValueArray)
            } catch {
                completion(languagesNameArray, languagesValueArray)
            }
        }
    }

    /// 使用言語割合グラフ用のデータを作成する(言語選別)
    ///
    /// - parameters:
    ///  - languagesNameArray: 全ての使用言語名
    ///  - languagesValueArray: 全ての使用言語割合
    ///
    /// - returns:
    ///  - newLanguagesNameArray: 使用割合が0.5%以上の言語名のみ
    ///  - newLanguagesValueArray: 使用割合が0.5%以上の言語割合のみ
    ///
    public func createLanguageArray(languagesNameArray: [String], languagesValueArray: [Int]) -> ([String], [Double]) {
        let languagesValueSum = languagesValueArray.reduce(0, +) // 配列合計

        var newLanguagesNameArray: [String] = []
        var newLanguagesValueArray: [Double] = []

        // 割合が0.5％以上の言語を配列に格納
        for i in 0..<languagesValueArray.count {
            let percent = floor((Double(languagesValueArray[i]) / Double(languagesValueSum)) * 1000) / 10
            if percent >= 0.5 {
                newLanguagesNameArray.append(languagesNameArray[i])
                newLanguagesValueArray.append(percent)
                print("\(languagesNameArray[i]): \(percent)%")
            }
        }

        var newLanguagesValueSum: Double = 0 // 割合合計

        for i in newLanguagesValueArray {
            newLanguagesValueSum += i
        }

        // 割合が0.5より小さい言語はOtherとしてまとめる & 言語がなかった場合、"No Language"を返す
        if (100 - newLanguagesValueSum) != 0.0 && (100 - newLanguagesValueSum) != 100.0 {
            newLanguagesNameArray.append("Other")
            newLanguagesValueArray.append(round((100 - newLanguagesValueSum) * 100) / 100)
            print("Other: \(floor((100 - newLanguagesValueSum) * 100) / 100)%")
        } else if (100 - newLanguagesValueSum) == 100.0 {
            newLanguagesNameArray.append("No Language")
            newLanguagesValueArray.append(100)
            print("No Language")
        }

        return (newLanguagesNameArray, newLanguagesValueArray)
    }

    /// 使用言語割合グラフに適用する言語カラー配列を作成
    ///
    /// - parameters:
    ///  - languagesArray: 言語配列
    ///
    /// - returns: 言語カラー配列
    ///
    public func createLanguageColorArray(languagesArray: [String]) -> [UIColor] {
        var colors: [UIColor] = []
        for i in languagesArray {
            colors.append(UIColor(language: i))
        }

        return colors
    }
}
