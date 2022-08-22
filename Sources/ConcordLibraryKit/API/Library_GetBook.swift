//
//  Library_GetBook.swift
//  ConcordLibrary
//
//  Created by Bashir Rahmah on 4/7/2022.
//

import Foundation
import SwiftSoup

extension Library_APIManager {
    static func getBook(id: String, completion: @escaping (Result<Library_BookDetail, Error>) -> Void) {
        // MARK: - Values
        var stockItems = [Library_BookStockItem]()
        var infoRows = [Library_BookInfoRowItem]()
        // MARK: REST
        self.makeCall(
            path: "library/search/results/\(id)?fromOpac=true&origin=&reloadPage=true",
            method: .get,
            body: "",
            headers: ["Accept": "text/html"]
        ) { result in
            if case .success(let res) = result {
                do {
                    // Doc
                    let doc: Document = try SwiftSoup.parse(res)
                    // MARK: - Book Elms
                    let BookElms: Elements = try doc.select("#itemDetailTabs .tab-pane tr")
                    for bookElm in BookElms {
                        var stockItem = Library_BookStockItem(barcode: "", site: "", section: "", callNumber: "", status: "", isStatusSuccess: false)
                        if let barcode = try? bookElm.select("td:nth-child(1)").text(trimAndNormaliseWhitespace: true) {
                            stockItem.barcode = barcode
                        }
                        if let site = try? bookElm.select("td:nth-child(2)").text(trimAndNormaliseWhitespace: true) {
                            stockItem.site = site
                        }
                        if let section = try? bookElm.select("td:nth-child(3)").text(trimAndNormaliseWhitespace: true) {
                            stockItem.section = section
                        }
                        if let callNumber = try? bookElm.select("td:nth-child(4)").text(trimAndNormaliseWhitespace: true) {
                            stockItem.callNumber = callNumber
                        }
                        if let status = try? bookElm.select("td:nth-child(5)").text(trimAndNormaliseWhitespace: true) {
                            stockItem.status = status
                        }
                        if let isStatusSuccess = try? bookElm.select("td:nth-child(5) span").hasClass("label-success") {
                            stockItem.isStatusSuccess = isStatusSuccess
                        }
                        if !stockItem.id.isEmpty {
                            stockItems.append(stockItem)
                        }
                    }
                    // MARK: - Info Rows
                    let infoRowsElms: Elements = try doc.select(".col-xs-12.col-sm-8 table tr")
                    for bookElm in infoRowsElms {
                        var infoRowItem = Library_BookInfoRowItem(label: "", value: "")
                        if let label = try? bookElm.select("td:nth-child(1)").text(trimAndNormaliseWhitespace: true) {
                            infoRowItem.label = label
                        }
                        if let value = try? bookElm.select("td:nth-child(2)").text(trimAndNormaliseWhitespace: true) {
                            infoRowItem.value = value
                        }
                        if !infoRowItem.value.isEmpty && !infoRowItem.label.isEmpty {
                            infoRows.append(infoRowItem)
                        }
                    }
                    // MARK: - Completion
                    completion(.success(Library_BookDetail(resultId: id, stockItems: stockItems, infoRows: infoRows)))
                } catch {
                    completion(.failure(RuntimeError("FAILED TO EXTRACT USEFUL DATA FROM Search Book")))
                    return
                }
            } else {
                completion(.failure(RuntimeError("FAILED TO FETCH Search Book")))
            }
        }
    }
    
}
