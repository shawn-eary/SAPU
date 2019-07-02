# SAPU
SAPU - Shawn's Aweful Password Utility

This is an incredibly hideuous but partially working command line
password manager written in Haskell.  Do *NOT* use this password
manager.  It does partially work, but your passwords are too valuable
to trust to a flaky piece of junk password manager written by some
bloke that likes to pop wheelies, watch GCN and ride two hundred miles
on gravel in his free time...

Seriously, I'm planning on fixing these bugs over time, but right now
I consider this code more a "work of art" than a functional piece of
useable software.  Hence my choice of Haskell rather than any run 
of the mill language.  Haskell *is* very functional (pun intended)
but my Haskell skills are crude and I need to spend more time on this
project.  

In the case of this code, Haskell was mainly chosen for
aesthetic reasons.  While I do not like the name of the Haskell 
package manager "cabal", I personally feel Haskell is the most 
beautiful programming language ever written.  The code here in this
project is almost an embarsement to the beauty of Haskell, but I 
feel humbled by the freedom to write code is such an elegant 
language.  

Now, to more practical considerations:
1) Various Haskell packages were used to build this code.  If 
I remember correctly they are: clipboard, haskeline, split and
SimpleAES

2) To compile you will need to so something like this:
cabal install clipboard
cabal install haskeline
cabal install split
cabal install [otherStuffI_MayHaveForgot]
ghc sapu.hs

3) I was planning on using the clipboard to keep the passwords
from prying eyes but I haven't gotten that far yet.  It's an 
easy modification but I just haven't gotten around to it.

4) When you first run the utility you will need to set an
inMemory Crypto Key.  That's option "s" from the main menu.
The inMemory Crypto Key will be concatated with a key stored
in extraKeyFile.  The total lenght of the concatenation should
be exactly 32 characters at this time.  It it isn't, this 
program will crash.

5) Each time you run this program, you should use the same 
inMemory Crypto Key and Key from the extraKeyFile otherwise
the program will likely crash on you and if it doesn't you're
going to get very strange results

6) The is presently no way to change the keys used for a
samplePassFile once it is created.  If you feel you are using
bad keys (or your keys have been comprimised) then you will
need to recreate your samplePassFile from scratch.  If you 
have large file, that will be a royal pain...

######################################################
# You have been warned.                              #
#                                                    #
# DO *NOT* USE Shawn's Aweful Password Utility       #
# One the other hand if you daydream about Haskell   #
# and how it can make the world a better place, you  #
# are welcome to browse around                       #
######################################################

NOTE: This README File will likely contain huge inaccuracies
and probably won't keep pace with development.  I don't 
have a lot of time on my hands but I'm planning on looking
at this code again in the next few weeks.
