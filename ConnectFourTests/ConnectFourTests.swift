//
//  ConnectFourTests.swift
//  ConnectFourTests
//
//  Created by Amar Ramachandran on 6/23/16.
//  Copyright © 2016 amarjayr. All rights reserved.
//

import XCTest
@testable import ConnectFour

class ConnectFourTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testConnectFourInit() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let game = ConnectFour(player: CFPlayer(uuid: "player1", color: #colorLiteral(red: 0.05259340256, green: 0, blue: 0.1441811323, alpha: 1)), opponent: CFPlayer(uuid: "player1", color: #colorLiteral(red: 0.05259340256, green: 0, blue: 0.1441811323, alpha: 1)))
        
    }
    

    
}
