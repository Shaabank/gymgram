//
//  SearchUITests.swift
//  GymGram2UITests
//
//  Created by Kamel on 25.04.2023.
//

import XCTest

final class SearchUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons.element(boundBy: 1).tap()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }


}
