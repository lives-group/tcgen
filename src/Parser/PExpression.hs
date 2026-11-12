module Parser.PExpression where

import Text.Megaparsec
import Text.Megaparsec.Char
import qualified Text.Megaparsec.Char.Lexer as L
import Control.Monad.Combinators.Expr
-- Project defined modules imported bellow 
import Parser.PCommon
import AST

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
pVar = Var <$> pIdentifier

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
                ],
                [
                        binary "==" (Binary Eq),
                        binary "!=" (Binary Neq),
                        binary "<" (Binary Lt),
                        binary ">" (Binary Gt)
                ],
                [
                        prefixStr "not" (Unary Not)
                ],
                [
                        binaryStr "and" (Binary And)
                ],
                [
                        binaryStr "or" (Binary Or)
                ]
        ]

binary :: String -> (Expr -> Expr -> Expr) -> Operator Parser Expr
binary name f = InfixL (f <$ symbol name)

prefix, postfix :: String -> (Expr -> Expr) -> Operator Parser Expr
prefix name f = Prefix (f <$ symbol name)
postfix name f = Postfix (f <$ symbol name)

binaryStr :: String -> (Expr -> Expr -> Expr) -> Operator Parser Expr
binaryStr name f = InfixL (f <$ pKeyWord name)

prefixStr :: String -> (Expr -> Expr) -> Operator Parser Expr
prefixStr name f = Prefix (f <$ pKeyWord name)