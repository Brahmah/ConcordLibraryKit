//
//  HomepageComponent.swift
//  Ilim College
//
//  Created by Bashir Rahmah on 18/7/2022.
//  Copyright © 2022 Bashir Rahmah. All rights reserved.
//

import SwiftUI

public struct LibraryHomepageComponent: View {
    public init() {
        
    }
    
    public var body: some View {
       comp
    }
    
    public var comp: some View {
        NavigationLink {
            BooksView(searchText: Library_APIManager.getRandomSearchQuery())
                .navigationBarTitleDisplayMode(.inline)
        } label: {
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    Text("📚")
                        .font(.system(size: 80))
                    Spacer()
                }
                HStack {
                    Spacer()
                    Text("Tap to search library catalog")
                        .font(.callout)
                        .foregroundColor(Color("SoftTextColor"))
                    Spacer()
                }
            }
            .contentShape(Rectangle())
        }
        .padding([.leading, .trailing, .bottom])
    }
}

struct HomepageComponent_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            LibraryHomepageComponent()
        }
        .background(Color("InboxBackground"))
    }
}
