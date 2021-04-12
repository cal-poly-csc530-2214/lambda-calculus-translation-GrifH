# lambda-calculus-translation-GrifH
lambda-calculus-translation-grifh created by GitHub Classroom

For assignment 2, I started with the basic format and structures from my assignment 2 from csc 430, one of the last classes I took in person over a year ago!

The critical functions in my assignment are parse and interp. Parse takes a S expression and tries to match it to one of the structs I have defined to match our LC language 
grammar, or throws an error if it is unable to figure out which one. The output from parse is fed directly into interp, which converts it to a viable python string, also using 
match. In terms of implementing the LC language, it was the largely trivial task of making sure the grammar was correct, and that a few more complex programs still came out ok. 
Probably the biggest question I faced was how to handle applications of functions, as with lambda functions it can be a little tricky t wrap your head around. I was tempted to 
demand a lamC when parsing for an application, but was able to leave it open so someone could have a more complex program that returns a lambda at some point in the function 
application spot. Another issue was if statements, although I ultimately just made it spit out one line if statements, although that feels kind of lame.

I connect parse to interp with two overarching functions. The first is top-interp. This takes an S expression intending to be a single LC program, though it could be very 
complicated with lots of nesting stuff. For writing longer programs, the interp-script function takes what should be a list of LC programs, parses and interps each one 
individually, then prints each one out on its own line. The output of interp-script can be pasted straight into a python script and will run, from what I have tested at least. 
To enhance that experience, I also added a variable assignment option to the LC language. (= id LC) converts to the python statement id = LC, so with interp-script at least 
readability can be improved.

I would assume that there is some combos of LC that create some syntax errors in python, although I haven't seen them. This assigment had scared me quite a bit initially, but it
turns out not having to interp LC makes things a whole lot easier.
