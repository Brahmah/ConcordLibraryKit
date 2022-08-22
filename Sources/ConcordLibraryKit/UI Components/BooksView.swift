//
//  BooksView.swift
//  ConcordLibrary
//
//  Created by Bashir Rahmah on 4/7/2022.
//

import SwiftUI
import Colorful
import TelemetryClient

public struct BooksView: View {
    @State var begin: Int = 24
    @State var books = [Library_Book]()
    @State public var searchText = "Diary Of A Wimpy Kid"
    @State var lastSearchText = "Diary Of A Wimpy Kid"
    @State var isLoading = true
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    public init(searchText: String) {
        self.searchText = searchText
    }
    
    public init() {
    }
    
    public var body: some View {
        Group {
            if searchText.isEmpty {
                getErrorView(message1: "Search for a book to get started!", message2: "Adventure awaits", icon:  "a.book.closed.hi")
            } else if books.isEmpty && !isLoading {
                getErrorView(message1: "Nothing found...", message2: "Try searching something else :(", icon:  "bookmark.slash.fill")
            } else {
                booksList
            }
        }
        .navigationTitle("Books")
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .listStyle(.grouped)
        .onAppear {
            begin = 24
            Library_APIManager.getBooks(query: searchText, begin: "0") { result in
                if case .success(let res) = result {
                    books = res
                }
                isLoading = false
            }
//            TelemetryManager.send("viewBookSearch", with: getTelemetry())
        }
        .onReceive(timer) { time in
            if lastSearchText != searchText {
                isLoading = true
                lastSearchText = searchText
                let b4LoadSearchText = searchText
                Library_APIManager.getBooks(query: searchText, begin: "0") { result in
                    isLoading = false
                    if case .success(let res) = result {
                        if b4LoadSearchText == searchText {
                            books = res
                        }
                    }
                }
            }
        }
    }
    
    var booksList: some View {
        List(books) { book in
            NavigationLink {
                BookDetail(book: book)
                    .navigationBarTitleDisplayMode(.inline)
            } label: {
                Library_BookRow(book: book)
            }
            .onAppear {
                if book.id == books.last?.id {
                    Library_APIManager.getBooks(query: searchText, begin: String(begin)) { result in
                        if case .success(let res) = result {
                            books.append(contentsOf: res)
                            begin += 24
                        }
                    }
                }
            }
            if isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(.circular)
                    Spacer()
                }
            }
        }
    }
}

struct BooksView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BooksView()
        }
    }
}

fileprivate func getErrorView(message1: String, message2: String, icon: String) -> some View {
    ZStack {
        ColorfulView()
        LazyVStack {
            Text(" ")
            Text(" ")
            Text(" ")
            Image(systemName: icon)
                .font(.system(size: 50))
                .padding(.bottom)
            Text(message1)
                .fontWeight(.bold)
            Text(message2)
        }
    }
}
