//
//  Library_BookRow.swift
//  ConcordLibrary
//
//  Created by Bashir Rahmah on 4/7/2022.
//

import SwiftUI
import URLImage

struct Library_BookCoverPlaceholder: View {
    let book: Library_Book
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .leading, vertical: .center)) {
            Rectangle()
                .foregroundColor(.brown.opacity(0.3))
            Rectangle()
                .foregroundColor(.brown.opacity(0.9))
                .frame(width: 10)
            VStack {
                Text(book.title)
                    .font(.caption)
                    .foregroundColor(.brown)
                    .padding(.horizontal, 6)
                    .padding(.leading, 14)
                    .lineLimit(4)
                .lineSpacing(-5)
                Spacer()
                Rectangle()
                    .foregroundColor(.brown.opacity(0.8))
                    .frame(width: 30, height: 5)
                    .cornerRadius(16)
                    .padding(.leading, 5)
                Rectangle()
                    .foregroundColor(.brown.opacity(0.6))
                    .frame(width: 30, height: 5)
                    .cornerRadius(16)
                    .padding(.leading, 5)
            }
            .padding(.vertical)
        }
        .frame(width: 81, height: 117)
        .cornerRadius(16)
    }
}

struct Library_BookCoverPlaceholder_Previews: PreviewProvider {
    static var previews: some View {
        Library_BookCoverPlaceholder(book: Library_Book(title: "Harry Potter origami. Vol. 2", imageLink: "https://syndetics.com/hw7.pl?isbn=9781338745184/LC.jpg", meta: "by John Rocky", stock: "3 of 12", resultId: "1", isStatusSuccess: false))
    }
}


struct Library_BookRow: View {
    let book: Library_Book
    
    var body: some View {
        HStack(alignment: .top) {
            bookCover
            VStack(alignment: .leading) {
                Text(book.title)
                    .font(.headline)
                Text(book.meta)
                    .font(.callout)
                    .foregroundColor(.gray)
                Text(book.stock)
                    .font(.callout)
                    .foregroundColor(book.isStatusSuccess ? .green : .gray)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .background((book.isStatusSuccess ? Color.green : Color.gray).opacity(0.3).cornerRadius(10))
            }
        }
    }
    
    var bookCover: some View {
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
                .frame(width: 81, height: 117)
                .clipped()
                .cornerRadius(16)
        }
        .environment(\.urlImageService, Library_APIManager.urlImageService)
        .environment(\.urlImageOptions, URLImageOptions(
            fetchPolicy: .returnStoreElseLoad(),
            loadOptions: .loadImmediately,
            maxPixelSize: CGSize(width: 100, height: 240)
        ))
    }
}

struct Library_BookRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            Library_BookRow(book: Library_Book(title: "Harry Potter origami. Vol. 2", imageLink: "https://syndetics.com/hw7.pl?isbn=9781338745184/LC.jpg", meta: "by John Rocky", stock: "3 of 12", resultId: "1", isStatusSuccess: false))
            Library_BookRow(book: Library_Book(title: "Diary of a wimpy kid : cabin fever", imageLink: "https://syndetics.com/hw7.pl?isbn=9781410498786/LC.jpg", meta: "by John Rocky", stock: "3 of 13", resultId: "1", isStatusSuccess: false))
            Library_BookRow(book: Library_Book(title: "Diary of a wimpy kid : the last straw (PRC 5-6)", imageLink: "https://syndetics.com/hw7.pl?isbn=9780670074921/LC.jpg", meta: "by John Rocky", stock: "0 of 1", resultId: "1", isStatusSuccess: false))
        }
        .listStyle(.grouped)
    }
}
