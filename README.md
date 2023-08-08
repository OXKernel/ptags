# ptags
Perl tags generator for VIM

# Usage
ptags.pl path tags_file [--exclude pattern] [--lang] (where lang is --C, --Java, --Python, --JS, --Perl, --Ruby, --Kotlin, --Go, --CS, --Swift, --PHP)

# Tag file format:

tagname\<tab\>file\<tab\>/pattern/

# Add generated tag file to VIM using:

:set tags=tags\_file \# set the tags file

:set tags+=tags\_file \# append to list of existing tags

# Current languages supported:

## c/c++,java,python,javascript,perl,ruby,kotlin,go,c#,swift,php

# Support for other languages:

This requires adding a check for the filetype, removing comments,
stripping out string literals. Most importantly, it should filter out
the language's keywords. 

The identifier split should be the same (I believe) and the unique symbol 
check and sort should be the same. However, its better to output to different
tag files symbols of different languages.

# Tags use in VIM:

## Ctrl ] 
(jump to tag) if more than one match, type in number for selecting from multiple matches

## Ctrl T 
return back to previous tag

## :pop previous

## :tag 
go back to tag match
Can also give number like :5tag

# Author
Roger Doss

opensource [at] rdoss [dot] com
