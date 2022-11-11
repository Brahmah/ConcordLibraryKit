//
//  Library_Book.swift
//  ConcordLibrary
//
//  Created by Bashir Rahmah on 4/7/2022.
//

import Foundation

struct Library_Book: Codable & Identifiable {
    var id: String {
        resultId
    }
    var title: String
    var imageLink: String?
    var meta: String
    var stock: String
    var resultId: String
    var isStatusSuccess: Bool
    
    var image: URL {
        URL(string: imageLink ?? "") ?? URL(string: "https://syndetics.com/hw7.pl?isbn=bdjhdfhdfhjdf/LC.jpg")!
    }
}

struct Library_BookDetail: Codable {
    var resultId: String
    var stockItems: [Library_BookStockItem]
    var infoRows: [Library_BookInfoRowItem]
}

struct Library_BookStockItem: Codable & Identifiable {
    var id: String {
        barcode + site + section + callNumber + status
    }
    var barcode: String
    var site: String
    var section: String
    var callNumber: String
    var status: String
    var isStatusSuccess: Bool
}

struct Library_BookInfoRowItem: Codable & Identifiable {
    var id: String {
        label + value
    }
    var label: String
    var value: String
}

struct Library_BookLoanItem: Codable & Identifiable {
    var id: String {
        barcode + title + loanDate + dueDate + returnedDate
    }
    var context: loanItemContexts
    var barcode: String
    var title: String
    var loanDate: String
    var dueDate: String
    var returnedDate: String
    
    enum loanItemContexts: Codable {
        case current
        case history
    }
}

struct Library_Book_Loans: Codable {
    let history: [Library_BookLoanItem]
    let current: [Library_BookLoanItem]
}
