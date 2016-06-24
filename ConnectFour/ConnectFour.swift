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

enum CFError: ErrorProtocol, CustomStringConvertible {
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
    
    var size: (columns: Int, rows: Int) {
        return (grid.count, grid[0].count)
    }
    
    var winner: CFPlayer? {
        return checkWinner() ?? nil
    }
    
    subscript(column: Int, row: Int) -> CFCellState {
        get {
            return grid[column][row]
        }
        set(value) {
            grid[column][row] = value
        }
    }
    
    var requiredInRowCustom: Int = 4

    // MARK: Initializers
    
    init(player: CFPlayer, opponent: CFPlayer, columns: Int = 7, rows: Int = 6) {
        self.player = player
        self.opponent = opponent
        
        grid = Array(repeatElement(Array(repeatElement(CFCellState.empty, count: rows)), count: columns))
    }
    
    private init(player: CFPlayer, opponent: CFPlayer, board: [[CFCellState]]) {
        self.player = player
        self.opponent = opponent
        
        grid = board
    }

    // MARK: Board manipulation
    
    func drop(in column: Int) throws {
        guard column < size.columns && column >= 0 else {
            fatalError("Coordinates not on grid")
        }
        
        guard winner == nil else {
            throw CFError.gameDone
        }
        
        guard moveCount(for: player) <= moveCount(for: opponent) else {
            throw CFError.notPlayerTurn
        }
        
        do {
            let coordinates = try firstAvailableSpot(in: column)
            
            self[coordinates.column, coordinates.row] = CFCellState.occupied(player)
        } catch CFError.rowFull {
            throw CFError.rowFull
        }
    }
    
    private func firstAvailableSpot(in column: Int) throws -> (column: Int, row: Int) {
        for i in 0..<size.rows {
            if case .empty = self[column, (size.rows-1)-i] {
                return (column, (size.rows-1)-i)
            }
        }
        
        throw CFError.rowFull
    }
    
    // MARK: Winning/Gameover handling
    
    func checkWinner() -> CFPlayer? {
        return checkDiagonals() ?? checkAntidiagonals() ?? checkColumns() ?? checkRows()
    }

    private func checkDiagonals() -> CFPlayer? {
        return nil
    }
    
    private func checkAntidiagonals() -> CFPlayer? {
        return nil
    }
    
    private func checkColumns() -> CFPlayer? {
        return nil
    }
    
    private func checkRows() -> CFPlayer? {
        return nil
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
