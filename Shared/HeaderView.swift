//
//  HeaderView.swift
//  ishtar
//
//  Created by Noah Trupin on 10/10/21.
//

import SwiftUI

struct HeaderView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewManager: ViewManager
    var title: String
    var image: String
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    AsyncImagePolyfill(self.image, width: UIScreen.width, height: UIScreen.width)
                        .equatable()
                        .scaleEffect(max(1, 1 + (geometry.frame(in: .global).minY * 0.005)))
                    Spacer()
                }
                VStack(alignment: .leading) {
                    HStack {
                        if self.viewManager.viewStack.isEmpty {
                            Image("ishtar")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(colorScheme == .dark || self.image != "" ? Color.ishtarWhite : Color.ishtarGrey)
                                .frame(width: 50, height: 50)
                        } else {
                            Button {
                                viewManager.pop(animated: true)
                            } label: {
                                Image(systemName: "arrow.backward")
                                    .foregroundColor(colorScheme == .dark || self.image != "" ? Color.ishtarWhite : Color.ishtarGrey)
                                    .font(.system(size: 20).bold())
                            }
                        }
                        Spacer()
                    }
                    .padding(.top, 100/1.5)
                    .padding([.leading, .trailing], UIScreen.width * 0.1)
                    Group {
                        Spacer()
                        Text(self.title)
                            .font(.system(size: 48).bold())
                            .foregroundColor(colorScheme == .dark || self.image != "" ? Color.ishtarWhite : Color.ishtarGrey)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                    }
                    .padding([.leading, .trailing], UIScreen.width * 0.1)
                    Spacer()
                }
            }
            .frame(maxHeight: UIScreen.width)
            .offset(y: geometry.frame(in: .global).minY > 0 ? -geometry.frame(in: .global).minY : 0)
        }
        .frame(height: UIScreen.width)
    }
}
