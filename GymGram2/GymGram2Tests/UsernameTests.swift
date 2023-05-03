//
//  UsernameTests.swift
//  GymGram2Tests
//
//  Created by Kamel on 24.04.2023.
//

import XCTest
@testable import GymGram2

final class UsernameTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUsername_IsProper_ShouldReturnFalse() {
        let username = "Johndoe2"

        let isValid = username.isValidUserName()

        XCTAssertTrue(isValid, "isValidPassoword should return TRUE, but returned TRUE")
    }

    func testUsername_IsTooShort_ShouldReturnFalse() {
        let username = "doe2"

        let isValid = username.isValidUserName()

        XCTAssertFalse(isValid, "isValidPassoword should return FALSE, but returned TRUE")
    }

    func testUsername_IsTooLong_ShouldReturnFalse() {
        let username = "johndoedoedoedoedoe20"

        let isValid = username.isValidUserName()

        XCTAssertFalse(isValid, "isValidPassoword should return FALSE, but returned TRUE")
    }
}
