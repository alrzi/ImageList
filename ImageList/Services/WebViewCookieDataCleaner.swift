//
//  WebViewCookieDataCleaner.swift
//  ImageList
//
//  Created by Александр Зиновьев on 13.03.2023.
//

import WebKit

protocol WebViewCookieDataCleanerProtocol {
    @MainActor
    func clean(for domain: String) async
}

struct WebViewCookieDataCleaner: WebViewCookieDataCleanerProtocol {
    let cookieStorage: HTTPCookieStorage = .shared

    func clean(for domain: String) async {
        let dataStore: WKWebsiteDataStore = .default()

        if let cookies = cookieStorage.cookies {
            for cookie in cookies where cookie.domain.contains(domain) {
                cookieStorage.deleteCookie(cookie)
            }
        }

        let records = await dataStore.dataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes())

        for record in records where record.displayName.contains(domain) {
            await dataStore.removeData(ofTypes: record.dataTypes, for: [record])
        }
    }
}
