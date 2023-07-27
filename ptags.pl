#!/usr/bin/perl
#
# Copyright (C) 2023. Roger Doss. All Rights Reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# REFERENCES
#
# https://perlmaven.com/traversing-a-directory-tree-finding-required-files
# https://www.perl.com/article/21/2013/4/21/Read-an-entire-file-into-a-string
# https://perldoc.perl.org/Cwd.html
# https://fresh2refresh.com/c-programming/c-tokens-identifiers-keywords
# https://rosettacode.org/wiki/Special_characters
# https://stackoverflow.com/questions/850907/regular-expression-opposite
# https://perldoc.perl.org/perlrequick.html
# https://stackoverflow.com/questions/14699822/perl-exact-string-match
# https://stackoverflow.com/questions/25391079/perl-search-for-string-and-get-the-full-line-from-text-file
# https://metacpan.org/pod/distribution/Regexp-Common/lib/Regexp/Common/comment.pm
# https://en.cppreference.com/w/cpp/keyword
# https://stackoverflow.com/questions/13479198/sort-2nd-field-descending-from-text-file-perl
# https://perldoc.perl.org/functions/sort.html
# https://perldoc.perl.org/functions/exists.html
# https://www.tutorialspoint.com/perl/perl_regular_expressions.htm
#
# LANGUAGE REFERENCES
#
# https://www.w3schools.in/python-tutorial/keywords/
# https://www.w3schools.in/javascript-tutorial/keywords/
# https://learn.perl.org/docs/keywords.html
# https://www.ruby-forum.com/t/listing-ruby-keywords/55731/2
# https://corlewsolutions.com/articles/article-7-finding-reserved-words-or-keywords-in-ruby
# https://beginnersbook.com/2017/12/kotlin-keywords-identifiers/
# https://www.geeksforgeeks.org/go-keywords/
# https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/keywords/
# https://www.tutorialkart.com/swift-tutorial/swift-keywords/
# https://www.php.net/manual/en/reserved.keywords.php
# https://programmingpot.com/php-programming/list-of-php-keywords/
#
# Tag file format:
#
# tagname<tab>file<tab>lineno
# tagname<tab>file<tab>/pattern/ # --> (This is the one we actually use) <--
#
# Add generated tag file to VIM using:
#
# :set tags=tags_file # set the tags file
# :set tags+=tags_file # append to list of existing tags
#
# Current languages supported:
#
# c/c++,java,python,javascript,perl,ruby,kotlin,go,c#,swift,php
#
# Support for other languages:
#
# This requires adding a check for the filetype, removing comments,
# stripping out string literals. Most importantly, it should filter out
# the language's keywords. 
#
# The identifier split should be the same (I believe) and the unique symbol 
# check and sort should be the same. However, its better to output to different
# tag files symbols of different languages.
#
# Tags use in VIM:
#
# Ctrl ] (jump to tag) if more than one match, type in number for selecting from 
#        multiple matches
# Ctrl T return back to previous tag
# :pop previous
# :tag go back to tag match
#
# Can also give number like :5tag
#
# AUTHOR
#
# Roger Doss
#
use strict;
use warnings;
 
use File::Find::Rule;
use File::Slurp;
use File::Basename qw(basename);
use Regexp::Common qw /comment/;
use Regexp::Common qw /delimited/;
use Cwd 'abs_path';
 
sub getLine {
  my $file_content = shift;
  my $id = shift;
  if($file_content =~ /(.{0,100}\W$id\W.{0,100})/) { # match up to 100 characters leading/trailing --grep
  #if($file_content =~ /(\n.*$id.*\n)/) { # match whole line --verbose
    my $result=$1;
    #chomp $result;
    $result =~ s/\n//g;
    $result =~ s/\\/\\\\/g; # Excape special characters.
    $result =~ s/\//\\\//g; # Excape special characters.
    return $result;
  }
}

my $exclude = "";
my $lang = "--C"; # Default is C/C++

if ( $#ARGV != 1 ) {
  if( $#ARGV == 2 ) {
    $lang = $ARGV[2];
  }
  elsif( $#ARGV == 3 ) {
    if($ARGV[2] eq "--exclude") {
      $exclude = $ARGV[3];
    } else {
      print "ptags::  syntax path tags_file [--exclude pattern] [--lang] (where lang is --C, --Java, --Python, --JS, --Perl, --Ruby, --Kotlin, --Go, --CS, --Swift, --PHP) arguments received $#ARGV\n";
      exit(1);
    }
  }
  elsif( $#ARGV == 4 ) {
    if($ARGV[2] eq "--exclude") {
      $exclude = $ARGV[3];
      $lang = $ARGV[4];
    } elsif($ARGV[3] eq "--exclude") {
      $exclude = $ARGV[4];
      $lang = $ARGV[2];
    } else {
      print "ptags::  syntax path tags_file [--exclude pattern] [--lang] (where lang is --C, --Java, --Python, --JS, --Perl, --Ruby, --Kotlin, --Go, --CS, --Swift, --PHP) arguments received $#ARGV\n";
    exit(1);
    }
  } else {
    print "ptags::  syntax path tags_file [--exclude pattern] [--lang] (where lang is --C, --Java, --Python, --JS, --Perl, --Ruby, --Kotlin, --Go, --CS, --Swift, --PHP) arguments received $#ARGV\n";
    exit(1);
  }
}

my $path = $ARGV[0];
my $report = $ARGV[1];

#if ( $#ARGV == 4 ) {
#  $exclude = $ARGV[3];
#}

if($lang eq "--C") {
  $report .= ".C";
} elsif($lang eq "--Java") {
  $report .= ".java";
} elsif($lang eq "--Python") {
  $report .= ".py";
} elsif($lang eq "--JS") {
  $report .= ".js";
} elsif($lang eq "--Perl") {
  $report .= ".pl";
} elsif($lang eq "--Ruby") {
  $report .= ".rb";
} elsif($lang eq "--Kotlin") {
  $report .= ".kt";
} elsif($lang eq "--Go") {
  $report .= ".go";
} elsif($lang eq "--CS") {
  $report .= ".cs";
} elsif($lang eq "--Swift") {
  $report .= ".swift";
} elsif($lang eq "--PHP") {
  $report .= ".php";
} else {
  print "unsupported language $lang\n";
  exit(2);
}

open(my $out, '>', $report) or die "Could not open '$report' $!\n";

my @files = File::Find::Rule->file->name('*.*')->in($path);
 
my %uniq;
my @tags_file_temp;

# Generate tags file...
#print "$#files\n";
for(my $i = 0; $i <= $#files; $i++) {
  my $filen = abs_path($files[$i]);
  print "$filen\n";
  if ( length($exclude) > 0 and $filen =~ $exclude ) {
    print "skipping: $filen\n";
    next;
  }
  my @suffix = split /\./, $files[$i];
  #print "$suffix[1]\n";
  if($suffix[1] =~ /^(c|cc|cpp|cxx|h|hpp|hxx)$/i and $lang eq "--C") { # Accepted filetypes (C/C++)
    #print "ptags:: scanning $filen\n";
    my $file_content = read_file($filen); 
    my $orig_content = $file_content;
    # Strip out newlines
    $file_content =~ s/\n/ /g;
    # Strip out comments
    $file_content =~ s/$RE{comment}{'Perl'}//g; # To remove preprocessor directives
    $file_content =~ s/$RE{comment}{'C'}//g;
    $file_content =~ s/$RE{comment}{'C++'}//g;
    # Strip out string literals
    $file_content =~ s/$RE{delimited}{-delim=>'"'}//g;
    $file_content =~ s/$RE{delimited}{-delim=>'\''}//g;
    #$file_content =~ s/\'.*\'|\".*\"//g;
    #print $file_content;
    my @identifiers = split /[^\w]/, $file_content; # Split on anything thats not a word
    #my @identifiers = split /^[A-Za-z_][A-Za-z0-9_]*/, $file_content;
    #my @identifiers = split / /, $file_content;
    for(my $j = 0; $j <= $#identifiers; $j++) {
      if($identifiers[$j] =~ /\d/) {
        #print "found number $identifiers[$j]\n";
      } elsif($identifiers[$j] =~ /^(auto|double|int|struct|const|float|short|unsigned|break|else|long|switch|continue|for|signed|void|case|enum|register|typedef|default|goto|sizeof|volatile|char|extern|return|do|if|static|while|include|define|using|namespace|union|true|false)$/) {
        #print "found C keyword $identifiers[$j]\n";
      } elsif($identifiers[$j] =~ /^(alignas|alignof|and|and_eq|asm|atomic_cancel|atomic_commit|atomic_noexcept|auto|bitand|bitor|bool|break|case|catch|char|char8_t|char16_t|char32_t|class|compl|concept|const|consteval|constexpr|constinit|const_cast|continue|co_await|co_return|co_yield|decltype|default|delete|do|double|dynamic_cast|else|enum|explicit|export|extern|false|float|for|friend|goto|if|inline|int|long|mutable|namespace|new|noexcept|not|not_eq|nullptr|operator|or|or_eq|private|protected|public|reflexpr|register|reinterpret_cast|requires|return|short|signed|sizeof|static|static_assert|static_cast|struct|switch|synchronized|template|this|thread_local|throw|true|try|typedef|typeid|typename|union|unsigned|using|virtual|void|volatile|wchar_t|while|xor|xor_eq|and|bitor|or|xor|compl|bitand|and_eq|or_eq|xor_eq|not|and|not_eq|override|final|import|module|transaction_safe|transaction_safe_dynamic|elif|endif|ifdef|ifndef|define|undef|include|line|error|pragma|defined|__has_include|__has_cpp_attribute)$/) {
        #print "found C++ keyword $identifiers[$j]\n";
      } elsif(length($identifiers[$j]) > 0) {
        #print "found identifier $identifiers[$j]\n";
        #print "adding tag entry\n";
        # Tag format
        # identifier<tab>file<tab>excommand<newline>
        #print $out "$identifiers[$j]\t$filen\t/$identifiers[$j]/\n";
        # Remove duplicates
        if(not exists $uniq{"$identifiers[$j]\t$filen"}) {
          $uniq{"$identifiers[$j]\t$filen"}=1;
          my @row;
          push @row, $identifiers[$j];
          push @row, $filen;
          push @row, getLine($orig_content, $identifiers[$j]);
          push @tags_file_temp, \@row; # Array ref
        }
      }
    }
  }
  if($suffix[1] =~ /^(java)$/i and $lang eq "--Java") { # Accepted filetypes (Java)
    #print "ptags:: scanning $filen\n";
    my $file_content = read_file($filen); 
    my $orig_content = $file_content;
    # Strip out newlines
    $file_content =~ s/\n/ /g;
    # Strip out comments
    $file_content =~ s/$RE{comment}{'C'}//g;
    $file_content =~ s/$RE{comment}{'C++'}//g;
    # Strip out string literals
    $file_content =~ s/$RE{delimited}{-delim=>'"'}//g;
    $file_content =~ s/$RE{delimited}{-delim=>'\''}//g;
    #$file_content =~ s/\'.*\'|\".*\"//g;
    #print $file_content;
    my @identifiers = split /[^\w]/, $file_content; # Split on anything thats not a word
    #my @identifiers = split /^[A-Za-z_][A-Za-z0-9_]*/, $file_content;
    #my @identifiers = split / /, $file_content;
    for(my $j = 0; $j <= $#identifiers; $j++) {
      if($identifiers[$j] =~ /\d/) {
        #print "found number $identifiers[$j]\n";
      } elsif($identifiers[$j] =~ /^(abstract|assert|boolean|break|byte|case|catch|char|class|const|continue|default|do|double|else|enum|extends|final|finally|float|for|goto|if|implements|import|instanceof|int|interface|long|native|new|package|private|protected|public|return|short|static|strictfp|super|switch|synchronized|this|throw|throws|transient|try|void|volatile|while|true|false|null)$/) {
        #print "found C++ keyword $identifiers[$j]\n";
      } elsif(length($identifiers[$j]) > 0) {
        #print "found identifier $identifiers[$j]\n";
        #print "adding tag entry\n";
        # Tag format
        # identifier<tab>file<tab>excommand<newline>
        #print $out "$identifiers[$j]\t$filen\t/$identifiers[$j]/\n";
        # Remove duplicates
        if(not exists $uniq{"$identifiers[$j]\t$filen"}) {
          $uniq{"$identifiers[$j]\t$filen"}=1;
          my @row;
          push @row, $identifiers[$j];
          push @row, $filen;
          push @row, getLine($orig_content, $identifiers[$j]);
          push @tags_file_temp, \@row; # Array ref
        }
      }
    }
  }
  if($suffix[1] =~ /^(py)$/i  and $lang eq "--Python") { # Accepted filetypes (Java)
    #print "ptags:: scanning $filen\n";
    my $file_content = read_file($filen); 
    my $orig_content = $file_content;
    # Strip out newlines
    $file_content =~ s/\n/ /g;
    # Strip out comments
    $file_content =~ s/$RE{comment}{'Python'}//g;
    # Strip out string literals
    $file_content =~ s/$RE{delimited}{-delim=>'"'}//g;
    $file_content =~ s/$RE{delimited}{-delim=>'\''}//g;
    #$file_content =~ s/\'.*\'|\".*\"//g;
    #print $file_content;
    my @identifiers = split /[^\w]/, $file_content; # Split on anything thats not a word
    #my @identifiers = split /^[A-Za-z_][A-Za-z0-9_]*/, $file_content;
    #my @identifiers = split / /, $file_content;
    for(my $j = 0; $j <= $#identifiers; $j++) {
      if($identifiers[$j] =~ /\d/) {
        #print "found number $identifiers[$j]\n";
      } elsif($identifiers[$j] =~ /^(and|assert|in|del|else|raise|from|if|continue|not|pass|finally|while|yield|is|as|break|return|elif|except|def|global|import|for|or|print|lambda|with|class|try|exec)$/) {
        #print "found C++ keyword $identifiers[$j]\n";
      } elsif(length($identifiers[$j]) > 0) {
        #print "found identifier $identifiers[$j]\n";
        #print "adding tag entry\n";
        # Tag format
        # identifier<tab>file<tab>excommand<newline>
        #print $out "$identifiers[$j]\t$filen\t/$identifiers[$j]/\n";
        # Remove duplicates
        if(not exists $uniq{"$identifiers[$j]\t$filen"}) {
          $uniq{"$identifiers[$j]\t$filen"}=1;
          my @row;
          push @row, $identifiers[$j];
          push @row, $filen;
          push @row, getLine($orig_content, $identifiers[$j]);
          push @tags_file_temp, \@row; # Array ref
        }
      }
    }
  }
  if($suffix[1] =~ /^(js|jsx|ts|tsx)$/i and $lang eq "--JS") { # Accepted filetypes (Java)
    #print "ptags:: scanning $filen\n";
    my $file_content = read_file($filen); 
    my $orig_content = $file_content;
    # Strip out newlines
    $file_content =~ s/\n/ /g;
    # Strip out comments
    $file_content =~ s/$RE{comment}{'C'}//g;
    $file_content =~ s/$RE{comment}{'C++'}//g;
    # Strip out string literals
    $file_content =~ s/$RE{delimited}{-delim=>'"'}//g;
    $file_content =~ s/$RE{delimited}{-delim=>'\''}//g;
    #$file_content =~ s/\'.*\'|\".*\"//g;
    #print $file_content;
    my @identifiers = split /[^\w]/, $file_content; # Split on anything thats not a word
    #my @identifiers = split /^[A-Za-z_][A-Za-z0-9_]*/, $file_content;
    #my @identifiers = split / /, $file_content;
    for(my $j = 0; $j <= $#identifiers; $j++) {
      #print("found [$identifiers[$j]]\n");
      if($identifiers[$j] =~ /\d/) {
        #print "found number $identifiers[$j]\n";
      } elsif($identifiers[$j] =~ /^(abstract|arguments|boolean|break|byte|case|catch|char|const|continue|debugger|default|delete|do|double|else|eval|false|final|finally|float|for|function|goto|if|implements|in|instanceof|int|interface|let|long|native|new|null|package|private|protected|public|return|short|static|switch|synchronized|this|throw|throws|transient|true|try|typeof|var|void|volatile|while|with|yield|class|enum|export|extends|import|super)$/) {
        #print "found C++ keyword $identifiers[$j]\n";
      } elsif(length($identifiers[$j]) > 0) {
        #print "found identifier $identifiers[$j]\n";
        #print "adding tag entry\n";
        # Tag format
        # identifier<tab>file<tab>excommand<newline>
        #print $out "$identifiers[$j]\t$filen\t/$identifiers[$j]/\n";
        # Remove duplicates
        if(not exists $uniq{"$identifiers[$j]\t$filen"}) {
          $uniq{"$identifiers[$j]\t$filen"}=1;
          my @row;
          push @row, $identifiers[$j];
          push @row, $filen;
          push @row, getLine($orig_content, $identifiers[$j]);
          push @tags_file_temp, \@row; # Array ref
        }
      }
    }
  }
  if($suffix[1] =~ /^(pl)$/i and $lang eq "--Perl") { # Accepted filetypes (Java)
    #print "ptags:: scanning $filen\n";
    my $file_content = read_file($filen); 
    my $orig_content = $file_content;
    # Strip out newlines
    $file_content =~ s/\n/ /g;
    # Strip out comments
    $file_content =~ s/$RE{comment}{'Perl'}//g;
    # Strip out string literals
    $file_content =~ s/$RE{delimited}{-delim=>'"'}//g;
    $file_content =~ s/$RE{delimited}{-delim=>'\''}//g;
    #$file_content =~ s/\'.*\'|\".*\"//g;
    #print $file_content;
    my @identifiers = split /[^\w]/, $file_content; # Split on anything thats not a word
    #my @identifiers = split /^[A-Za-z_][A-Za-z0-9_]*/, $file_content;
    #my @identifiers = split / /, $file_content;
    for(my $j = 0; $j <= $#identifiers; $j++) {
      if($identifiers[$j] =~ /\d/) {
        #print "found number $identifiers[$j]\n";
      } elsif($identifiers[$j] =~ /^(__DATA__|else|lock|qw|__END__|elsif|lt|qx|__FILE__|eq|m|s|__LINE__|exp|ne|sub|__PACKAGE__|for|no|tr|and|foreach|or|unless|cmp|ge|package|until|continue|gt|q|while|CORE|if|qq|xor|do|le|qr|y|goto|last|next|return|shift)$/) {
        #print "found C++ keyword $identifiers[$j]\n";
      } elsif(length($identifiers[$j]) > 0) {
        #print "found identifier $identifiers[$j]\n";
        #print "adding tag entry\n";
        # Tag format
        # identifier<tab>file<tab>excommand<newline>
        #print $out "$identifiers[$j]\t$filen\t/$identifiers[$j]/\n";
        # Remove duplicates
        if(not exists $uniq{"$identifiers[$j]\t$filen"}) {
          $uniq{"$identifiers[$j]\t$filen"}=1;
          my @row;
          push @row, $identifiers[$j];
          push @row, $filen;
          push @row, getLine($orig_content, $identifiers[$j]);
          push @tags_file_temp, \@row; # Array ref
        }
      }
    }
  }
  if($suffix[1] =~ /^(rb)$/i and $lang eq "--Ruby") { # Accepted filetypes (Java)
    #print "ptags:: scanning $filen\n";
    my $file_content = read_file($filen); 
    my $orig_content = $file_content;
    # Strip out newlines
    $file_content =~ s/\n/ /g;
    # Strip out comments
    $file_content =~ s/$RE{comment}{'Ruby'}//g;
    # Strip out string literals
    $file_content =~ s/$RE{delimited}{-delim=>'"'}//g;
    $file_content =~ s/$RE{delimited}{-delim=>'\''}//g;
    #$file_content =~ s/\'.*\'|\".*\"//g;
    #print $file_content;
    my @identifiers = split /[^\w]/, $file_content; # Split on anything thats not a word
    #my @identifiers = split /^[A-Za-z_][A-Za-z0-9_]*/, $file_content;
    #my @identifiers = split / /, $file_content;
    for(my $j = 0; $j <= $#identifiers; $j++) {
      if($identifiers[$j] =~ /\d/) {
        #print "found number $identifiers[$j]\n";
      } elsif($identifiers[$j] =~ /^(alias|and|begin|break|case|catch|class|def|do|elsif|else|fail|ensure|for|end|if|in|module|next|not|or|raise|redo|rescue|retry|return|then|throw|super|unless|undef|until|when|while|yield|nil|self|true|false|FILE|LINE|BEGIN|END|define)$/) {
        #print "found C++ keyword $identifiers[$j]\n";
      } elsif(length($identifiers[$j]) > 0) {
        #print "found identifier $identifiers[$j]\n";
        #print "adding tag entry\n";
        # Tag format
        # identifier<tab>file<tab>excommand<newline>
        #print $out "$identifiers[$j]\t$filen\t/$identifiers[$j]/\n";
        # Remove duplicates
        if(not exists $uniq{"$identifiers[$j]\t$filen"}) {
          $uniq{"$identifiers[$j]\t$filen"}=1;
          my @row;
          push @row, $identifiers[$j];
          push @row, $filen;
          push @row, getLine($orig_content, $identifiers[$j]);
          push @tags_file_temp, \@row; # Array ref
        }
      }
    }
  }
  if($suffix[1] =~ /^(kt|kts|ktm)$/i and $lang eq "--Kotlin") { # Accepted filetypes (Kotlin)
    #print "ptags:: scanning $filen\n";
    my $file_content = read_file($filen); 
    my $orig_content = $file_content;
    # Strip out newlines
    $file_content =~ s/\n/ /g;
    # Strip out comments
    $file_content =~ s/$RE{comment}{'C'}//g;
    $file_content =~ s/$RE{comment}{'C++'}//g;
    # Strip out string literals
    $file_content =~ s/$RE{delimited}{-delim=>'"'}//g;
    $file_content =~ s/$RE{delimited}{-delim=>'\''}//g;
    #$file_content =~ s/\'.*\'|\".*\"//g;
    #print $file_content;
    my @identifiers = split /[^\w]/, $file_content; # Split on anything thats not a word
    #my @identifiers = split /^[A-Za-z_][A-Za-z0-9_]*/, $file_content;
    #my @identifiers = split / /, $file_content;
    for(my $j = 0; $j <= $#identifiers; $j++) {
      if($identifiers[$j] =~ /\d/) {
        #print "found number $identifiers[$j]\n";
      } elsif($identifiers[$j] =~ /^(as|class|break|continue|do|else|for|fun|false|if|in|interface|super|return|object|package|null|is|try|throw|true|this|typeof|typealias|when|while|val|var)$/) {
        #print "found C++ keyword $identifiers[$j]\n";
      } elsif(length($identifiers[$j]) > 0) {
        #print "found identifier $identifiers[$j]\n";
        #print "adding tag entry\n";
        # Tag format
        # identifier<tab>file<tab>excommand<newline>
        #print $out "$identifiers[$j]\t$filen\t/$identifiers[$j]/\n";
        # Remove duplicates
        if(not exists $uniq{"$identifiers[$j]\t$filen"}) {
          $uniq{"$identifiers[$j]\t$filen"}=1;
          my @row;
          push @row, $identifiers[$j];
          push @row, $filen;
          push @row, getLine($orig_content, $identifiers[$j]);
          push @tags_file_temp, \@row; # Array ref
        }
      }
    }
  }
  if($suffix[1] =~ /^(go)$/i and $lang eq "--Go") { # Accepted filetypes (Java)
    #print "ptags:: scanning $filen\n";
    my $file_content = read_file($filen); 
    my $orig_content = $file_content;
    # Strip out newlines
    $file_content =~ s/\n/ /g;
    # Strip out comments
    $file_content =~ s/$RE{comment}{'C'}//g;
    $file_content =~ s/$RE{comment}{'C++'}//g;
    # Strip out string literals
    $file_content =~ s/$RE{delimited}{-delim=>'"'}//g;
    $file_content =~ s/$RE{delimited}{-delim=>'\''}//g;
    #$file_content =~ s/\'.*\'|\".*\"//g;
    #print $file_content;
    my @identifiers = split /[^\w]/, $file_content; # Split on anything thats not a word
    #my @identifiers = split /^[A-Za-z_][A-Za-z0-9_]*/, $file_content;
    #my @identifiers = split / /, $file_content;
    for(my $j = 0; $j <= $#identifiers; $j++) {
      if($identifiers[$j] =~ /\d/) {
        #print "found number $identifiers[$j]\n";
      } elsif($identifiers[$j] =~ /^(break|case|chan|const|continue|default|defer|else|fallthrough|for|func|go|goto|if|import|interface|map|package|range|return|select|struct|switch|type|var)$/) {
        #print "found C++ keyword $identifiers[$j]\n";
      } elsif(length($identifiers[$j]) > 0) {
        #print "found identifier $identifiers[$j]\n";
        #print "adding tag entry\n";
        # Tag format
        # identifier<tab>file<tab>excommand<newline>
        #print $out "$identifiers[$j]\t$filen\t/$identifiers[$j]/\n";
        # Remove duplicates
        if(not exists $uniq{"$identifiers[$j]\t$filen"}) {
          $uniq{"$identifiers[$j]\t$filen"}=1;
          my @row;
          push @row, $identifiers[$j];
          push @row, $filen;
          push @row, getLine($orig_content, $identifiers[$j]);
          push @tags_file_temp, \@row; # Array ref
        }
      }
    }
  }
  if($suffix[1] =~ /^(cs)$/i and $lang eq "--CS") { # Accepted filetypes (Java)
    #print "ptags:: scanning $filen\n";
    my $file_content = read_file($filen); 
    my $orig_content = $file_content;
    # Strip out newlines
    $file_content =~ s/\n/ /g;
    # Strip out comments
    $file_content =~ s/$RE{comment}{'C'}//g;
    $file_content =~ s/$RE{comment}{'C++'}//g;
    # Strip out string literals
    $file_content =~ s/$RE{delimited}{-delim=>'"'}//g;
    $file_content =~ s/$RE{delimited}{-delim=>'\''}//g;
    #$file_content =~ s/\'.*\'|\".*\"//g;
    #print $file_content;
    my @identifiers = split /[^\w]/, $file_content; # Split on anything thats not a word
    #my @identifiers = split /^[A-Za-z_][A-Za-z0-9_]*/, $file_content;
    #my @identifiers = split / /, $file_content;
    for(my $j = 0; $j <= $#identifiers; $j++) {
      if($identifiers[$j] =~ /\d/) {
        #print "found number $identifiers[$j]\n";
      } elsif($identifiers[$j] =~ /^(abstract|as|base|bool|break|byte|case|catch|char|checked|class|const|continue|decimal|default|delegate|do|double|else|enum|event|explicit|extern|false|finally|fixed|float|for|foreach|goto|if|implicit|in|int|interface|internal|is|lock|long|namespace|new|null|object|operator|out|override|params|private|protected|public|readonly|ref|return|sbyte|sealed|short|sizeof|stackalloc|static|string|struct|switch|this|throw|true|try|typeof|uint|ulong|unchecked|unsafe|ushort|using|virtual|void|volatile|while|add|alias|ascending|async|await|by|descending|dynamic|equals|from|get|global|group|into|join|let|nameof|on|orderby|partial|remove|select|set|unmanaged|value|var|when|where|where|yield)$/) {
        #print "found C++ keyword $identifiers[$j]\n";
      } elsif(length($identifiers[$j]) > 0) {
        #print "found identifier $identifiers[$j]\n";
        #print "adding tag entry\n";
        # Tag format
        # identifier<tab>file<tab>excommand<newline>
        #print $out "$identifiers[$j]\t$filen\t/$identifiers[$j]/\n";
        # Remove duplicates
        if(not exists $uniq{"$identifiers[$j]\t$filen"}) {
          $uniq{"$identifiers[$j]\t$filen"}=1;
          my @row;
          push @row, $identifiers[$j];
          push @row, $filen;
          push @row, getLine($orig_content, $identifiers[$j]);
          push @tags_file_temp, \@row; # Array ref
        }
      }
    }
  }
  if($suffix[1] =~ /^(swift)$/i and $lang eq "--Swift") { # Accepted filetypes (Java)
    #print "ptags:: scanning $filen\n";
    my $file_content = read_file($filen); 
    my $orig_content = $file_content;
    # Strip out newlines
    $file_content =~ s/\n/ /g;
    # Strip out comments
    $file_content =~ s/$RE{comment}{'C'}//g;
    $file_content =~ s/$RE{comment}{'C++'}//g;
    # Strip out string literals
    $file_content =~ s/$RE{delimited}{-delim=>'"'}//g;
    $file_content =~ s/$RE{delimited}{-delim=>'\''}//g;
    #$file_content =~ s/\'.*\'|\".*\"//g;
    #print $file_content;
    my @identifiers = split /[^\w]/, $file_content; # Split on anything thats not a word
    #my @identifiers = split /^[A-Za-z_][A-Za-z0-9_]*/, $file_content;
    #my @identifiers = split / /, $file_content;
    for(my $j = 0; $j <= $#identifiers; $j++) {
      if($identifiers[$j] =~ /\d/) {
        #print "found number $identifiers[$j]\n";
      } elsif($identifiers[$j] =~ /^(Class|deinit|Enum|extension|Func|import|Init|internal|Let|operator|private|protocol|public|static|struct|subscript|typealias|var|break|case|continue|default|do|else|fallthrough|for|if|in|return|switch|where|while|as|dynamicType|false|is|nil|self|Self|super|true|_COLUMN_|_FILE_|_FUNCTION_|_LINE_|associativity|convenience|dynamic|didSet|final|get|infix|inout|lazy|left|mutating|none|nonmutating|optional|override|postfix|precedence|prefix|Protocol|required|right|set|Type|unowned|weak|willSet)$/) {
        #print "found C++ keyword $identifiers[$j]\n";
      } elsif(length($identifiers[$j]) > 0) {
        #print "found identifier $identifiers[$j]\n";
        #print "adding tag entry\n";
        # Tag format
        # identifier<tab>file<tab>excommand<newline>
        #print $out "$identifiers[$j]\t$filen\t/$identifiers[$j]/\n";
        # Remove duplicates
        if(not exists $uniq{"$identifiers[$j]\t$filen"}) {
          $uniq{"$identifiers[$j]\t$filen"}=1;
          my @row;
          push @row, $identifiers[$j];
          push @row, $filen;
          push @row, getLine($orig_content, $identifiers[$j]);
          push @tags_file_temp, \@row; # Array ref
        }
      }
    }
  }
  if($suffix[1] =~ /^(php)$/i and $lang eq "--PHP") { # Accepted filetypes (Java)
    #print "ptags:: scanning $filen\n";
    my $file_content = read_file($filen); 
    my $orig_content = $file_content;
    # Strip out newlines
    $file_content =~ s/\n/ /g;
    # Strip out comments
    $file_content =~ s/$RE{comment}{'C'}//g;
    $file_content =~ s/$RE{comment}{'C++'}//g;
    # Strip out string literals
    $file_content =~ s/$RE{delimited}{-delim=>'"'}//g;
    $file_content =~ s/$RE{delimited}{-delim=>'\''}//g;
    #$file_content =~ s/\'.*\'|\".*\"//g;
    #print $file_content;
    my @identifiers = split /[^\w]/, $file_content; # Split on anything thats not a word
    #my @identifiers = split /^[A-Za-z_][A-Za-z0-9_]*/, $file_content;
    #my @identifiers = split / /, $file_content;
    for(my $j = 0; $j <= $#identifiers; $j++) {
      if($identifiers[$j] =~ /\d/) {
        #print "found number $identifiers[$j]\n";
      } elsif($identifiers[$j] =~ /^(__halt_compiler|abstract|and|array|as|break|callable|case|catch|class|clone|const|continue|declare|default|die|do|echo|else|elseif|empty|enddeclare|endfor|endforeach|endif|endswitch|endwhile|eval|exit|extends|final|finally|fn|for|foreach|function|global|goto|if|implements|include|include_once|instanceof|insteadof|interface|isset|list|namespace|new|or|print|private|protected|public|require|require_once|return|static|switch|throw|trait|try|unset|use|var|while|xor|yield|from|__CLASS__|__DIR__|__FILE__|__FUNCTION__|__LINE__|__METHOD__|__NAMESPACE__|__TRAIT__ )$/) {
        #print "found C++ keyword $identifiers[$j]\n";
      } elsif(length($identifiers[$j]) > 0) {
        #print "found identifier $identifiers[$j]\n";
        #print "adding tag entry\n";
        # Tag format
        # identifier<tab>file<tab>excommand<newline>
        #print $out "$identifiers[$j]\t$filen\t/$identifiers[$j]/\n";
        # Remove duplicates
        if(not exists $uniq{"$identifiers[$j]\t$filen"}) {
          $uniq{"$identifiers[$j]\t$filen"}=1;
          my @row;
          push @row, $identifiers[$j];
          push @row, $filen;
          push @row, getLine($orig_content, $identifiers[$j]);
          push @tags_file_temp, \@row; # Array ref
        }
      }
    }
  }
}

# Sort the file based on identifers, since VIM does a binary search on the tags file.
my @tags_file = sort { $a->[0] cmp $b->[0] } @tags_file_temp; # Sort strings in ascending order on first row element
# Dump the sorted tags file.
for(my $i=0; $i <= $#tags_file; $i++) {
  my @row= @{$tags_file[$i]}; # Dereference array ref into array
  print $out "$row[0]\t$row[1]\t/$row[2]/\n";
}
close $out;
