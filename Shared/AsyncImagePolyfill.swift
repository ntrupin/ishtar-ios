//
//  AsyncImagePolyfill.swift
//  project1810
//
//  Created by Noah Trupin on 10/3/21.
//

import SwiftUI

class ImageLoader: ObservableObject {
    
    @Published var data: Data = Data()

    init(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.data = data
            }
        }
        task.resume()
    }
}

struct AsyncImagePolyfill: View, Equatable {
    
    @ObservedObject var loader: ImageLoader
    @State var image: UIImage = UIImage()
    var url: String
    var width: CGFloat?
    var height: CGFloat?
    
    init(_ url: String, width: CGFloat? = .none, height: CGFloat? = .none) {
        loader = ImageLoader(urlString: url)
        self.url = url
        self.width = width
        self.height = height
    }
    
    var body: some View {
        return Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: width, height: height)
            .onReceive(loader.$data) { data in
                self.image = UIImage(data: data) ?? UIImage()
            }
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.url == rhs.url && lhs.width == rhs.width && rhs.height == rhs.height
    }
}
