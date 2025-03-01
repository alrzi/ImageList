//
//  WebViewCookieDataCleaner.swift
//  ImageList
//
//  Created by Александр Зиновьев on 13.03.2023.
//

import WebKit

@MainActor
protocol WebViewCookieDataCleanerProtocol {
    func clean(for domain: String) async
}

struct WebViewCookieDataCleaner: WebViewCookieDataCleanerProtocol {
    let cookieStorage: HTTPCookieStorage = .shared
    let dataStore: WKWebsiteDataStore = .default()
    
    func clean(for domain: String) async {
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
