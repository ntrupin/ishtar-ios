//
//  Scraper.swift
//  project1810
//
//  Created by Noah Trupin on 10/4/21.
//

import SwiftUI
import SwiftSoup

class Scraper: NSObject {
    
    enum ScraperError: Error {
        case NoBanner
    }
    
    static func readHTML(from addr: String, _ completion: @escaping (String) -> Void) {
        let url: URL = URL(string: addr)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                  let resp = response as? HTTPURLResponse,
                  error == nil
            else {
                print(error?.localizedDescription ?? "Error")
                return
            }
            guard (200...299) ~= resp.statusCode else {
                print("Invalid status code \(resp.statusCode)")
                return
            }
            guard let html = String(data: data, encoding: .utf8) else {
                print("Could not decode response")
                return
            }
            completion(html)
        }
        task.resume()
    }
    
    static func scrapeBanner(_ completion: @escaping ([[String: String]]) -> Void) {
        Self.readHTML(from: "https://www.ishtar-collective.net/") { string in
            do {
                let doc: Document = try SwiftSoup.parse(string)
                let banners: Elements = try doc.select("div.banner")
                completion(try banners.map { banner -> [String: String] in
                    let style = try banner.attr("style")
                    let title = banner.children().first()!.children().first()!
                    return [
                        "title": try title.text(),
                        "link": "https://www.ishtar-collective.net\(try title.attr("href"))",
                        "image": String(style[style.range(
                            of: #"https://.+?(?=\')"#,
                            options: .regularExpression
                        )!]),
                        "flavor": try banner.children()[1].children().first()!.text()
                    ]
                })
             } catch Exception.Error(let type, let message) {
                 print("\(type): \(message)")
                 completion([[:]])
             } catch {
                 print("error (banner)")
                 completion([[:]])
             }
        }
    }
    
    static func scrapeCategory(_ url: String, _ completion: @escaping (Category) -> Void) {
        Self.readHTML(from: url) { string in
            do {
                let doc: Document = try SwiftSoup.parse(string)
                try doc.select("sup").remove()
                guard let banner = try doc.select("div.banner,div.dark-header").first() else {
                    throw ScraperError.NoBanner
                }
                let style = try banner.attr("style")
                let title = try { () -> String in
                    guard let sib = try banner.nextElementSibling(),
                          let el = sib.children()[safe: 1]
                    else {
                        return "[Redacted]"
                    }
                    return try el.text()
                }()
                let flavor = try { () -> String in
                    if let el = banner.siblingElements()[safe: 1] {
                        return try el.text()
                    } else {
                        return ""
                    }
                }()
                let description = try { () -> String in
                    if let desc = try doc.select("div.description")[safe: 0] {
                        return try desc.text()
                    } else {
                        return ""
                    }
                }()
                let footnotes = try { () -> [(String, String)] in
                    if let fns = try doc.select("div.footnotes")[safe: 0],
                       let ch1 = fns.children()[safe: 0] {
                        return try ch1.children().map { el -> (String, String) in
                            if let shell = el.children()[safe: el.children().count-1],
                               let link = shell.children()[safe: 0] {
                                return (name: try link.text(), link: "https://www.ishtar-collective.net\(try link.attr("href"))")
                            } else {
                                return ("", "")
                            }
                        }
                    } else {
                        return []
                    }
                }()
                let entries = try doc.select("div.entry-thumbnail").map { el -> (String, String) in
                    let link = el.children().first()!
                    return (name: try link.text(), link: "https://www.ishtar-collective.net\(try link.attr("href"))")
                }
                let image = { () -> String in
                    if let urlStr = style.range(
                        of: #"https://.+?(?=\')"#,
                        options: .regularExpression
                    ), let image = style[safe: urlStr] {
                        return String(image)
                    } else {
                        return ""
                    }
                }()
                completion(Category(
                    title: title,
                    image: image,
                    flavor: flavor,
                    description: description,
                    references: footnotes,
                    entries: entries
                ))
             } catch Exception.Error(let type, let message) {
                 print("\(type): \(message)")
                 completion(Category())
             } catch {
                 print("error with \(url)")
                 completion(Category())
             }
        }
    }
    
    static func scrapeBook(_ url: String, _ completion: @escaping (Book) -> Void) {
        Self.readHTML(from: url) { string in
            do {
                let doc: Document = try SwiftSoup.parse(string)
                try doc.select("sup").remove()
                guard let banner = try doc.select("div.banner").first() else {
                    throw ScraperError.NoBanner
                }
                let style = try banner.attr("style")
                let title = try { () -> String in
                    if let sib = try banner.nextElementSibling(),
                       let el = sib.children()[safe: 1] {
                        return try el.text()
                    } else {
                        return "[Redacted]"
                    }
                }()
                let footnotes = try { () -> [(String, String)] in
                    if let fns = try doc.select("div.footnotes")[safe: 0],
                       let ch1 = fns.children()[safe: 0] {
                        return try ch1.children().map { el -> (String, String) in
                            if let shell = el.children()[safe: el.children().count-1],
                               let link = shell.children()[safe: 0] {
                                return (name: try link.text(), link: "https://www.ishtar-collective.net\(try link.attr("href"))")
                            } else {
                                return ("", "")
                            }
                        }
                    } else {
                        return []
                    }
                }()
                let entries = try doc.select("div.entry-thumbnail").map { el -> (String, String, String) in
                    if let link = el.children()[safe: 0] {
                        return (
                            name: try link.text(),
                            image: try link.children()[safe: 0]?.attr("data-src") ?? "",
                            link: "https://www.ishtar-collective.net\(try link.attr("href"))"
                        )
                    } else {
                        return ("", "", "")
                    }
                }
                completion(Book(
                    title: title,
                    image: String(style[style.range(
                        of: #"https://.+?(?=\')"#,
                        options: .regularExpression
                    )!]),
                    references: footnotes,
                    entries: entries
                ))
            } catch Exception.Error(let type, let message) {
                print("\(type): \(message)")
                completion(Book())
            } catch {
                print("error with \(url)")
                completion(Book())
            }
        }
    }
    
    static func scrapeEntry(_ url: String, _ completion: @escaping (Entry) -> Void) {
        Self.readHTML(from: url) { string in
            do {
                let doc: Document = try SwiftSoup.parse(string)
                let title = try { () -> String in
                    if let wrap = try doc.select("div.wrapper").first() {
                        return try wrap.text()
                    } else {
                        return ""
                    }
                }()
                let subtitle = try { () -> String in
                    if let sub = try doc.select("div.subtitle").first() {
                        return try sub.text()
                    } else {
                        return ""
                    }
                }()
                let image = try { () -> String in
                    if let desc = try doc.select("p.image").first(),
                       let img = desc.children().first() {
                        return try img.attr("data-src")
                    } else {
                        return ""
                    }
                }()
                let description = try { () -> String in
                    if let desc = try doc.select("div.description").first() {
                        return try desc.text()
                    } else {
                        return ""
                    }
                }()
                let categories = try { () -> [(String, String)] in
                    if let cats = try doc.select("div.categories").first(),
                       let items = cats.children()[safe: 1] {
                        return try items.children().map { cat -> (String, String) in
                            if let link = try cat.select("a").first() {
                                return (
                                    name: try link.text(),
                                    link: "https://www.ishtar-collective.net\(try link.attr("href"))"
                                )
                            } else {
                                return ("", "")
                            }
                        }
                    } else {
                        return []
                    }
                }()
                let added = try { () -> (String, String) in
                    if let span = try doc.select("span.release-icon").first(),
                       let added = try span.nextElementSibling() {
                        return (
                            name: try added.text(),
                            link: "https://www.ishtar-collective.net\(try added.attr("href"))"
                        )
                    } else {
                        return ("", "")
                    }
                }()
                completion(Entry(
                    title: title,
                    subtitle: subtitle,
                    image: image,
                    description: description,
                    categories: categories,
                    added: added,
                    associated: []
                ))
            } catch Exception.Error(let type, let message) {
                print("\(type): \(message)")
                completion(Entry())
            } catch {
                print("error with \(url)")
                completion(Entry())
            }
        }
    }
    
    static func scrapeCategories(_ completion: @escaping (Categories) -> Void) {
        Self.readHTML(from: "https://www.ishtar-collective.net/categories") { string in
            do {
                let doc: Document = try SwiftSoup.parse(string)
                let categories = try { () -> Categories in
                    guard let parent = try doc.select("h2.col-8").parents().first() else {
                        return Categories()
                    }
                    return try parent.children().reduce(into: Categories()) { acc, x in
                        guard let letter = x.children().first(),
                              let list = x.children().last()
                        else {
                            return
                        }
                        let items = try list.children().compactMap { el -> (String, String)? in
                            guard let link = el.children().first() else {
                                return ("", "")
                            }
                            let body = try el.text()
                            if acc.sections.contains(where: {
                                $0.categories.contains(where: {
                                    $0.name == body
                                })
                            }) {
                                return .none
                            }
                            return (
                                name: body,
                                link: "https://www.ishtar-collective.net\(try link.attr("href"))"
                            )
                        }
                        if let index = try acc.sections.firstIndex(where: {
                            try letter.text() == $0.letter
                        }) {
                            acc.sections[index].categories += items
                        } else {
                            acc.sections.append(
                                Categories.CategorySection(
                                    letter: try letter.text(),
                                    categories: items
                                )
                            )
                        }
                    }
                }()
                completion(categories)
            } catch Exception.Error(let type, let message) {
                print("\(type): \(message)")
                completion(Categories())
            } catch {
                print("error (categories)")
                completion(Categories())
            }
        }
    }
    
    static func scrapeHome(_ completion: @escaping (([HomeEntry], [HomeEntry])) -> Void) {
        Self.readHTML(from: "https://www.ishtar-collective.net/") { string in
            do {
                let masks = ["f_claret_to_light_gray": Color.ishtarRed, "f_port_gore_to_cabaret": Color.ishtarPurple, "f_dark_gray_to_tango": Color.ishtarBrown]
                typealias HomeTuple = ([HomeEntry], [HomeEntry])
                let doc: Document = try SwiftSoup.parse(string)
                guard let table: Element = try doc.select("div.grid-11.feature-grid.wrapper.flat").first() else {
                    completion(([], []))
                    return
                }
                let home = try [1..<6, 7..<12].map { range in
                    try table.children()[range].map { item -> HomeEntry in
                        guard let info = item.children().first(),
                              let style = info.children().first(),
                              let t1 = info.children().last(),
                              let title = t1.children().last()
                        else {
                            return HomeEntry()
                        }
                        var maskStr = try style.attr("class")
                        if let range = maskStr.range(of: #"f_\w+?(?=\W|$)"#, options: .regularExpression) {
                            maskStr = String(maskStr[range])
                        }
                        let mask = masks.keys.reduce(into: Optional<Color>.none) {
                            if $1 == maskStr {
                                $0 = masks[$1]
                            }
                        }
                        return HomeEntry(
                            title: try title.text(),
                            image: String(try style.attr("style")[try style.attr("style").range(
                                of: #"https://.+?(?=\))"#,
                                options: .regularExpression
                            )!]),
                            mask: mask,
                            link: "https://www.ishtar-collective.net\(try info.attr("href"))"
                        )
                    }
                }
                completion(home.withUnsafeBytes { buf in
                    return buf.bindMemory(to: ([HomeEntry], [HomeEntry]).self)[0]
                })
            } catch Exception.Error(let type, let message) {
                print("\(type): \(message)")
                completion(([], []))
            } catch {
                print("error (generic)")
                completion(([], []))
            }
        }
    }
    
}
