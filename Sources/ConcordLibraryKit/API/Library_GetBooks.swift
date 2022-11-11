//
//  Library_GetBooks.swift
//  ConcordLibrary
//
//  Created by Bashir Rahmah on 4/7/2022.
//

import Foundation
import SwiftSoup

extension Library_APIManager {
    static func getBooks(query: String, begin: String, completion: @escaping (Result<[Library_Book], Error>) -> Void) {
        // MARK: - Values
        var books = [Library_Book]()
        // MARK: REST
        self.makeCall(
            path: "library/search/keyword?usePane=true&searchSiteId=undefined&searchTerm=\(query.replacingOccurrences(of: " ", with: "%20"))&searchHasStr=&searchRangeFrom=&searchRangeTo=&begin=\(begin)&sort=0",
            method: .get,
            body: "",
            headers: ["Accept": "text/html"]
        ) { result in
            if case .success(let res) = result {
                do {
                    // Doc
                    let doc: Document = try SwiftSoup.parse(res)
                    // MARK: - Books
                    let BookElms: Elements = try doc.select("body > div.row.search-results-grid.search-results > div")
                    for bookElm in BookElms {
                        var book = Library_Book(title: "", imageLink: nil, meta: "", stock: "", resultId: "", isStatusSuccess: false)
                        if let title = try? bookElm.select("h5.panel-footer div:nth-child(1)").text(trimAndNormaliseWhitespace: true) {
                            book.title = title
                        }
                        if let stock = try? bookElm.select("h5.panel-footer div:nth-child(2) span small .label").text(trimAndNormaliseWhitespace: true) {
                            book.stock = stock.replacingOccurrences(of: "  ", with: " ")
                        }
                        if let author = try? bookElm.select("h5.panel-footer div:nth-child(2) small").text(trimAndNormaliseWhitespace: true) {
                            book.meta = author.replacingOccurrences(of: book.stock, with: "")
                        }
                        if let imageLink = try? bookElm.select(".panel-body img.cover-image").attr("src") {
                            if !imageLink.contains(".svg") {
                                book.imageLink = imageLink
                            }
                        }
                        if let resourceId = try? bookElm.select(".panel.panel-default.popover-holder.pointer").attr("data-resource-id") {
                            book.resultId = resourceId
                        }
                        if let isStatusSuccess = try? bookElm.select("h5.panel-footer div:nth-child(2) span small .label").hasClass("label-success") {
                            book.isStatusSuccess = isStatusSuccess
                        }
                        books.append(book)
                    }
                    // MARK: - Completion
                    completion(.success(books.unique(map: {$0.resultId})))
                } catch {
                    completion(.failure(RuntimeError("FAILED TO EXTRACT USEFUL DATA FROM Search Results")))
                    return
                }
            } else {
                completion(.failure(RuntimeError("FAILED TO FETCH Search Results")))
            }
        }
    }
    
    static func getBookLoans(completion: @escaping (Result<Library_Book_Loans, Error>, Bool) -> Void) {
        // MARK: - Values
        var current = [Library_BookLoanItem]()
        var history = [Library_BookLoanItem]()
        // MARK: REST
        self.makeCall(
            path: "core/myprofile#loanHistory",
            method: .get,
            body: "",
            headers: ["Accept": "text/html"]
        ) { result in
            if case .success(let res) = result {
                do {
                    if res.contains("/loginFromOpac") {
                        completion(.failure(RuntimeError("needsLogin")), true)
                    }
                    // Doc
                    let doc: Document = try SwiftSoup.parse(res)
                    // MARK: - History
                    let BookElmsHistory: Elements = try doc.select("body #myLoanHistory tbody tr")
                    for bookElm in BookElmsHistory {
                        var book = Library_BookLoanItem(context: .history, barcode: "", title: "", loanDate: "", dueDate: "", returnedDate: "")
                        if let barcode = try? bookElm.select("td:nth-child(1)").text(trimAndNormaliseWhitespace: true) {
                            book.barcode = barcode
                        }
                        if let title = try? bookElm.select("td:nth-child(2)").text(trimAndNormaliseWhitespace: true) {
                            book.title = title
                        }
                        if let loanDate = try? bookElm.select("td:nth-child(3)").text(trimAndNormaliseWhitespace: true) {
                            book.loanDate = loanDate
                        }
                        if let dueDate = try? bookElm.select("td:nth-child(4)").text(trimAndNormaliseWhitespace: true) {
                            book.dueDate = dueDate
                        }
                        if let returnedDate = try? bookElm.select("td:nth-child(5)").text(trimAndNormaliseWhitespace: true) {
                            book.returnedDate = returnedDate
                        }
                        if !book.title.isEmpty && !book.barcode.isEmpty {
                            history.append(book)
                        }
                    }
                    // MARK: - Current
                    let BookElmsCurrent: Elements = try doc.select("body #myCurrentLoans tbody tr")
                    for bookElm in BookElmsCurrent {
                        var book = Library_BookLoanItem(context: .current, barcode: "", title: "", loanDate: "", dueDate: "", returnedDate: "")
                        if let barcode = try? bookElm.select("td:nth-child(1)").text(trimAndNormaliseWhitespace: true) {
                            book.barcode = barcode
                        }
                        if let title = try? bookElm.select("td:nth-child(2)").text(trimAndNormaliseWhitespace: true) {
                            book.title = title
                        }
                        if let loanDate = try? bookElm.select("td:nth-child(3)").text(trimAndNormaliseWhitespace: true) {
                            book.loanDate = loanDate
                        }
                        if let dueDate = try? bookElm.select("td:nth-child(4)").text(trimAndNormaliseWhitespace: true) {
                            book.dueDate = dueDate
                        }
                        if !book.title.isEmpty && !book.barcode.isEmpty {
                            current.append(book)
                        }
                    }
                    // MARK: - Completion
                    completion(.success(Library_Book_Loans(history: history.unique(map: {$0.id}), current: current.unique(map: {$0.id}))), false)
                } catch {
                    completion(.failure(RuntimeError("FAILED TO EXTRACT USEFUL DATA FROM Search Results")), false)
                    return
                }
            } else {
                completion(.failure(RuntimeError("FAILED TO FETCH Search Results")), false)
            }
        }
    }
    
    static func getMyLibraryBadgeId(completion: @escaping (String) -> Void) {
        // MARK: REST
        self.makeCall(
            path: "core/myprofile/myaccount",
            method: .get,
            body: "",
            headers: ["Accept": "text/html"]
        ) { result in
            if case .success(let res) = result {
                do {
                    // Doc
                    let doc: Document = try SwiftSoup.parse(res)
                    if let libraryId = try? doc.select("#register-form > div > div:nth-child(2) > div:nth-child(1) > p").text(trimAndNormaliseWhitespace: true) {
                        completion(libraryId)
                    }
                } catch {
                    return
                }
            }
        }
    }
    
    
    public static func getRandomSearchQuery() -> String {
        ["Diary Of A Wimpy Kid", "1984", "Dragon Ball", "Maze Runner", "Ranger's Apprentice", "Shakespeare", "Hadith", "Animal Farm", "Harry Potter", "Minecraft"].randomElement()!
    }
}

extension Array {
    public func unique<T:Hashable>(map: ((Element) -> (T)))  -> [Element] {
        var set = Set<T>() //the unique list kept in a Set for fast retrieval
        var arrayOrdered = [Element]() //keeping the unique list of elements but ordered
        for value in self {
            if !set.contains(map(value)) {
                set.insert(map(value))
                arrayOrdered.append(value)
            }
        }
        
        return arrayOrdered
    }
}
