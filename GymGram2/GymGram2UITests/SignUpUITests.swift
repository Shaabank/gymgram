//
//  SignUpUITests.swift
//  GymGram2UITests
//
//  Created by Kamel on 24.04.2023.
//

import XCTest

final class SignUpUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.

        let app = XCUIApplication()
        app.launch()
        app.buttons["Do not have an account?  Sign UP"].tap()

        print(app.buttons)

        let emailField = app.textFields["Email@.com"]
        emailField.tap()
        emailField.typeText("test@gmail.com")

        let fullName = app.textFields["Full Name..."]
        fullName.tap()
        fullName.typeText("Test User")

        let userName = app.textFields["Username..."]
        userName.tap()
        userName.typeText("testuser")

        let password = app.secureTextFields["Password"]
        password.tap()
        password.typeText("a")

        app.buttons["photoButton"].tap()
        app.images.element(boundBy: 1).tap()

        app.buttons["Choose"].tap()

        if app.buttons["SignUP"].waitForExistence(timeout: 5) {

        }
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }


}
