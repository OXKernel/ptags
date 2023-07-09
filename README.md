# ptags
Perl tags generator for VIM

# REFERENCES

https://perlmaven.com/traversing-a-directory-tree-finding-required-files

https://www.perl.com/article/21/2013/4/21/Read-an-entire-file-into-a-string

https://perldoc.perl.org/Cwd.html

https://fresh2refresh.com/c-programming/c-tokens-identifiers-keywords

https://rosettacode.org/wiki/Special\_characters

https://stackoverflow.com/questions/850907/regular-expression-opposite

https://perldoc.perl.org/perlrequick.html

https://stackoverflow.com/questions/14699822/perl-exact-string-match

https://stackoverflow.com/questions/25391079/perl-search-for-string-and-get-the-full-line-from-text-file

https://metacpan.org/pod/distribution/Regexp-Common/lib/Regexp/Common/comment.pm

https://en.cppreference.com/w/cpp/keyword

https://stackoverflow.com/questions/13479198/sort-2nd-field-descending-from-text-file-perl

https://perldoc.perl.org/functions/sort.html

https://perldoc.perl.org/functions/exists.html

https://www.tutorialspoint.com/perl/perl\_regular\_expressions.htm

# LANGUAGE REFERENCES

https://www.w3schools.in/python-tutorial/keywords/

https://www.w3schools.in/javascript-tutorial/keywords/

https://learn.perl.org/docs/keywords.html

https://www.ruby-forum.com/t/listing-ruby-keywords/55731/2

https://corlewsolutions.com/articles/article-7-finding-reserved-words-or-keywords-in-ruby

https://beginnersbook.com/2017/12/kotlin-keywords-identifiers/

https://www.geeksforgeeks.org/go-keywords/

https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/keywords/

https://www.tutorialkart.com/swift-tutorial/swift-keywords/

https://www.php.net/manual/en/reserved.keywords.php

https://programmingpot.com/php-programming/list-of-php-keywords/

# Tag file format:

## tagname<tab>file<tab>lineno
## tagname<tab>file<tab>/pattern/ \# --> (This is the one we actually use) <--

# Add generated tag file to VIM using:

## :set tags=tags\_file \# set the tags file
## :set tags+=tags\_file \# append to list of existing tags

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

## Ctrl ] (jump to tag) if more than one match, type in number for selecting from 
##        multiple matches
## Ctrl T return back to previous tag
## :pop previous
## :tag go back to tag match

## Can also give number like :5tag

