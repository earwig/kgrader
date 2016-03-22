kgrader
=======

__kgrader__ is a code autograder, originally created by the course staff of
[CS 296-41](https://cs.illinois.edu/courses/profile/CS296) (Systems Programming
Honors) at the University of Illinois to grade student homework submissions.

It is written in Ruby.

Installation
------------

Download kgrader over git:

    git clone https://github.com/earwig/kgrader.git kgrader
    cd kgrader

If you want to use UIUC-specific assignment specifications (requires special
permissions, but you have those if you want to grade our assignments, right?):

    git submodule update --init

Usage
-----

kgrader uses rake as its command-line interface.

To do some basic housekeeping:

    rake clean

To restore kgrader to its factory defaults (i.e., delete checked-out student
repos and any uncommitted grading attempts):

    rake clobber
