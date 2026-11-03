module Parser.PCommon where

import Data.Void (Void)
import Text.Megaparsec
import Text.Megaparsec.Char
import qualified Text.Megaparsec.Char.Lexer as L

type Parser = Parsec Void String

reservedWords :: [String]
reservedWords = ["True", "False", "None", "print", "if", "else", "while", "def", "return"]

sc :: Parser ()
sc = L.space
        space1
        (L.skipLineComment "#")
        (L.skipBlockComment "'''" "'''")

lexeme :: Parser a -> Parser a
lexeme = L.lexeme sc

symbol :: String -> Parser String
symbol = L.symbol sc