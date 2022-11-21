//
//  LibraryPreview.swift
//  ConcordLibrary
//
//  Created by Bashir Rahmah on 5/7/2022.
//

import SwiftUI
import URLImage

public struct LibraryPreview: View {
    @State var books = [Library_Book(title: "", imageLink: "", meta: "", stock: "", resultId: "", isStatusSuccess: false)]
    let headerColor: Color?
    
    public init(headerColor: Color) {
        self.headerColor = headerColor
    }
    public init() {
        self.headerColor = nil
    }
    
    public var body: some View {
        VStack {
            HStack {
                if headerColor == nil {
                    Text("Ilim Library")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .padding(.horizontal)
                } else {
                    Text("Ilim Library")
                    .font(.custom("Feijoa-Display", size: 16))
                    .foregroundColor(headerColor)
                    .padding(.bottom, -2)
                    .padding(.horizontal)
                }
                NavigationLink {
                    BooksView(searchText: Library_APIManager.getRandomSearchQuery())
                } label: {
                    Spacer()
                    Text("View All")
                        .font(.caption)
                    Image(systemName: "chevron.right")
                        .padding(.trailing)
                        .font(.caption)
                }
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    NavigationLink {
                       LoansView()
                            .navigationBarTitleDisplayMode(.large)
                    } label: {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.green.opacity(0.8))
                                .cornerRadius(10)
                            VStack {
                                Image(systemName: "books.vertical")
                                    .font(.title)
                                    .padding(.bottom)
                                Text("My Loans")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                            .padding(.horizontal, 6)
                            .foregroundColor(.white)
                        }
                        .frame(width: 85, height: 127)
                    }
                    ForEach(books) { book in
                        if UIDevice.current.userInterfaceIdiom == .pad {
                            BookItemViewIPad(book: book)
                        } else {
                            NavigationLink {
                                BookDetail(book: book)
                                    .navigationBarTitleDisplayMode(.inline)
                            } label: {
                                Library_BookPreviewItem(book: book)
                            }
                        }
                    }
                    NavigationLink {
                        BooksView(searchText: "")
                    } label: {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.brown.opacity(0.8))
                                .cornerRadius(10)
                            VStack {
                                Image(systemName: "chevron.right")
                                    .padding(.bottom)
                                Text("View More")
                                    .font(.caption)
                            }
                            .padding(.horizontal, 6)
                            .foregroundColor(.white)
                        }
                        .frame(width: 85, height: 127)
                    }
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            if books.count == 1 {
                Library_APIManager.getBooks(query: Library_APIManager.getRandomSearchQuery(), begin: "0") { result in
                    if case .success(let res) = result {
                        books = Array(res.filter({$0.imageLink != nil}).prefix(
                            (UserDefaults(suiteName: "group.ilimcollege.apps")?.bool(forKey: "isLoggedIn") ?? true) ? 7 : 30
                        ))
                    }
                }
            }
        }
    }
}

struct LibraryPreview_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LibraryPreview()
        }
    }
}

fileprivate struct BookItemViewIPad: View {
    let book: Library_Book
    @State var showingPopover: Bool = false
    
    var body: some View {
            Library_BookPreviewItem(book: book)
                .onTapGesture {
                    showingPopover.toggle()
                }
                .popover(isPresented: $showingPopover) {
                    BookDetail(book: book)
                        .navigationBarTitleDisplayMode(.inline)
                        .frame(width: 400, height: 600)
                }

    }
}

struct Library_BookPreviewItem: View {
    let book: Library_Book
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .trailing, vertical: .bottom)) {
            URLImage(book.image) {
                Library_BookCoverPlaceholder(book: book)
            } inProgress: { progress in
                Library_BookCoverPlaceholder(book: book)
            } failure: { error, retry in
                Library_BookCoverPlaceholder(book: book)
            } content: { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 85, height: 127)
                    .clipped()
                    .cornerRadius(10)
            }
            .environment(\.urlImageService, Library_APIManager.urlImageService)
            bookStock
        }
    }
    
    var bookStock: some View {
        Text(book.stock)
            .font(.caption)
            .foregroundColor(.white)
            .padding(.vertical, 5)
            .padding(.horizontal, 5)
            .background((book.isStatusSuccess ? Color.green : Color.red).opacity(0.8).cornerRadius(10))
            .padding([.bottom, .trailing], 4)
    }
}
