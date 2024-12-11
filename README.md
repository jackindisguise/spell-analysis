[comment]: # (All my badges and shit go here.)
<div align='center'>

![GitHub package.json version](https://img.shields.io/github/package-json/v/jackindisguise/spell-analysis?style=for-the-badge&logo=npm)

[![Static Badge](https://img.shields.io/badge/GitHub-black?style=for-the-badge&logo=github)](https://github.com/jackindisguise/spell-analysis)

</div>

[comment]: # (Place-holder logo.)
<p align='center'><img src='https://raw.githubusercontent.com/jackindisguise/spell-analysis/main/logo.png'/></p>

# About
A simple WoW addon that adds analysis to spell tooltips.

# Notes
Due to the way I have everything compartmentalized, the source spell handler will do all of the math ahead of time to provide to the mana analyzer, and then it'll
re-do that math in all of the various `AnalyzeDamage...` functions. This is obviously silly, but it makes it a lot easier to work with.

I'm not sure how I'll fix this, but my guess is I'll remove all the math from those functions, push all of it to a separate function that returns all of the results, and then I'll provide all that data to each function individually.

In fact, using tables, this should be pretty easy. Just make a function that analyzes EVERY single potential element of the spell that we're interested in for every function, throw it in a table, and return that table. Then send that table to any of the Analyze functions.