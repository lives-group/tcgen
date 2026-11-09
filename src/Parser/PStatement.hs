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

indented :: Parser a -> Parser (a, [Stmt])
indented pHeader = L.indentBlock scn $ do
    h <- pHeader <* symbol ":"
    return (L.IndentSome Nothing (\block -> return (h, block)) pStmt)

pIf :: Parser Stmt
pIf = do
    ifColumnPos <- L.indentLevel
    (conditionExpr, ifBody) <- indented (pKeyWord "if" *> pExpr)
    elseBody <- option [] (try $ pElse ifColumnPos)
    return (If conditionExpr ifBody elseBody)

pElse :: Pos -> Parser [Stmt]
pElse col = snd <$> indented (L.indentGuard scn EQ col *> pKeyWord "else")

pWhile :: Parser Stmt
pWhile = do
    (conditionExpr, whileBody) <- indented (pKeyWord "while" *> pExpr)
    return (While conditionExpr whileBody)

pDef :: Parser Stmt
pDef = do
    let
        header = (,) <$> (pKeyWord "def" *> pIdentifier)
                     <*> (parens (pIdentifier `sepBy` symbol ","))
    ((defName, parameters), defBody) <- indented header
    return (Def defName parameters defBody)

pStmt :: Parser Stmt
pStmt = choice [try pAssign, pDef, pIf, pWhile, pPrint, pExprStmt]
