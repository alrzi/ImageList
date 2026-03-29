//
//  WebViewAuthHelper.swift
//  ImageList
//
//  Created by Александр Зиновьев on 01.03.2025.
//

import Foundation

struct WebViewAuthHelper {
    func code(from url: URL) -> String? {
        guard
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let codeItem = urlComponents.queryItems?.first(where: { $0.name == "code" })
        else {
            return nil
        }

        return codeItem.value
    }
}
