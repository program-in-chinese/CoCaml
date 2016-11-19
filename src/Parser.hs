module Parser where

import Ast

import Control.Applicative hiding ((<|>), many)
import Text.Parsec hiding (token)
import Text.Parsec.String
import Text.Parsec.Combinator
import Text.Parsec.Char

parse :: String -> Either ParseError Prog
parse program = Text.Parsec.parse prog "" program

prog :: Parser Ast.Prog
prog = return []

alphas :: Parser Char
alphas = oneOf $ ['0'..'9'] ++ ['a'..'z'] ++ ['A'..'Z'] ++ "'_()+-="

regchars :: [Char]
regchars = "　 、。也為如若寧無呼取何也以定「」"

tokenList :: Parser String
tokenList = (spaces *> noneOf regchars <* spaces )`sepBy1` char '-'

token :: Parser String
token = spaces *>  (many1 alphas <|> tokenList) <* spaces

idt :: Parser Idt
idt = Idt <$> token

lidt :: Parser Expr
lidt = LIdt <$> idt

atom :: Parser Expr
atom = lidt

apply :: Parser Expr
apply = foldl Apply <$> atom <*> many expr

pipe :: Parser Expr
pipe = foldl1 Pipe <$> apply `sepBy1` char '、'

rec :: Parser IsRec
rec = option NonRec $ (char '再' *> return Rec)

llet :: Parser Expr
llet = do
  char '以'
  r <- rec
  f <- idt
  args <- many idt
  char '為'
  val <- pipe
  char '如'
  e <- pipe
  return $ Let r f args val e

expr :: Parser Expr
expr =  llet <|> pipe
