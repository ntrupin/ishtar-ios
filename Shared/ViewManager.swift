//
//  ViewManager.swift
//  ishtar
//
//  Created by Noah Trupin on 10/10/21.
//

import SwiftUI

class ViewManager: ObservableObject {
    
    @Published var viewStack: [AnyView] = []
    @Published var routingError: String? = .none
        
    init() {}
    
    func push(animated: Bool = false, _ view: AnyView) {
        DispatchQueue.main.async {
            if animated {
                withAnimation {
                    self.viewStack.append(view)
                }
            } else {
                self.viewStack.append(view)
            }
        }
    }
    
    func pop(animated: Bool = false) {
        DispatchQueue.main.async {
            if animated {
                withAnimation {
                    _ = self.viewStack.popLast()
                }
            } else {
                _ = self.viewStack.popLast()
            }
        }
    }
    
    func popAll(animated: Bool = false) {
        DispatchQueue.main.async {
            if animated {
                withAnimation {
                    self.viewStack = []
                }
            } else {
                self.viewStack = []
            }
        }
    }
    
    func route(_ link: String) {
        if link.contains("/categories/") {
            if link.contains("/book-") {
                Scraper.scrapeBook(link) { data in
                    self.push(animated: true, AnyView(BookView(viewManager: self, book: data)))
                }
            } else {
                Scraper.scrapeCategory(link) { data in
                    self.push(animated: true, AnyView(CategoryView(viewManager: self, category: data)))
                }
            }
        } else if link.contains("/entries/") {
            Scraper.scrapeEntry(link) { data in
                self.push(animated: true, AnyView(EntryView(viewManager: self, entry: data)))
            }
        } else {
            print("Invalid link (\(link))")
            let path = link.replacingOccurrences(of: "https://www.ishtar-collective.net", with: "")
            withAnimation {
                self.routingError = "Error reading route \"\(path)\""
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                withAnimation {
                    self.routingError = .none
                }
            }
        }
    }
}
