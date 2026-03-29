//
//  ImageListDataTests.swift
//  ImageListDataTests
//
//  Created by Александр Зиновьев on 05.03.2025.
//

@testable import ImageListData
import Testing

struct ImageListDataTests {
    let cache = Cache<String, Int>()

    @Test func example() async {
        let keys = Array(0..<100).map { "key\($0)" }

        await withTaskGroup { group in
            for key in keys {
                group.addTask {
                    await cache.setValue(Int.random(in: 0...100), for: key)
                }
            }
        }

        await #expect(cache.values.count == keys.count)

        let retrievedValues: [String: Int] = await withTaskGroup { group in
            for key in keys {
                group.addTask {
                    (await cache.getValue(for: key), key)
                }
            }

            return await group.reduce(into: [:]) { $0[$1.1] = $1.0 }
        }

        for key in keys {
            #expect(retrievedValues[key] != nil)
        }
    }
}
