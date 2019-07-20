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
-- APPROXIMATE COMPILATION STEPS for MS Windows:
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
-- What is the Best Way to Convert String to ByteString
-- StackOverflow
-- https://stackoverflow.com/questions/3232074/
-- what-is-the-best-way-to-convert-string-to-bytestring
-- July 13, 2010
-- [Last Accessed: July 1, 2019]
--
-- [4] - ocharles; Joiner, Matt; et al...
-- Convert a Lazy ByteString to a strict ByteString
-- StackOverflow
-- https://stackoverflow.com/questions/7815402/
-- convert-a-lazy-bytestring-to-a-strict-bytestring
-- November 29, 2012
-- [Last Accessed: July 4, 2019]
--
-- [5] - Burton, Kyle; Seymour, Chris
-- Haskell Output a List of ASCII Value
-- StackOverflow
-- https://stackoverflow.com/questions/13665796/
-- haskell-output-a-list-of-ascii-value
-- December 2, 2012
-- [Last Accessed: July 17, 2019]
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
-- [Last Referenced: July 4, 2019]
--
-- [C] - Various
-- Hackage
-- https://hackage.haskell.org/
-- [Last Referenced: July 3, 2019]
--
-- [D] - Various
-- Hoogλe
-- https://hoogle.haskell.org
-- [Last Referenced: July 17, 2019]
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
import Data.Char
import Data.Maybe
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
import System.Random;

-- I wanted to use Cryptonite but I don't understand it right now
-- and I'm trying to get this out the door.  I will fix it later
import Codec.Crypto.SimpleAES;



-- Contstants
splitToken = " :%: "
cryptoKeyLength = 32
extraKeyFile = "extraKeyFile"

-- The number of alphanumeric characters should be
-- 26 a-z + 26 A-Z + 10 for 0-9
alphaNumericExtent = (26 * 2) + 10

-- Hardcoded for now
thePasswordFile = "samplePassFile"



-- PURPOSE:
--   To indicated if the String s contains only ASCII alphanumeric
--   character
--   (There is a bug in this function.  It can't be used right now)s
--
-- s:
--   The string to examine
--
-- RETURNS:
--   True if the String s contains only alphanumeric characters from
--   the ASCII set
--   (There is a bug in this function.  It can't be used right now)
isAlphaNumClean :: String -> Bool
isAlphaNumClean s = do
  if s == "" then
    -- I know this is probably "techically" wrong
    -- but it is convienent for the purposes of
    -- recursion to assume that all empty strings
    -- are alphanumeric even if their status is
    -- undefined
    True
  else do
    let headChar = head s
    let tailString = tail s
    let itIsAlpha = isAlpha headChar
    let itIsASCII = isAscii headChar
    let curCharIsAlphaClean = itIsAlpha && itIsASCII
    curCharIsAlphaClean && (isAlphaNumClean tailString)



-- PURPOSE:
--   To determine if thePassPhrase is valid
--
-- thePassPhrase:
--   The pass phrase to check for validity
--
-- RETURNS:
--   True if thePassPhrase is thought to be valid and false it it is
--   deemed to be invalid
--   [Presently, the check for the validity of the pass phrase is
--    quite limited.  This isn't a security risk but it's a
---   nuisance because it will cause the encryption and decryption
--    to yield incorrect/garbled results.  Under the current
--    design (which will be eventually fixed) if the user enters
--    a bad passphrase, she/he will have to restart the application]
passPhraseIsValid :: String -> Bool
passPhraseIsValid thePassPhrase = do
  let passPhraseLen = Prelude.length(thePassPhrase)
  if passPhraseLen < 4 then
     False
  else if passPhraseLen > 16 then
     False
  else if (thePassPhrase == "") then
     False
  else
     True
     -- This isn't working just now
     -- isAlphaNumClean thePassPhrase



-- PURPOSE:
--   To return a randomly generated alphanumeric character
--
-- RETURNS:
--   A randomly generated alphanumeric character
getAlphaNumericChar :: IO Char
getAlphaNumericChar = do
  offSetNum <- getStdRandom (randomR (0,(alphaNumericExtent-1)))
  let keyVal =
           if offSetNum >= 0 && offSetNum <= 10 then
             48 + offSetNum
           else if offSetNum > 10 && offSetNum <= 36 then
             65 + (offSetNum - 11)
           else
             97 + (offSetNum - 37)
  -- From [5] chr gets a character from the integer ASCII value
  return (chr keyVal)



-- PURPOSE:
--   To create a "random" alphanumeric string of the specified length
--
-- len:
--   The length of the "random" alphanumeric string to create
--
-- RETURNS:
--   A "random" alphanumeric string of the specified length
generateNewFileKey :: Int -> IO String
generateNewFileKey len = do
  if (len < 1) then
    return ""
  else do
    nextChar <- getAlphaNumericChar
    restOfString <- (generateNewFileKey (len -1))
    let theString = nextChar : restOfString
    return theString



-- PURPOSE:
--   Runs until curPassPhrase is determined to be valid via
--   validationFunc
--
-- curPassPhrase:
--   The pass phrase to check for validity
--
-- validationFunc:
--   The function that verifies curPassPhrase
--   Validation Func must accept a string as input and return a true
--   or false value indicating if the input string is a valid
--   passPhrase.  The idea is that validationFunc can be changed in the
--   future to match the desired context
--
-- message:
--   The message to display when prompting for a passPhrase
--
-- RETURNS:
--   A valid passPhrase according to validationFunc
getUpdatedPassPhrase :: String -> (String -> Bool) -> String -> IO String
getUpdatedPassPhrase curPassPhrase validationFunc message = do
  if validationFunc curPassPhrase then
    return curPassPhrase
  else do
    putStrLn message
    let outString = "[4 - 16 Alphanumeric ASCII Characters]"
    putStrLn outString
    passPhrase <- getSecret
    getUpdatedPassPhrase passPhrase validationFunc message



-- PURPOSE:
--   Per [3] and [4], converts and ordinary string to a Lazy ByteString
--
-- s:
--   The String to convert to a Lazy ByteString
--
-- RETURNS:
--   A Lazy ByteString representing s
stringToLazyByteString :: String -> BL.ByteString
stringToLazyByteString s = do
  let byteString = UTF8.fromString s
  BL.fromStrict byteString



-- PURPOSE:
--   Per [3] and [4], converts a Lazy ByteString to an ordinary String
--
-- lbs:
--   The Lazy ByteString to convert to a String
--
-- RETURNS:
--   A String representing lbs
lazyByteStringToString :: BL.ByteString -> String
lazyByteStringToString lbs = do
  let strictByteString = BL.toStrict lbs
  UTF8.toString strictByteString



-- PURPOSE:
--   Per [1], uses the getPassword function of the Haskeline package
--   to read sensitive information from the command line.  As mentioned
--   in [1], the getPassword takes a character as a parmeter that will
--   be used to display inplace of the password characters.  The
--   getPassword form Haskeline is useful if you want to obscure the
--   typed in text from shoulder surfers
--
-- RETURNS:
--   An IO String action representing the sensitive information.
--   In many cases this will just be a password string
getSecret :: IO String
getSecret = do
  theSecret <- runInputT defaultSettings (getPassword (Just '*') "pass:")
  return (fromJust theSecret)



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
  putStrLn "i - Initialize";
  putStrLn "n - New Password Mode";
  putStrLn "g - Get Password Mode";
  putStrLn "x - Exit";

runMainMenu :: String -> IO ()
runMainMenu inMemoryDecripKey = do
  showMainMenu;
  menuChoice <- getLine     -- GetChar was leaving junk at the end
  if menuChoice == "x" then
    putStrLn "Terminating"
  else if menuChoice == "i" then do
    putStrLn "WARNING!!! - This will erase any old data"
    putStrLn "   You may want to backup this directory with a suitable"
    putStrLn "   third party encryption routine before continuing..."
    putStrLn ""
    putStrLn "   Do you want to continue (y/n)?"
    yesNo <- getLine
    if yesNo == "y" then do
       passPhrase <- getUpdatedPassPhrase
         "" passPhraseIsValid "Enter Passphrase (4-16 alphanumeric chars):"
       let passPhraseLen = Prelude.length(passPhrase)
       let keyFromFileLen = cryptoKeyLength - passPhraseLen
       fileKey <- generateNewFileKey keyFromFileLen
       keyFileH <- openFile extraKeyFile WriteMode
       hPutStrLn keyFileH fileKey
       hClose keyFileH

       -- erase the old PasswordFile
       passFileH <- openFile thePasswordFile WriteMode
       hPutStrLn passFileH ""
       hClose passFileH
       runMainMenu passPhrase
    else do
       putStrLn "aborting..."
       runMainMenu ""
  else if menuChoice == "n" then do
    passPhrase <- getUpdatedPassPhrase
      inMemoryDecripKey passPhraseIsValid "Enter Passphrase:"
    theHandle <- openFile extraKeyFile ReadMode
    theLine <- hGetLine theHandle
    hClose theHandle
    let tKey = getTotalKey passPhrase theLine
    putStrLn "Enter Description Identifier:"
    theDescription <- getLine
    putStrLn "Enter Password:"
    sPass <- getSecret

    -- You can see [3] and [4] for how to convert a string into a
    -- Lazy ByteString
    let blPass = stringToLazyByteString sPass
    let bTkey = UTF8.fromString tKey
    encryptedPassword <- encryptMsg CBC bTkey blPass
    let encodedEncryptedPassword = B64L.encode encryptedPassword
    let decryptedPassword = decryptMsg CBC bTkey encryptedPassword
    writePass theDescription encodedEncryptedPassword
    runMainMenu passPhrase
  else if menuChoice == "g" then do
    passPhrase <- getUpdatedPassPhrase
      inMemoryDecripKey passPhraseIsValid "Enter Passphrase:"
    theHandle <- openFile extraKeyFile ReadMode
    theLine <- hGetLine theHandle
    hClose theHandle
    let tKey = getTotalKey passPhrase theLine
    let bTkey = UTF8.fromString tKey
    putStrLn "Enter Description Identifier:"
    theDescription <- getLine
    theEncryptedPass <- getPasswordFromSAPU tKey theDescription

    -- Converting a String to a ByteString according to [3]
    let bEncodedEncryptedPass = UTF8.fromString theEncryptedPass
    let bEncryptedPass = B64.decodeLenient bEncodedEncryptedPass
    let lbsEncryptedPass = LChar8.fromStrict bEncryptedPass;
    let decryptedPassword = decryptMsg CBC bTkey lbsEncryptedPass;

    -- In the future, the user might be given the option to choose
    -- whether she or he wants to print the password to the console
    -- or copy it to the clipboard, but right now just copy it to
    -- the clipboard
    -- LChar8.putStrLn decryptedPassword
    let sDecryptedPassword = lazyByteStringToString decryptedPassword
    setClipboardString sDecryptedPassword
    runMainMenu passPhrase
  else
    runMainMenu inMemoryDecripKey

main :: IO ()
main = do
  -- The inMemory Crypto Key is passed recursively on the Stack to
  -- main menu to preserve its state.  When this program is first
  -- started, that value has not been specified so we pass in ""
  runMainMenu "";
