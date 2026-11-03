module Parser.PExpression where

import Text.Megaparsec
import Text.Megaparsec.Char
import qualified Text.Megaparsec.Char.Lexer as L
import Control.Monad.Combinators.Expr
-- Project defined modules imported bellow 
import Parser.PCommon
import AST

stringLiteral :: Parser String
stringLiteral = singleQuoted <|> doubleQuoted
        where 
                singleQuoted = char '\'' *> manyTill L.charLiteral (char '\'')
                doubleQuoted = char '"' *> manyTill L.charLiteral (char '"')

identifier :: Parser String
identifier = ((:) <$> fstVarChar <*> many leftVarChars)
        where
                fstVarChar = (letterChar <|> char '_')
                leftVarChars = (alphaNumChar <|> char '_')

parens :: Parser a -> Parser a
parens = between (symbol "(") (symbol ")")

pKeyWord :: String -> Parser String
pKeyWord keyword = lexeme $ try (string keyword <* notFollowedBy (alphaNumChar <|> char '_'))

pStringLiteral :: Parser Expr
pStringLiteral = LitStr <$> lexeme stringLiteral

pIntLiteral :: Parser Expr
pIntLiteral = LitInt <$> lexeme L.decimal

pBoolLiteral :: Parser Expr
pBoolLiteral = LitBool <$> lexeme boolLiteral
        where
                boolLiteral = choice [True <$ pKeyWord "True", False <$ pKeyWord "False"]

pVar :: Parser Expr
pVar = Var <$> lexeme (try name)
        where
                name = do
                        i <- identifier <?> "identifier"
                        if i `elem` reservedWords
                        then
                                fail ("keyword " ++ i ++ " cannot be an identifier")
                        else
                                return i

pTerm :: Parser Expr
pTerm = choice
        [
                parens pExpr,
                pIntLiteral,
                pStringLiteral,
                pBoolLiteral,
                pVar
        ]

pExpr :: Parser Expr
pExpr = makeExprParser pTerm operatorTable

operatorTable :: [[Operator Parser Expr]]
operatorTable =
        [
                [
                        prefix "+" id,
                        prefix "-" (Unary Neg)
                ],
                [
                        binary "*" (Binary Product),
                        binary "/" (Binary Division)
                ],
                [
                        binary "+" (Binary Sum),
                        binary "-" (Binary Subtr)
                ]
        ]


binary :: String -> (Expr -> Expr -> Expr) -> Operator Parser Expr
binary name f = InfixL (f <$ symbol name)

prefix, postfix :: String -> (Expr -> Expr) -> Operator Parser Expr
prefix name f = Prefix (f <$ symbol name)
postfix name f = Postfix (f <$ symbol name)