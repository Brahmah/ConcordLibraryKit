//
//  SwiftUIView.swift
//  
//
//  Created by Bashir Rahmah on 5/11/2022.
//

import SwiftUI
import TelemetryClient
import Colorful
import URLImage

public struct LoansView: View {
    @State var loans = Library_Book_Loans(history: [], current: [])
    @State var libraryUserId: String? = nil
    @State var isLoading = true
    @State var isShowingSSOPrompt = false
    @State var didSSOSucceed = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    public init() {
    }
    
    func reload() {
        Library_APIManager.getBookLoans() { result, needsLogin in
            if case .success(let res) = result {
                DispatchQueue.main.async {
                    loans = res
                }
            } else {
                if needsLogin {
                    DispatchQueue.main.async {
                        isShowingSSOPrompt = true
                    }
                }
            }
            isLoading = false
        }
        Library_APIManager.getMyLibraryBadgeId { badgeId in
            libraryUserId = badgeId
        }
    }
    
    public var body: some View {
        booksList
            .navigationTitle("Loans")
            .listStyle(.grouped)
            .onAppear {
                reload()
                //            TelemetryManager.send("viewBookSearch", with: getTelemetry())
            }
            .sheet(isPresented: $isShowingSSOPrompt) {
                NavigationView {
                    LibraryAuthView(didSucceed: $didSSOSucceed)
                        .navigationBarTitleDisplayMode(.inline)
                        .edgesIgnoringSafeArea(.bottom)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button {
                                    isShowingSSOPrompt = false
                                } label: {
                                    Text("Cancel")
                                }
                            }
                        }
                }
                .edgesIgnoringSafeArea(.bottom)
                .navigationViewStyle(.stack)
            }
            .onChange(of: didSSOSucceed) { newValue in
                if newValue == true {
                    isLoading = true
                    isShowingSSOPrompt = false
                    reload()
                }
            }
    }
    
    @Environment(\.colorScheme) var colorScheme
    
    var barcodeUrlString: String {
        let urlEncodedUserId = (libraryUserId ?? "").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        if colorScheme == .dark {
            return "https://barcode.tec-it.com/barcode.ashx?data=\(urlEncodedUserId ?? "Unknown")&code=Code39FullASCII&color=ffffff&bgcolor=1C1C1E&hidehrt=False"
        } else {
            return "https://barcode.tec-it.com/barcode.ashx?data=\(urlEncodedUserId ?? "Unknown")&code=Code39FullASCII&hidehrt=False"
        }
    }
    
    var booksList: some View {
        List {
            if let imageUrl = URL(string: barcodeUrlString), libraryUserId != nil {
                Section(header: Text("Library Pass").bold().font(.title3)) {
                    URLImage(imageUrl) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                    .padding(.horizontal)
                }
            }
            Section(header: Text("Current").bold().font(.title3)) {
                if loans.current.isEmpty {
                    Text("no current loans")
                } else {
                    ForEach(loans.current) { loanItem in
                        Library_BookRow_Loan(loanItem: loanItem)
                    }
                }
            }
            Section(header: Text("History").bold().font(.title3)) {
                if loans.history.isEmpty {
                    Text("no loan history, read more!")
                } else {
                    ForEach(loans.history) { loanItem in
                        Library_BookRow_Loan(loanItem: loanItem)
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

struct LoansView_Previews: PreviewProvider {
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

struct Library_BookRow_Loan: View {
    let loanItem: Library_BookLoanItem
    
    var body: some View {
        HStack(alignment: .top) {
            bookCover
            VStack(alignment: .leading) {
                Text("Loaned: ").bold().foregroundColor(.blue) + Text(loanItem.loanDate).foregroundColor(.blue)
                Text("Due: ").bold().foregroundColor(.orange) + Text(loanItem.dueDate).foregroundColor(.orange)
                if !loanItem.returnedDate.isEmpty {
                    Text("Returned: ").bold().foregroundColor(.green) + Text(loanItem.returnedDate).foregroundColor(.green)
                }
                Text(loanItem.barcode)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .font(.callout)
        }
    }
    
    var bookCover: some View {
        Library_BookCoverPlaceholder(book: Library_Book(title: loanItem.title, meta: loanItem.barcode, stock: "", resultId: "", isStatusSuccess: false))
    }
}
