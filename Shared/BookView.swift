//
//  BookView.swift
//  project1810
//
//  Created by Noah Trupin on 10/4/21.
//


import SwiftUI

struct Book {
    
    var title: String
    var image: String
    var references: [(name: String, link: String)]
    var entries: [(name: String, image: String, link: String)]
    
    init(_ data: [String: Any] = [:]) {
        self.title = data["title"] as? String ?? ""
        self.image = data["image"] as? String ?? ""
        self.references = data["references"] as? [(String, String)] ?? []
        self.entries = data["entries"] as? [(String, String, String)] ?? []
    }
    
    init(
        title: String,
        image: String,
        references: [(String, String)],
        entries: [(String, String, String)]
    ) {
        self.title = title
        self.image = image
        self.references = references
        self.entries = entries
    }

}

struct BookView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewManager: ViewManager
    var book: Book
    
    var body: some View {
        ScrollView {
            HeaderView(
                viewManager: self.viewManager,
                title: book.title,
                image: book.image
            )
            VStack(alignment: .leading) {
                if !book.references.isEmpty {
                    Text("References")
                        .font(.system(size: 32).bold())
                        .foregroundColor(colorScheme == .dark ? Color.ishtarWhite : Color.ishtarGrey)
                        .padding([.top, .bottom], 10)
                        .frame(alignment: .leading)
                    ForEach(book.references, id: \.name.hashValue) { ref in
                        Button {
                            viewManager.route(ref.link)
                        } label: {
                            Text("\(ref.name)")
                                .underline(color: colorScheme == .dark ? Color.ishtarWhite : Color.ishtarGrey)
                                .font(.system(size: 18))
                                .foregroundColor(colorScheme == .dark ? Color.ishtarWhite : Color.ishtarGrey)
                                .frame(width: UIScreen.width * 0.9, alignment: .leading)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.bottom, 1)
                    }
                }
                if !book.entries.isEmpty {
                    Text("Lore Entries")
                        .font(.system(size: 32).bold())
                        .foregroundColor(colorScheme == .dark ? Color.ishtarWhite : Color.ishtarGrey)
                        .padding([.top, .bottom], 10)
                        .frame(alignment: .leading)
                    ForEach(book.entries, id: \.0.hashValue) { ent in
                        Button {
                            viewManager.route(ent.link)
                        } label: {
                            ZStack {
                                AsyncImagePolyfill(ent.image, width: UIScreen.width * 0.9)
                                    .equatable()
                                    .overlay(
                                        Rectangle()
                                            .fill(Color.ishtarGreen.opacity(0.75))
                                    )
                                VStack(alignment: .leading) {
                                    Spacer()
                                    Rectangle()
                                        .fill(Color.ishtarWhite)
                                        .frame(height: 2)
                                    Text(ent.name)
                                        .font(.system(size: 20).bold())
                                        .foregroundColor(Color.ishtarWhite)
                                        .frame(alignment: .leading)
                                        .multilineTextAlignment(.leading)
                                }
                                .padding([.leading, .trailing, .bottom])
                            }
                        }
                        .padding(.bottom, 1)
                    }
                }
            }
            .padding([.leading, .trailing], UIScreen.width * 0.05)
            .padding(.bottom, 50)
        }
        .frame(maxHeight: UIScreen.height)
    }
    
}
