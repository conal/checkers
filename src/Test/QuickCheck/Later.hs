{-# OPTIONS_GHC -Wall #-}
----------------------------------------------------------------------
-- |
-- Module      :  Data.Later
-- Copyright   :  (c) David Sankel 2008
-- License     :  BSD3
-- 
-- Maintainer  :  david@sankelsoftware.com
-- Stability   :  experimental
-- 
-- Later. Allows for testing of functions that depend on the order of
-- evaluation.
----------------------------------------------------------------------

module Test.QuickCheck.Later
  ( isAssocTimes
  , isCommutTimes
  , delay
  , delayForever
  ) where

import Test.QuickCheck.Help
import Test.QuickCheck

import Control.Applicative ()
import System.Random       ()

import System.IO.Unsafe
import Control.Concurrent
import Control.Monad(forever)

isCommutTimes :: (EqProp a1, Arbitrary a, Show a) => (a -> a -> a1) -> Property
isCommutTimes (#) =
  forAll (genR (1,100)) $ \ t1 ->
  forAll (genR (1,100)) $ \ t2 ->
  forAll (arbitrary) $ \ v ->
  let v1 = (delay v t1)
      v2 = (delay v t2)
  in
    v1 # v2 =-= v2 # v1

isAssocTimes :: (EqProp a, Arbitrary a, Show a) => (a -> a -> a) -> Property
isAssocTimes (#) =
  forAll (genR (1,100)) $ \ t1 ->
  forAll (genR (1,100)) $ \ t2 ->
  forAll (genR (1,100)) $ \ t3 ->
  forAll (arbitrary) $ \ v ->
  let v1 = (delay v t1)
      v2 = (delay v t2)
      v3 = (delay v t3)
  in
    (v1 # v2) # v3 =-= v1 # (v2 # v3)

delay :: a ->
         Int -> -- milliseconds
         a
delay i d = unsafePerformIO $ do
  v <- newEmptyMVar
  forkIO $ do
            threadDelay (d*1000)
            putMVar v i
  takeMVar v

delayForever :: a
delayForever = unsafePerformIO $ do forever (threadDelay maxBound)
                                    return undefined
