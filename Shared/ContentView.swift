//
//  ContentView.swift
//  Shared
//
//  Created by Noah Trupin on 9/27/21.
//

import SwiftUI
import CoreLocation
import SwiftSoup

struct HomeEntry {
    
    var title: String
    var image: String
    var mask: Color?
    var link: String
    
    init(_ data: [String: Any] = [:]) {
        self.title = data["title"] as? String ?? ""
        self.image = data["image"] as? String ?? ""
        self.mask = data["mask"] as? Color
        self.link = data["entries"] as? String ?? ""
    }
    
    init(
        title: String,
        image: String,
        mask: Color?,
        link: String
    ) {
        self.title = title
        self.image = image
        self.mask = mask
        self.link = link
    }
}

struct ContentView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @State var updates: ([HomeEntry], [HomeEntry]) = ([], [])
    @State var selected: Int = 0
    @ObservedObject var viewManager: ViewManager = ViewManager()
    @State var categories: Categories = Categories()
    
    var body: some View {
        GeometryReader { _ in
            ZStack {
                Rectangle()
                    .fill(colorScheme == .dark ? Color.ishtarGrey : Color.ishtarWhite)
                    .frame(width: UIScreen.width, height: UIScreen.height)
                VStack {
                    if viewManager.viewStack.isEmpty {
                        switch self.selected {
                        case 0:
                            home
                                .transition(.opacity)
                        case 1:
                            CategoriesView(viewManager: self.viewManager, categories: self.categories)
                        case 2:
                            VStack {
                                Spacer()
                                Text("History coming soon")
                                Spacer()
                            }
                        default:
                            home
                                .transition(.opacity)
                        }
                    } else {
                        viewManager.viewStack.last!
                            .transition(.opacity)
                    }
                    Spacer()
                    // No fucking clue why this works
                    if #available(iOS 15.0, *) {
                        tabBar
                    } else {
                        tabBar
                            .padding(.bottom, 50)
                    }
                }
                if self.viewManager.routingError != .none {
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(colorScheme == .dark ? Color.ishtarGrey : Color.ishtarWhite)
                                .frame(width: UIScreen.width * 0.9, height: 100)
                                .transition(.opacity)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.red)
                                        .transition(.opacity)
                                )
                            Text(self.viewManager.routingError!)
                                .foregroundColor(colorScheme == .dark ? Color.ishtarWhite : Color.ishtarGrey)
                                .font(.system(size: 18))
                                .transition(.opacity)
                                .padding(10)
                        }
                        .frame(width: UIScreen.width * 0.9, height: 100)
                        .padding(.top, 45)
                        Spacer()
                    }
                }
            }
            .edgesIgnoringSafeArea([.top, .leading, .trailing])
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .frame(maxHeight: UIScreen.height)
        .onAppear {
            if self.updates.0.isEmpty {
                Scraper.scrapeHome { updates in
                    self.updates = updates
                }
            }
            if self.categories.sections.isEmpty {
                Scraper.scrapeCategories { categories in
                    self.categories = categories
                }
            }
        }
    }
    
    var home: some View {
        ScrollView {
            BannerView(viewManager: self.viewManager)
            page
                .padding(.bottom, 50)
        }
        .frame(maxHeight: UIScreen.height)
    }
    
    var tabBar: some View {
        let icons = ["square.grid.2x2", "clock"]
        return HStack {
            Spacer()
            ForEach(0..<3) { i in
                Button {
                    withAnimation {
                        self.viewManager.popAll()
                        self.selected = i
                    }
                } label: {
                    if i == 0 {
                        Image("ishtar")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(colorScheme == .dark ? Color.ishtarWhite : Color.ishtarGrey)
                            .frame(width: 28, height: 28)
                            .overlay(
                                Circle()
                                    .stroke(i == selected ? colorScheme == .dark ? Color.ishtarWhite : Color.ishtarGrey : Color.clear)
                                    .frame(width: 50, height: 50)
                            )
                            .padding(10)
                    } else {
                        Image(systemName: icons[i-1])
                            .foregroundColor(colorScheme == .dark ? Color.ishtarWhite : Color.ishtarGrey)
                            .font(.system(size: 28))
                            .frame(width: 28, height: 28)
                            .overlay(
                                Circle()
                                    .stroke(i == selected ? colorScheme == .dark ? Color.ishtarWhite : Color.ishtarGrey : Color.clear)
                                    .frame(width: 50, height: 50)
                            )
                            .padding(10)
                    }
                }
                Spacer()
            }
        }
        .padding(.top, 5)
        .padding(.bottom, 35)
        .background(colorScheme == .dark ? Color.ishtarGrey : Color.ishtarWhite)
    }
    
    var page: some View {
        let entries = [self.updates.0, self.updates.1]
        return VStack(alignment: .leading) {
            ForEach(0..<2) { i in
                if !entries[i].isEmpty {
                    Text(["Updates", "Popular"][i])
                        .font(.system(size: 32).bold())
                        .foregroundColor(colorScheme == .dark ? Color.ishtarWhite : Color.ishtarGrey)
                        .padding([.top, .bottom], 10)
                        .padding([.leading, .trailing], UIScreen.width * 0.05)
                }
                pageSection(data: entries[i])
            }
        }
    }
    
    func pageSection(data: [HomeEntry]) -> some View {
        ForEach(data, id: \.title.hashValue) { item in
            Button {
                viewManager.route(item.link)
            } label: {
                ZStack {
                    AsyncImagePolyfill(item.image, width: UIScreen.width * 0.9)
                        .equatable()
                        .overlay(
                            Rectangle()
                                .fill((item.mask ?? Color.clear).opacity(0.75))
                        )
                    VStack(alignment: .trailing) {
                        Spacer()
                        Rectangle()
                            .fill(Color.ishtarWhite)
                            .frame(height: 2)
                        Text(item.title)
                            .font(.system(size: 28).bold())
                            .foregroundColor(Color.ishtarWhite)
                            .multilineTextAlignment(.trailing)
                            .fixedSize(horizontal: false, vertical: false)
                    }
                    .padding([.leading, .trailing, .bottom])
                }
            }
        }
        .frame(width: UIScreen.width * 0.9)
        .padding([.leading, .trailing], UIScreen.width * 0.05)
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
