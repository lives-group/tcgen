module Parser.Parser (pProgram) where

import Text.Megaparsec (many, eof)
import AST
import Parser.PCommon
import Parser.PStatement
import qualified Text.Megaparsec.Char.Lexer as L

pProgram :: Parser Program
pProgram = scn *> many (L.nonIndented scn pStmt <* scn) <* eof