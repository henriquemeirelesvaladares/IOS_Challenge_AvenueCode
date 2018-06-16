//
//  ModelTests.swift
//  ModelTests
//
//  Created by Henrique Valadares on 13/06/18.
//  Copyright © 2018 Henrique Valadares. All rights reserved.
//

import XCTest

@testable import IOS_Challenge_AvenueCode

class ModelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    let location: Location = Location(name: "Belo Horizonte", latitude: -19.8843222, longitude: -43.9627492)
    
    func testLocationNotNil() {
        
        XCTAssertNotNil(location, "Location should not be nil")
    }
    
    func testEmptyLocationName() {
        
        XCTAssertFalse(location.name == "", "Location name can not be empty")
    }
    
    func testNilLocationName() {
        
        XCTAssertNotNil(location.name, "Location can not be nil")
    }
    
    func testNilLocationLatitute() {
        
        XCTAssertNotNil(location.latitude, "Location latitude can not be nil")
    }
    
    func testNilLocationLongitude() {
        
        XCTAssertNotNil(location.longitude, "Location longitude can not be nil")
    }
    
    func testValidLocationLatitude() {
        let validLat:Bool = location.latitude >= -85 && location.latitude <= 85
        XCTAssertTrue(validLat, "Location latitude must be higher than -85 and lower than 85")
    }
    
    func testValidLocationLongitude() {
        let validLon:Bool = location.longitude >= -180 && location.longitude <= 180
        XCTAssertTrue(validLon, "Location longitude must be higher than -180 and lower than 180")
    }
    
    
    
    
}
