//
//  EmailTests.swift
//  GymGram2Tests
//
//  Created by Kamel on 24.04.2023.
//

import XCTest
@testable import GymGram2

final class EmailTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEmail_isValid_ShouldReturnTrue() {
        let email = "testmail@gmail.com"

        let isValid = email.isValidEmail()

        XCTAssertTrue(isValid, "isValidEmail should return TRUE, but returned FALSE")
    }

    func testEmail_IsEmpty_ShouldReturnFalse() {
        let email = ""

        let isValid = email.isValidEmail()

        XCTAssertFalse(isValid, "isValidEmail should return FALSE, but returned TRUE")
    }

    func testEmail_HasMultipleAtSigns_ShouldReturnFalse() {
        let email = "testmail@@@gmail.com"

        let isValid = email.isValidEmail()

        XCTAssertFalse(isValid, "isValidEmail should return FALSE, but returned TRUE")
    }

    func testEmail_HasInvalidTLD_ShouldReturnFalse() {
        let email = "testmail@gmail.c"

        let isValid = email.isValidEmail()

        XCTAssertFalse(isValid, "isValidEmail should return FALSE, but returned TRUE")
    }

    func testEmail_HasInvalidChars_ShouldReturnFalse() {
        let email = "testmail😆@gmail.com"

        let isValid = email.isValidEmail()

        XCTAssertFalse(isValid, "isValidEmail should return FALSE, but returned TRUE")
    }

}
