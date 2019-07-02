-- Copyright (c) 2019 Shawn Eary
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--
--
-- SAPU - Shawn's Aweful Password Utility
-- 
-- SAPU is Licensed via the MIT License (See Above)
--
-- This is a password manager and it is in the alpha stage.  You are
-- welcome to browse the code to see very basic Haskell but do not
-- use this Password Manager.  I am *NOT* a security expert and this
-- password manager was slapped together in a big hurry.  It is more
-- of an academic exercise than anything else.  I accept *NO*
-- repsonsibility for anything bad this might program might do to your
-- passwords, identity, mental stability or anything else.  With that
-- said, you are certainly welcome to write your own password manager
-- but again if it blows up and half the world dies off, that's not
-- my problem...
--
--       1         2         3         4         5         6         7
-- 456789012345678901234567890123456789012345678901234567890123456789012
-- 
-- This program uses the following Haskell Packages clipboard, split,
-- haskeline and cryptonite.  You will need to install them before
-- compiling this one file program.
--
-- EASY COMPILATION STEPS:
-- cabal install clipboard
-- cabal install haskeline
-- NOT Used Right now - Want to use in future-- cabal install cryptonite
-- cabal install SimpleAES
-- cabal install split
-- ghc passMgr.hs
--
-- SPECIFIC REFERENCES:
-- The references in this section are for unique or novel concepts that
-- I was specifically struggling with.  You should generally see at
-- least one inline citation for ever source in this section.
-- Authors credited for StackExchange posts are done in the following
-- format:
-- [MyFavoriteAnswererName; QuestionAskerName; et al...]
-- Since the favorite answer for my use case and the queston asker
-- seem they should get the most credit
--
-- [1] - Velkov, Daniel; Apfelmus, Heinrich; et al...
-- Prompting for a Password in Haskell Commmand Line Application
-- StackOverflow
-- https://stackoverflow.com/questions/4064378/
-- prompting-for-a-password-in-haskell-command-line-application
-- November 1, 2010
-- [Last Accessed: June 30, 2019]
--
-- [2] - Jonno_FTW; Wilson, Eric; et al...
-- How to Split a String in Haskell?
-- StackOverflow
-- https://stackoverflow.com/questions/4978578/
-- how-to-split-a-string-in-haskell
-- February 12, 2011
-- [Last Accessed: June 30, 2019]
--
-- [3] - Peacker; Eding, Thomas; et al...
-- What is the Best Way to Convert STring to ByteString
-- StackOverflow
-- https://stackoverflow.com/questions/3232074/
-- what-is-the-best-way-to-convert-string-to-bytestring
-- July 13, 2010
-- [Last Accessed: July 1, 2019]
--
-- GENERAL REFERECES:
-- The referneces in listed in this section were overarching and
-- general.  They were used so frequently that it doesn't make sense to
-- use an inline citation *every* single time they were referenced.  In
-- the event something very unique or novel from those references is
-- used that unique or novel though will be cited.  Otherwise, do not
-- expect to see inline citations of these sources scattered all over
-- the source code
--
-- [A] - Hudak, Paul; Peterson, John; Fasel, Joseph
-- A Gentle Introduction to Haskell 98
-- October, 1999
-- https://www.haskell.org/tutorial/haskell-98-tutorial.pdf
-- https://www.haskell.org/tutorial/index.html
-- [Last Referenced: June 30, 2019]
--
-- [B] - Baker, Martin
-- Haskell Operators
-- Euclidean Space
-- https://www.euclideanspace.com/
-- software/language/functional/haskell/operators/index.htm
-- [Last Referenced: June 30, 2019]
--
-- REFERNCE APPOLOGY:
-- While I would like for this to be an academic work, it is not
-- one.  This code is written in haste because I have a day job.
-- If I've accidently missed someone that has signifiantly helped
-- me without citing then or a "parent"/similar source, I appologize.
-- I will try to correct the situation when I become aware.  Also,
-- things that are common knowlege are not required to be cited, but
-- with me being a paranoid person, I tend to cite whenever I get
-- help 
import System.IO;
import System.Clipboard;
import System.Console.Haskeline;
import Data.List.Split;
import qualified Data.ByteString.UTF8 as UTF8;
import qualified Data.ByteString.Lazy as BL;
import qualified Data.ByteString as BStr;
import qualified Data.ByteString.Lazy.Char8 as LChar8;
import qualified Data.ByteString.Base64.Lazy as B64L;
import qualified Data.ByteString.Base64 as B64;

-- I wanted to use Cryptonite but I don't understand it right now
-- and I'm trying to get this out the door.  I will fix it later
import Codec.Crypto.SimpleAES;



-- Hardcoded for now
thePasswordFile = "samplePassFile";
splitToken = " :%: "

-- This actually isn't implemented correctly since splitToken
-- may appear again later on the line but it's probably good
-- enough for now...
splitRowFromSAPU :: String -> String -> (String, String)
splitRowFromSAPU tokenStr stringToSplit = do
  -- This the lazy way of splitting a string [2].
  -- I should be ashamed of myself but I'm in a hurry
  let theSplit = splitOn tokenStr stringToSplit
  if Prelude.length(theSplit) < 2 then
    ("", "")
  else
    (theSplit !! 0, theSplit !! 1)

searchFromSAPU :: Handle -> String -> IO String
searchFromSAPU h entryToFind = do
  atEndOfFile <- hIsEOF(h)
  if atEndOfFile then
    return ""
  else do
    someLine <- hGetLine h
    let theSplit = splitRowFromSAPU splitToken someLine
    let theRowDesc = fst(theSplit)
    let theEncryptedPass = snd(theSplit)
    let theRowOut = "**" ++ theRowDesc ++ "**"
    let entryOut = "**" ++ entryToFind ++ "**"
    -- putStrLn theRowOut
    -- putStrLn entryOut
    if theRowDesc == entryToFind then do
      return theEncryptedPass
    else
      searchFromSAPU h entryToFind

getPasswordFromSAPU :: String -> String -> IO String
getPasswordFromSAPU totalKey passDescription = do
  let entryToLookFor = passDescription   --  ++ ": "
  theHandle <- openFile thePasswordFile ReadMode
  theEncryptedPass <- (searchFromSAPU theHandle entryToLookFor)
  hClose theHandle
  return theEncryptedPass

writePass :: String -> LChar8.ByteString -> IO ()
writePass description password = do
  theHandle <- openFile thePasswordFile AppendMode
  let stringToWrite = description ++ splitToken
  hPutStr theHandle stringToWrite
  LChar8.hPutStrLn theHandle password
  hClose theHandle

getTotalKey :: String -> String -> String
getTotalKey inMemoryKey fromFileKey =
  inMemoryKey ++ fromFileKey

showMainMenu :: IO ()
showMainMenu = do
  putStrLn "";
  putStrLn "s - Set InMemory Key";
  putStrLn "n - New Password Mode";
  putStrLn "g - Get Password Mode";
  putStrLn "x - Exit";

runMainMenu :: String -> IO ()
runMainMenu inMemoryDecripKey = do
  -- putStrLn inMemoryDecripKey;
  showMainMenu;
  menuChoice <- getLine     -- GetChar was leaving junk at the end
  if menuChoice == "x" then
    putStrLn "Terminating"
  else if menuChoice == "s" then do
    putStrLn "Enter the inMemory Crypto Key Below:"
    putStrLn "[Until I fix the padding issue, just use three alphanumeric ASCII Characters]"
    -- Can't get this working right now [1]
    -- inMemoryKey <- getPassword (Just '*') "pass:"
    inMemoryKey <- getLine
    runMainMenu inMemoryKey
  else if menuChoice == "n" then do
    -- Location of extraKeyFile is hardcoded for now
    theHandle <- openFile "extraKeyFile" ReadMode
    theLine <- hGetLine theHandle
    hClose theHandle
    let tKey = getTotalKey inMemoryDecripKey theLine
    -- putStrLn tKey
    putStrLn "Enter Description Identifier:"
    theDescription <- getLine;
    putStrLn "Enter Password:"
    -- Can't get this working right now [1]
    -- thePassword <- getPassword (Just '*') "pass:"
    -- thePassword <- getLine;
    bPass <- BStr.getLine
    let blPass = BL.fromStrict bPass
    LChar8.putStrLn blPass
    let bTkey = UTF8.fromString tKey
    -- let blTkey = BL.fromStrict bTkey
    -- let bPassword = UTF8.fromString thePassword
    -- let blPassword = BL.fromStrict bPassword
    encryptedPassword <- encryptMsg CBC bTkey blPass
    -- LChar8.putStrLn encryptedPassword
    let encodedEncryptedPassword = B64L.encode encryptedPassword
    -- LChar8.putStrLn encodedEncryptedPassword
    let decryptedPassword = decryptMsg CBC bTkey encryptedPassword
    -- LChar8.putStrLn decryptedPassword 
    -- let strict = BL.toStrict encryptedPassword
    -- let epString = UTF8.toString strict
    -- putStrLn epString
    writePass theDescription encodedEncryptedPassword
    runMainMenu inMemoryDecripKey
  else if menuChoice == "g" then do
    -- Location of extraKeyFile is hardcoded for now
    theHandle <- openFile "extraKeyFile" ReadMode
    theLine <- hGetLine theHandle
    hClose theHandle
    let tKey = getTotalKey inMemoryDecripKey theLine
    let bTkey = UTF8.fromString tKey
    -- putStrLn tKey
    putStrLn "Enter Description Identifier:"
    theDescription <- getLine
    theEncryptedPass <- getPasswordFromSAPU tKey theDescription
    -- Converting a String to a ByteSTring according to [3]
    let bEncodedEncryptedPass = UTF8.fromString theEncryptedPass
    let bEncryptedPass = B64.decodeLenient bEncodedEncryptedPass
    let outString = "pass: " ++ theEncryptedPass

    let decryptedPassword = decryptMsg CBC bTkey (LChar8.fromStrict bEncryptedPass)

    -- Actually, I should maybe be copying the password to the clipboard
    -- so it isn't seen but I will need to get to that later
    LChar8.putStrLn decryptedPassword
    runMainMenu inMemoryDecripKey
  else
    runMainMenu inMemoryDecripKey

main :: IO ()
main = do
  setClipboardString "Something Else";
  runMainMenu "";
