module Parser.PCommon where

import Data.Void (Void)
import Text.Megaparsec
import Text.Megaparsec.Char
import qualified Text.Megaparsec.Char.Lexer as L

type Parser = Parsec Void String

reservedWords :: [String]
reservedWords = ["True", "False", "None", "print", "if", "else", "while", "def", "return"]

lineComment :: Parser ()
lineComment = L.skipLineComment "#"

blockComment :: Parser ()
blockComment = L.skipBlockComment "'''" "'''"

-- Do not consume carriage return ('\r') and newline ('\n') chars
sc :: Parser ()
sc = L.space hspace1 lineComment blockComment

scn :: Parser ()
scn = L.space space1 lineComment blockComment

lexeme :: Parser a -> Parser a
lexeme = L.lexeme sc

symbol :: String -> Parser String
symbol = L.symbol sc

parens :: Parser a -> Parser a
parens = between (symbol "(") (symbol ")")

identifier :: Parser String
identifier = ((:) <$> fstVarChar <*> many leftVarChars)
        where
                fstVarChar = (letterChar <|> char '_')
                leftVarChars = (alphaNumChar <|> char '_')

stringLiteral :: Parser String
stringLiteral = singleQuoted <|> doubleQuoted
        where 
                singleQuoted = char '\'' *> manyTill L.charLiteral (char '\'')
                doubleQuoted = char '"' *> manyTill L.charLiteral (char '"')

pIdentifier :: Parser String
pIdentifier = lexeme (try name)
        where
                name = do
                        i <- identifier <?> "identifier"
                        if i `elem` reservedWords
                        then
                                fail ("keyword " ++ i ++ " cannot be an identifier")
                        else
                                return i