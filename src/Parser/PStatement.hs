module Parser.PStatement where

import Text.Megaparsec
import Control.Monad (void)
import Parser.PExpression
import Parser.PCommon
import AST
import qualified Text.Megaparsec.Char.Lexer as L

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

pIf :: Parser Stmt
pIf = do
    ifColumnPos <- L.indentLevel
    (ifBody, conditionExpr) <- p'If
    elseBody <- option [] (try $ p'Else ifColumnPos)
    return (If conditionExpr ifBody elseBody)

    where
        p'If = L.indentBlock scn $ do
            void (pKeyWord "if")
            conditionExpr <- pExpr
            void (symbol ":")
            return (L.IndentSome Nothing (\ifStmts -> return (ifStmts, conditionExpr)) pStmt)
        p'Else ifColumnPos = L.indentBlock scn $ do
            void (L.indentGuard scn EQ ifColumnPos)
            void (pKeyWord "else" >> symbol ":")
            return (L.IndentSome Nothing return pStmt)

pWhile :: Parser Stmt
pWhile = L.indentBlock scn $ do
    void (pKeyWord "while")
    conditionExpr <- pExpr
    void (symbol ":")
    return (L.IndentSome Nothing (\whileStmts -> return (While conditionExpr whileStmts)) pStmt)

pDef :: Parser Stmt
pDef = L.indentBlock scn $ do
    void (pKeyWord "def")
    defName <- pIdentifier
    parameters <- parens (pIdentifier `sepBy` symbol ",")
    void (symbol ":")
    return (L.IndentSome Nothing (\defStmts -> return (Def defName parameters defStmts)) pStmt)

pStmt :: Parser Stmt
pStmt = choice [try pAssign, pDef, pIf, pWhile, pPrint, pExprStmt]