pwd
===
A rewrite of the POSIX pwd program in x86 Assembly, it's 98.6% smaller than GNU's implementation (31472 bytes vs 436 bytes). It takes the arguments -L and -P, 
though anything that's not -P will be treated as an -L, as will no arguments at all. It will always take the final argument as the indicator as to how it will 
behave.
