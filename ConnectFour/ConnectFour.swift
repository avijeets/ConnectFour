//
//  ConnectFour.swift
//  ConnectFour
//
//  Created by Amar Ramachandran on 6/23/16.
//  Copyright © 2016 amarjayr. All rights reserved.
//

import Foundation
import Messages

enum CFCellState: CustomStringConvertible {
    case empty
    case occupied(CFPlayer)
    
    var description: String {
        switch self {
        case empty:
            return "empty"
        case occupied(let player):
            return player.description
        }
    }
}

struct CFPlayer: CustomStringConvertible {
    var uuid: String!
    var color: UIColor!
    
    var description: String {
        return uuid! + ":/:" + color.hexString(includeAlpha: false)
    }
}

extension CFPlayer: Hashable {
    var hashValue: Int {
        return self.uuid.hashValue
    }
}

extension CFPlayer: Equatable {}

func == (lhs: CFPlayer, rhs: CFPlayer) -> Bool {
    return lhs.uuid == rhs.uuid
}

enum TTTError: ErrorProtocol, CustomStringConvertible {
    case rowFull
    case notPlayerTurn
    case gameDone
    
    var description: String {
        switch self {
        case .rowFull:
            return "The current row is full."
        case .notPlayerTurn:
            return "Not current player's turn."
        case .gameDone:
            return "The game is over."
        }
    }
}

class ConnectFour {
    private var grid: [[CFCellState]]!
    
    let player: CFPlayer!
    let opponent: CFPlayer!
    var players: [CFPlayer] {
        return [player, opponent]
    }
    
    var size: CGSize {
        return CGSize(width: grid.count, height: grid[0].count)
    }
    
    var winner: CFPlayer? {
        return checkWinner() ?? nil
    }
    
    subscript(row: Int, column: Int) -> CFCellState {
        get {
            return grid[row][column]
        }
        set(value) {
            grid[row][column] = value
        }
    }

    // MARK: Initializers
    
    init(player: CFPlayer, opponent: CFPlayer, width: Int = 7, height: Int = 6) {
        self.player = player
        self.opponent = opponent
        
        grid = Array(repeatElement(Array(repeatElement(CFCellState.empty, count: height)), count: width))
    }
    
    private init(player: CFPlayer, opponent: CFPlayer, board: [[CFCellState]]) {
        self.player = player
        self.opponent = opponent
        
        grid = board
    }

    // MARK: Board manipulation
    
    func drop(in row: Int) throws {
        
    }
    
    private func firstAvailableSpot(in row: Int) -> (row: Int, column: Int) {
        
    }
    
    // MARK: Winning/Gameover handling
    
    func checkWinner() -> CFPlayer? {
        return checkDiagonals() ?? checkAntidiagonals() ?? checkColumns() ?? checkRows()
    }

    private func checkDiagonals() -> CFPlayer? {
        
    }
    
    private func checkAntidiagonals() -> CFPlayer? {
        
    }
    
    private func checkColumns() -> CFPlayer? {
        
    }
    
    private func checkRows() -> CFPlayer? {
        
    }
    
    // MARK: Utility
    
    func moveCount(for player: CFPlayer?) -> Int {
        guard player == self.player || player == opponent else {
            fatalError("Player not part of game.")
        }
        
        return grid.flatMap { $0 }.filter { (element) -> Bool in
            if case .occupied(let user) = element {
                return user == player
            }
            return false
            }.count
    }
    
    func containsUserWith(uuid user: String) -> Bool {
        return player.uuid == user || opponent.uuid == user
    }
}
