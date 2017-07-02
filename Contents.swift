//: Playground - noun: a place where people can play

import UIKit

// two types of errors: recoverable and nonrecoverable
// if swift gets a nonrecoverable error, it will shut down/crash the program

enum Token {
    case number(Int)
    case plus
}

class Lexer {
    enum Error: Swift.Error {
        case invalidCharacter(Character)
    }
    
    let input: String.CharacterView
    var position: String.CharacterView.Index
    
    init(input: String) {
        self.input = input.characters
        self.position = self.input.startIndex
    }
    func peek() -> Character? {
        guard position < input.endIndex else {
            return nil
        }
        return input[position]
    }
    // assert checks if first argument is true or false.  if true, nothing happens.  if false, program will trap in the debugger with the message (second argument)
    // assert can't be used in release mode.  use precondition(_: _: instead)
    func advance() {
        assert(position < input.endIndex, "Cannot advance past endIndex!")
        position = input.index(after: position)
    }
    
    func getNumber() -> Int {
        var value = 0
        
        while let nextCharacter = peek() {
            switch nextCharacter {
            case "0" ... "9":
                //another digit - add it into value
                let digitValue = Int(String(nextCharacter))!
                value = 10*value + digitValue
                advance()
                
            default:
                // a nondigit - go back to regular lexing
                return value
            }
        }
        return value
    }
    
    func lex() throws -> [Token] {
        var tokens = [Token]()
        
        while let nextCharacter = peek() {
            switch nextCharacter {
                case "0" ... "9":
                    let value = getNumber()
                    tokens.append(.number(value))
                
                case "+": tokens.append(.plus)
                advance()
                
                case " ":
                // just advance to ignore spaces
                advance()
                
                default:
                // something unexpected - need to send back an error
                throw Lexer.Error.invalidCharacter(nextCharacter)
            }
        }
        return tokens
    }
}

class Parser {
    enum Error: Swift.Error {
        case unexpectedEndOfInput
        case invalidToken(Token)
    }
    
    let tokens: [Token]
    var position = 0
    
    init (tokens: [Token]) {
        self.tokens = tokens
    }
    
    func getNextToken() -> Token? {
        guard position < tokens.count else {
            return nil
        }
        let token = tokens[position]
        position += 1
        return token
    }
    
    func getNumber() throws -> Int {
        guard let token = getNextToken() else {
            throw Parser.Error.unexpectedEndOfInput
        }
    
        switch token {
        case .number(let value):
            return value
        case .plus:
            throw Parser.Error.invalidToken(token)
        }
    }
    
    func parse() throws -> Int {
        // require a number first
        var value = try getNumber()
        
        while let token = getNextToken() {
            switch token {
            
            // getting a plus after a number is allowed
            case .plus:
                // after a plus, we must get another number
                let nextNumber = try getNumber()
                value += nextNumber
            
            // getting a number after a number is not legal
            case .number:
                throw Parser.Error.invalidToken(token)
            }
        }
        return value
    }
}

func evaluate(_ input: String) {
    print("Evaluating: \(input)")
    let lexer = Lexer(input: input)
    do {
        let tokens = try lexer.lex()
        print("Lexer output: \(tokens)")
        
        let parser = Parser(tokens: tokens)
        let result = try parser.parse()
        print("Parser output: \(result)")
    } catch Lexer.Error.invalidCharacter(let character) {
        print("Input contained an invalid character: \(character)")
    } catch Parser.Error.unexpectedEndOfInput {
        print("Unexpected end of input during parsing")
    } catch Parser.Error.invalidToken(let token) {
        print("Invalid token during parsing: \(token)")
    } catch {
        print("An error occurred: \(error)")
    }
}

evaluate("10 + 3 + 5")
evaluate("1 + 2 + 345")
evaluate("3 + 4")
evaluate("55 + neota")




