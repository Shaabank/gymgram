//
//  FullNameTests.swift
//  GymGram2Tests
//
//  Created by Kamel on 24.04.2023.
//

import XCTest
@testable import GymGram2

final class FullNameTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }



    func testFullName_WhenIsValid_ShouldReturnFalse() {
        let fullName = "John Doe"

        let isValid = fullName.isValidFullName()

        XCTAssertTrue(isValid, "isValidPassoword should return TRUE, but returned FALSE")
    }

    func testFullName_WhenIsTooShort_ShouldReturnFalse() {
        let fullName = "d"

        let isValid = fullName.isValidFullName()

        XCTAssertFalse(isValid, "isValidPassoword should return FALSE, but returned TRUE")
    }

    func testFullName_WhenIsTooLong_ShouldReturnFalse() {
        let fullName = "Johnjohnjohnjohnjohnjohnjohnjohnjohnjohohn Doeeoedoe"

        let isValid = fullName.isValidFullName()

        XCTAssertFalse(isValid, "isValidPassoword should return FALSE, but returned TRUE")
    }

    func testFullName_WhenHasNumber_ShouldReturnFalse() {
        let fullName = "John😆 Doe"

        let isValid = fullName.isValidFullName()

        XCTAssertFalse(isValid, "isValidPassoword should return FALSE, but returned TRUE")
    }

    func testFullName_WhenHasSpecialChars_ShouldReturnFalse() {
        let fullName = "John1 Doe"

        let isValid = fullName.isValidFullName()

        XCTAssertFalse(isValid, "isValidPassoword should return FALSE, but returned TRUE")
    }
}
