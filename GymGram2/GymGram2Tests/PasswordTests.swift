//
//  PasswordTests.swift
//  GymGram2Tests
//
//  Created by Kamel on 23.04.2023.
//

import XCTest
@testable import GymGram2

final class PasswordTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPassword_WhenTooShort_ShouldReturnFalse() {
        let password = "pass"

        let isValid = password.isValidPassword()

        XCTAssertFalse(isValid, "isValidPassoword should return FALSE, but returned TRUE, which means that the password is too short")
    }

    func testPassword_WhenTooLong_ShouldReturnFalse() {
        let password = "passssssssssssss"

        let isValid = password.isValidPassword()

        XCTAssertFalse(isValid, "isValidPassoword should return FALSE, but returned TRUE, which means that the password is too long")
    }
    func testPassword_WhenHasNoUpperCaseLetters_ShouldReturnFalse() {
        let password = "abcd1234"
        
        let isValid = password.isValidPassword()
        
        XCTAssertFalse(isValid, "isValidPassoword should return FALSE, but returned TRUE, which means that the password has no uppercase letters")
    }
    
    func testPassword_WhenHasNoLowerCaseLetters_ShouldReturnFalse() {
        let password = "ABCD1234"

        let isValid = password.isValidPassword()
        
        XCTAssertFalse(isValid, "isValidPassoword should return FALSE, but returned TRUE, which means that the password has no lowercase letters")
    }

    func testPassword_WhenHasNoLetters_ShouldReturnFalse() {
        let password = "12345678"

        let isValid = password.isValidPassword()

        XCTAssertFalse(isValid, "isValidPassoword should return FALSE, but returned TRUE, which means that the password has no letters")
    }

    func testPassword_WhenHasNoNumbers_ShouldReturnFalse() {
        let password = "abcdFdsgh"

        let isValid = password.isValidPassword()

        XCTAssertFalse(isValid, "isValidPassoword should return FALSE, but returned TRUE, which means that the password has no numbers")
    }


    func testPassword_WhenIsProper_ShouldReturnTrue() {
        let password = "Abcd1234"
    }

}
