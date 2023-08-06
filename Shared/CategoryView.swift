//
//  CategoryView.swift
//  project1810
//
//  Created by Noah Trupin on 10/3/21.
//

import SwiftUI

struct Category {
    
    var title: String
    var image: String
    var flavor: String
    var description: String
    var references: [(name: String, link: String)]
    var entries: [(name: String, link: String)]
    
    init(_ data: [String: Any] = [:]) {
        self.title = data["title"] as? String ?? ""
        self.image = data["image"] as? String ?? ""
        self.flavor = data["flavor"] as? String ?? ""
        self.description = data["description"] as? String ?? ""
        self.references = data["references"] as? [(String, String)] ?? []
        self.entries = data["entries"] as? [(String, String)] ?? []
    }
    
    init(
        title: String,
        image: String,
        flavor: String,
        description: String,
        references: [(String, String)],
        entries: [(String, String)]
    ) {
        self.title = title
        self.image = image
        self.flavor = flavor
        self.description = description
        self.references = references
        self.entries = entries
    }

}

struct CategoryView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewManager: ViewManager
    var category: Category
    
    var body: some View {
        ScrollView {
            HeaderView(
                viewManager: self.viewManager,
                title: category.title,
                image: category.image
            )
            VStack(alignment: .leading) {
                if category.flavor != "" {
                    Text(category.flavor)
                        .font(.system(size: 20).italic())
                        .foregroundColor(colorScheme == .dark ? Color.ishtarWhite : Color.ishtarGrey)
                        .padding([.top, .bottom], 10)
                }
                if category.description != "" {
                    Text("Description")
                        .font(.system(size: 32).bold())
                        .foregroundColor(colorScheme == .dark ? Color.ishtarWhite : Color.ishtarGrey)
                        .padding([.top, .bottom], 10)
                        .frame(alignment: .leading)
                    Text(category.description)
                        .font(.system(size: 18))
                        .foregroundColor(colorScheme == .dark ? Color.ishtarWhite : Color.ishtarGrey)
                        .frame(width: UIScreen.width * 0.9)
                        .frame(alignment: .leading)
                        .multilineTextAlignment(.leading)
                }
                if !category.references.isEmpty {
                    Text("References")
                        .font(.system(size: 32).bold())
                        .foregroundColor(colorScheme == .dark ? Color.ishtarWhite : Color.ishtarGrey)
                        .padding([.top, .bottom], 10)
                        .frame(alignment: .leading)
                    ForEach(category.references, id: \.name.hashValue) { ref in
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
                if !category.entries.isEmpty {
                    Text("Lore Entries")
                        .font(.system(size: 32).bold())
                        .foregroundColor(colorScheme == .dark ? Color.ishtarWhite : Color.ishtarGrey)
                        .padding([.top, .bottom], 10)
                        .frame(alignment: .leading)
                    ForEach(category.entries, id: \.0.hashValue) { ent in
                        Button {
                            viewManager.route(ent.link)
                        } label: {
                            Text("\(ent.0)")
                                .underline(color: colorScheme == .dark ? Color.ishtarWhite : Color.ishtarGrey)
                                .font(.system(size: 18))
                                .foregroundColor(colorScheme == .dark ? Color.ishtarWhite : Color.ishtarGrey)
                                .frame(width: UIScreen.width * 0.9, alignment: .leading)
                                .multilineTextAlignment(.leading)
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
