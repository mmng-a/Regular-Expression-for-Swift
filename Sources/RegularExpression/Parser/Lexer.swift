
struct Lexer {
  
  var text: String
  
  init(text: String) {
    self.text = text
  }
  
  var state = State.normal
  enum State {
    case normal, union, number
  }
  
  mutating func scan() -> Token {
    if text.isEmpty { return Token.EOF }
    
    switch state {
    case .normal: return _scan()
    case .union:  return scanUnion()
    case .number: return scanNumber()
    }
  }
  
  private mutating func _scan() -> Token {
    let c = text.removeFirst()
    
    switch c {
    case "[":
      state = .union
      return .lSquareBracket
    case "{":
      state = .number
      return .lCurlyBracket
    case #"\"#:
      // not supporting `\p{UNICODE PROPERTY NAME}`
      if text.isEmpty { return .EOF }
      let first = text.removeFirst()
      return .character(first)
    case ".": return .dot
    case "*": return .star
    case "+": return .plus
    case "|": return .union
    case "?": return .question
    case "(": return .lParen
    case ")": return .rParen
    default:  return .character(c)
    }
  }
  
  private mutating func scanUnion() -> Token {
    let c = text.removeFirst()
    
    switch c {
    case "]":
      state = .normal
      return .rSquareBracket
    case #"\"#:
      if text.isEmpty { return .EOF }
      let first = text.removeFirst()
      switch first {
      case "d": text.insert(contentsOf: "0-9", at: text.startIndex)
      case "s": text.insert(contentsOf: "\r\n\t\n\r ", at: text.startIndex)
      case "w": text.insert(contentsOf: "a-zA-Z0-9_", at: text.startIndex)
      default:  break
      }
      return scanUnion()
    case "-": return .hyphen
    default:  return .character(c)
    }
  }
  
  private mutating func scanNumber() -> Token {
    let c = text.removeFirst()
    
    switch c {
    case "}":
      state = .normal
      return .rCurlyBracket
    case ",": return .comma
    default: return .character(c)
    }
  }
}
