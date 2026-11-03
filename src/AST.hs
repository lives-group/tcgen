module AST where

data UnOp
    = Neg   -- -x
    | Not   -- not x
    deriving (Show, Eq, Read)

data BinOp 
    = Sum | Subtr | Product | Division
    | Eq  | Neq | Lt  | Gt
    | And | Or
    deriving (Show, Eq, Read)

data Expr
    = LitInt Int
    | LitStr String
    | LitBool Bool
    | Var String
    | Unary UnOp Expr
    | Binary BinOp Expr Expr
    | Input Expr
    deriving (Show, Eq, Read)

data Stmt
    = Assign String Expr
    | Print Expr
    | If Expr [Stmt] [Stmt]
    | While Expr [Stmt]
    | Def String [String] [Stmt]
    | ExprStmt Expr
    deriving (Show, Eq, Read)

-- A program itself is a bunch of statements
type Program = [Stmt]
