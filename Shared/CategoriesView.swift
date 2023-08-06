//
//  CategoriesView.swift
//  ishtar
//
//  Created by Noah Trupin on 10/10/21.
//

import SwiftUI

struct Categories {

    struct CategorySection {
        var letter: String
        var categories: [(name: String, link: String)]
        
        init(_ data: [String: Any] = [:]) {
            self.letter = data["letter"] as? String ?? ""
            self.categories = data["categories"] as? [(String, String)] ?? []
        }
        
        init(
            letter: String,
            categories: [(String, String)]
        ) {
            self.letter = letter
            self.categories = categories
        }
    }
    
    var sections: [CategorySection]
    
    init(_ data: [String: Any] = [:]) {
        self.sections = data["sections"] as? [CategorySection] ?? []
    }
    
    init(sections: [CategorySection]) {
        self.sections = sections
    }
    
}

struct CategoriesView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewManager: ViewManager
    @State var categories: Categories = Categories()
    
    var body: some View {
        ScrollView {
            HeaderView(
                viewManager: self.viewManager,
                title: "Category Archive",
                image: ""
            )
            VStack(alignment: .leading) {
                if !categories.sections.isEmpty {
                    ForEach(self.categories.sections, id: \.letter.hashValue) { c in
                        Text("\(c.letter)")
                            .font(.system(size: 24).bold())
                            .foregroundColor(colorScheme == .dark ? Color.ishtarWhite : Color.ishtarGrey)
                            .frame(width: UIScreen.width * 0.9, alignment: .leading)
                            .multilineTextAlignment(.leading)
                            .padding(.bottom, 2)
                        ForEach(c.categories, id: \.0.hashValue) { entry in
                            Button {
                                viewManager.route(entry.link)
                            } label: {
                                Text("\(entry.name)")
                                    .underline(color: colorScheme == .dark ? Color.ishtarWhite : Color.ishtarGrey)
                                    .font(.system(size: 18))
                                    .foregroundColor(colorScheme == .dark ? Color.ishtarWhite : Color.ishtarGrey)
                                    .frame(width: UIScreen.width * 0.9, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(.bottom, 1)
                        }
                    }
                    .padding(.bottom, 5)
                }
            }
            .padding([.leading, .trailing], UIScreen.width * 0.05)
            .padding(.bottom, 50)
        }
        .frame(maxHeight: UIScreen.height)
        .onAppear {
            if self.categories.sections.isEmpty {
                Scraper.scrapeCategories { categories in
                    self.categories = categories
                }
            }
        }
    }
    
}
