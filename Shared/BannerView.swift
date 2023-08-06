//
//  BannerView.swift
//  project1810
//
//  Created by Noah Trupin on 10/5/21.
//

import SwiftUI

struct BannerView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewManager: ViewManager
    @State var banners: [[String: String]] = [[:]]
    @State var bannerIndex: Int = 0
    @State var search: String = ""
    @State var searching: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    AsyncImagePolyfill(self.banners[self.bannerIndex]["image"] ?? "", width: UIScreen.width, height: UIScreen.width)
                        .equatable()
                        .scaleEffect(max(1, 1 + (geometry.frame(in: .global).minY * 0.005)))
                    Spacer()
                }
                VStack(alignment: .leading) {
                    HStack {
                        Image("ishtar")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(Color.ishtarWhite)
                            .frame(width: 50, height: 50)
                        Spacer()
                        VStack {
                            HStack {
                                TextField("", text: $search, onEditingChanged: { (editingChanged) in
                                    withAnimation {
                                        self.searching = editingChanged
                                    }
                                })
                                    .placeholder(when: !self.searching && self.search.isEmpty) {
                                        Text("Search")
                                    }
                                    .foregroundColor(Color.ishtarWhite)
                                    .font(.system(size: 20, weight: .bold))
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(Color.ishtarWhite)
                                    .font(.system(size: 20).bold())
                                    .padding(.leading, 10)
                            }
                            if searching {
                                Rectangle()
                                    .fill(Color.ishtarWhite)
                                    .frame(height: 2)
                            }
                        }
                        .padding(.leading, 25)
                    }
                    .padding(.top, 100/1.5)
                    .padding([.leading, .trailing], UIScreen.width * 0.1)
                    Group {
                        Text(self.banners[self.bannerIndex]["title"] ?? "")
                            .font(.system(size: 48).bold())
                            .foregroundColor(Color.ishtarWhite)
                            .padding(.top, 100/3)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(2)
                        /*Text(banner["flavor"] ?? "")
                            .font(.system(size: 20).italic())
                            .foregroundColor(Color.ishtarWhite)*/
                        Spacer()
                        Button {
                            viewManager.route(self.banners[self.bannerIndex]["link"] ?? "")
                        } label: {
                            Text("Read More \u{2192}")
                                .font(.system(size: 20).bold())
                                .foregroundColor(Color.ishtarWhite)
                                .padding(15)
                        }
                        .border(Color.ishtarWhite, width: 3)
                        .padding(.bottom, 20)
                    }
                    .padding([.leading, .trailing], UIScreen.width * 0.1)
                    Spacer()
                }
                HStack {
                    if self.bannerIndex > 0 {
                        Button {
                            withAnimation {
                                self.bannerIndex -= 1
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .foregroundColor(Color.ishtarWhite)
                                .font(.system(size: 20).bold())
                                .padding(.leading, 10)
                        }
                    }
                    Spacer()
                    if self.bannerIndex < self.banners.count - 1 {
                        Button {
                            withAnimation {
                                self.bannerIndex += 1
                            }
                        } label: {
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color.ishtarWhite)
                                .font(.system(size: 20).bold())
                                .padding(.trailing, 10)
                        }
                    }
                }
            }
            .onAppear {
                if self.banners == [[:]] {
                    Scraper.scrapeBanner { banners in
                        self.banners = banners
                    }
                }
            }
            .frame(maxHeight: UIScreen.width)
            .offset(y: geometry.frame(in: .global).minY > 0 ? -geometry.frame(in: .global).minY : 0)
        }
        .frame(height: UIScreen.width)
    }
}
