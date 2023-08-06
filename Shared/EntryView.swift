//
//  EntryView.swift
//  project1810
//
//  Created by Noah Trupin on 10/5/21.
//

import SwiftUI

struct Entry {
    
    var title: String
    var subtitle: String
    var image: String
    var description: String
    var categories: [(name: String, link: String)]
    var added: (name: String, link: String)
    var associated: [(name: String, link: String)]
    
    init(_ data: [String: Any] = [:]) {
        self.title = data["title"] as? String ?? ""
        self.subtitle = data["subtitle"] as? String ?? ""
        self.image = data["image"] as? String ?? ""
        self.description = data["description"] as? String ?? ""
        self.categories = data["categories"] as? [(String, String)] ?? []
        self.added = data["added"] as? (String, String) ?? ("", "")
        self.associated = data["associated"] as? [(String, String)] ?? []
    }
    
    init(
        title: String,
        subtitle: String,
        image: String,
        description: String,
        categories: [(String, String)],
        added: (name: String, link: String),
        associated: [(String, String)]
    ) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.description = description
        self.categories = categories
        self.added = added
        self.associated = associated
    }

}

struct EntryView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewManager: ViewManager
    var entry: Entry
    var body: some View {
        ScrollView {
            HeaderView(
                viewManager: self.viewManager,
                title: entry.title,
                image: entry.image
            )
            VStack(alignment: .leading) {
                if entry.subtitle != "" {
                    Text(entry.subtitle)
                        .font(.system(size: 20).italic())
                        .foregroundColor(colorScheme == .dark ? Color.ishtarWhite : Color.ishtarGrey)
                        .padding([.top, .bottom], 10)
                }
                if entry.description != "" {
                    Text("Description")
                        .font(.system(size: 32).bold())
                        .foregroundColor(colorScheme == .dark ? Color.ishtarWhite : Color.ishtarGrey)
                        .padding([.top, .bottom], 10)
                        .frame(alignment: .leading)
                    Text(entry.description)
                        .font(.system(size: 18))
                        .foregroundColor(colorScheme == .dark ? Color.ishtarWhite : Color.ishtarGrey)
                        .frame(width: UIScreen.width * 0.9)
                        .frame(alignment: .leading)
                }
                Button {
                    viewManager.route(entry.added.link)
                } label: {
                    Text("Added in \(entry.added.name)")
                        .underline(color: colorScheme == .dark ? Color.ishtarWhite : Color.ishtarGrey)
                        .font(.system(size: 18))
                        .foregroundColor(colorScheme == .dark ? Color.ishtarWhite : Color.ishtarGrey)
                        .padding([.top, .bottom], 10)
                        .frame(width: UIScreen.width * 0.9, alignment: .leading)
                }
                .padding(.bottom, 1)
                if !entry.categories.isEmpty {
                    Text("Categories")
                        .font(.system(size: 32).bold())
                        .foregroundColor(colorScheme == .dark ? Color.ishtarWhite : Color.ishtarGrey)
                        .padding([.top, .bottom], 10)
                        .frame(alignment: .leading)
                    ForEach(entry.categories, id: \.name.hashValue) { cat in
                        Button {
                            viewManager.route(cat.link)
                        } label: {
                            Text("\(cat.name)")
                                .underline(color: colorScheme == .dark ? Color.ishtarWhite : Color.ishtarGrey)
                                .font(.system(size: 18))
                                .foregroundColor(colorScheme == .dark ? Color.ishtarWhite : Color.ishtarGrey)
                                .multilineTextAlignment(.leading)
                                .frame(width: UIScreen.width * 0.9, alignment: .leading)
                        }
                        .padding(.bottom, 1)
                    }
                }
                if !entry.associated.isEmpty {
                    Text("Associated Items")
                        .font(.system(size: 32).bold())
                        .foregroundColor(colorScheme == .dark ? Color.ishtarWhite : Color.ishtarGrey)
                        .padding([.top, .bottom], 10)
                        .frame(alignment: .leading)
                    ForEach(entry.associated, id: \.0.hashValue) { assoc in
                        Button {
                            viewManager.route(assoc.link)
                        } label: {
                            Text("\(assoc.name)")
                                .underline(color: colorScheme == .dark ? Color.ishtarWhite : Color.ishtarGrey)
                                .font(.system(size: 18))
                                .foregroundColor(colorScheme == .dark ? Color.ishtarWhite : Color.ishtarGrey)
                                .frame(width: UIScreen.width * 0.9, alignment: .leading)
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
