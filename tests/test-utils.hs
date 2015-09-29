import System.Exit (exitFailure)
import Data.List (elemIndices, sort, nub)

import Test.Check
import Test.Check.Utils
import Test.Check.Invariants
import Test.Types (Nat)


(==>) :: Bool -> Bool -> Bool
False ==> _ = True
_     ==> y = y
infixr 0 ==>

argTypeOf :: (a -> b) -> a -> (a -> b)
argTypeOf = const

main :: IO ()
main =
  case elemIndices False tests of
    [] -> putStrLn "Tests passed!"
    is -> do putStrLn ("Failed tests:" ++ show is)
             exitFailure

tests =
  [ True

  , checkNoDup 12
  , checkCrescent 20
  , checkLengthListingsOfLength 5 5
  , checkSizesListingsOfLength 5 5

  , holds 100 (prop `argTypeOf` ('a','b'))
  ]

-- TODO: Remove map reverse (make actual code consistent)
checkNoDup :: Int -> Bool
checkNoDup n = take n (lsNoDupListsOf (listing :: [[Int]]))
            == take n ((map . filter) noDup (map reverse $ listing :: [[[Int]]]))
  where noDup xs = nub (sort xs) == sort xs

checkCrescent :: Int -> Bool
checkCrescent n = take n (lsCrescListsOf (listing :: [[Nat]]))
               == take n ((map . filter) (strictlyOrderedBy compare) (map reverse $ listing :: [[[Nat]]]))

checkLengthListingsOfLength :: Int -> Int -> Bool
checkLengthListingsOfLength n m = all check [1..m]
  where check m = all (\xs -> length xs == m)
                $ concat . take n
                $ listingsOfLength m natListing

checkSizesListingsOfLength :: Int -> Int -> Bool
checkSizesListingsOfLength n m = all check [1..m]
  where check m = orderedBy compare
                $ map sum . concat . take n
                $ listingsOfLength m natListing

prop :: (Eq a, Eq b) => (a,b) -> [(a,b)] -> Bool
prop (x,y) ps = (x,y) `elem` ps
            ==> pairsToFunction ps x == y
   
natListing :: [[Nat]]
natListing = listing