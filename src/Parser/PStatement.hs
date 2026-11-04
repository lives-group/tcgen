module Parser.PStatement where

import Control.Monad (void)
import Parser.PExpression
import Parser.PCommon
import AST

pPrint :: Parser Stmt
pPrint = Print <$> (symbol "print" *> parens pExpr)

pAssign :: Parser Stmt
pAssign = do
    varName <- pIdentifier
    void (symbol "=")
    expr <- pExpr
    return (Assign varName expr)

pExprStmt :: Parser Stmt
pExprStmt = ExprStmt <$> pExpr