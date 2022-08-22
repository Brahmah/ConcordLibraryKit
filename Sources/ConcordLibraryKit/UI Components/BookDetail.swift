//
//  BookDetail.swift
//  ConcordLibrary
//
//  Created by Bashir Rahmah on 4/7/2022.
//

import TelemetryClient
import SwiftUI

struct BookDetail: View {
    let book: Library_Book
    @State var stockItems = [Library_BookStockItem]()
    @State var infoRows = [Library_BookInfoRowItem]()
    
    var body: some View {
        Form {
            Library_BookRow(book: book)
            
            Section(header: Text("Availability")) {
                ForEach(stockItems) { item in
                    BookAvailabilityRow(item: item)
                }
            }
            
            if !infoRows.isEmpty {
                Section(header: Text("Overview")) {
                    ForEach(
                        infoRows.filter({$0.label != "Abstract" && $0.label != "Notes"})
                    ) { item in
                        HStack {
                            Text(item.label)
                                .font(.headline)
                            Spacer()
                            Text(item.value)
                                .font(.caption)
                            
                        }
                    }
                }
            }
            
            if let abstract = infoRows.first(where: {$0.label == "Abstract"}) {
                Section(header: Text(abstract.label)) {
                    Text(abstract.value)
                        .foregroundColor(.gray)
                }
            }
            
            if let notes = infoRows.first(where: {$0.label == "Notes"}) {
                Section(header: Text(notes.label)) {
                    Text(notes.value)
                        .foregroundColor(.gray)
                }
            }
            
        }
        .onAppear {
            Library_APIManager.getBook(id: book.resultId) { result in
                if case .success(let res) = result {
                    stockItems = res.stockItems
                    infoRows = res.infoRows
                }
            }
//            var telem = getTelemetry()
//            telem.updateValue(book.resultId, forKey: "bookResultId")
//            telem.updateValue(book.title, forKey: "bookTitle")
//            TelemetryManager.send("viewBookDetail", with: telem)
        }
    }
}

struct BookDetail_Previews: PreviewProvider {
    static var previews: some View {
        BookDetail(book: Library_Book(title: "Harry Potter origami. Vol. 2", imageLink: "https://syndetics.com/hw7.pl?isbn=9781338745184/LC.jpg", meta: "by John Rocky", stock: "3 of 12", resultId: "1008530", isStatusSuccess: false))
    }
}

struct BookAvailabilityRow: View {
    let item: Library_BookStockItem
    @State var isExpanded: Bool = false
    
    var body: some View {
        Button {
            isExpanded.toggle()
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred(intensity: 1.0)
        } label: {
            VStack(alignment: .leading) {
                HStack {
                    Circle()
                        .foregroundColor(item.isStatusSuccess ? .green : .red)
                        .frame(width: 10, height: 10)
                    VStack(alignment: .leading) {
                        Text(item.site)
                            .font(.headline)
                        HStack(spacing: 5) {
                            Text(item.section)
                                .font(.caption)
                            Image(systemName: "arrow.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(item.callNumber)
                                .font(.caption)
                        }
                    }
                    Spacer()
                    Text(item.status)
                        .font(.caption)
                        .foregroundColor(item.isStatusSuccess ? .green : .red)
                    
                }
                if isExpanded {
                    Text(item.barcode)
                        .font(.monospaced(.caption)())
                        .foregroundColor(.gray)
                        .padding(.leading)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
