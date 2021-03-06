kgrader
=======

__kgrader__ is a code autograder, originally created by the course staff of
[CS 296-41](https://cs.illinois.edu/courses/profile/CS296) (Systems Programming
Honors) at the University of Illinois to grade student homework submissions.

It is written in Ruby.

Installation
------------

kgrader was developed using Ruby 2.2, though it should work with any recent
version of Ruby.

Install dependencies with gem:

    gem install nokogiri ruby-progressbar

Download kgrader over git:

    git clone https://github.com/earwig/kgrader.git kgrader
    cd kgrader

If you want to use UIUC-specific assignment specifications (requires special
permissions, but you have those if you want to grade our assignments, right?):

    git submodule update --init

Usage
-----

kgrader uses rake as its command-line interface.

### Setup

To show all known classes, semesters, and assignments:

    rake list

To load a roster (a newline-delimited list of student identifiers) for the
current semester of a particular course (e.g. "cs123"):

    rake roster cs123 myroster.csv

You can also specify the semester:

    rake roster cs123 myroster.csv sp16

### Grading

To grade a particular assignment (e.g., "mp1" for "cs123"):

    rake grade cs123 mp1

After verifying that everything looks good, push the grade reports with:

    rake commit cs123 mp1

### Housekeeping

To do some basic cleanup (i.e., trash uncommitted grading attempts, or reset
messy internal state after a bad run):

    rake clean

To restore kgrader to its "factory defaults" (i.e., everything `clean` does,
but also delete checked-out student repos and roster files -- dangerous!):

    rake clobber

### Advanced

`grade` has an extended syntax for different options.

To specify the semester, instead of the inferred current one:

    rake grade cs123 mp1 semester=sp16

To set a cutoff date after which commits will be ignored:

    rake grade cs123 mp1 due="March 20, 2016 11:59:59 PM CDT"

To grade without fetching new student repo changes:

    rake grade cs123 mp1 fetch=no

To grade specific students only:

    rake grade cs123 mp1 students=ksmith12
    rake grade cs123 mp1 students=ksmith12,bcooper3,mjones14

Normally, kgrader will only regrade a particular student's assignment if their
repo has changed since the last run. To forcibly regrade:

    rake grade cs123 mp1 regrade=yes

You can enable superscoring as well, which will re-run tests that a student
failed in an attempt to see if they can get a higher grade:

    rake grade cs123 mp1 superscore=yes

You can combine these arguments in any meaningful way. `semester` and
`students` are also available options for `commit`.
