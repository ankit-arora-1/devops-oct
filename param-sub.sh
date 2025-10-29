#!/bin/bash
# parameter_basics.sh

filename="document.backup.tar.gz"

# 1. Get string length
echo ${#filename}  # Output: 23

# 2. Default values
echo ${undefined_var:-"default value"}     # Use default if unset
echo ${undefined_var:="assigned default"}  # Assign default if unset
echo ${undefined_var:?"Error: variable required"}  # Error if unset

# 3. Remove shortest match from end (%)
echo ${filename%.*}           # document.backup.tar
echo ${filename%.gz}          # document.backup.tar

# 4. Remove longest match from end (%%)
echo ${filename%%.*}          # document

# 5. Remove shortest match from beginning (#)
echo ${filename#*.}           # backup.tar.gz
echo ${filename#document.}    # backup.tar.gz

# 6. Remove longest match from beginning (##)
echo ${filename##*.}          # gz
echo ${filename##*/}          # filename (removes path)

****************************************

#!/bin/bash
# string_replacement.sh

path="/home/user/documents/file.txt"
text="The quick brown fox jumps over the lazy dog"

# 1. Replace first occurrence
echo ${text/o/_}    # The quick brwn fox jumps over the lazy dog


# 2. Replace all occurrences
echo ${path//\//\\}     # \home\user\documents\file.txt
echo ${text//o/_}       # The quick brwn f_x jumps _ver the lazy d_g

# 3. Replace at beginning
echo ${path/#\/home/\/root}  # /root/user/documents/file.txt

# 4. Replace at end
echo ${path/%txt/md}  # /home/user/documents/file.md

# 5. Delete pattern (replace with nothing)
echo ${text// /}      # Thequickbrownfoxjumpsoverthelazydog
echo ${text//[aeiou]/}  # Th qck brwn fx jmps vr th lzy dg

***************

#!/bin/bash
# case_conversion.sh

text="Hello World"
mixed="HeLLo WoRLd"

# 1. Uppercase first character
echo ${text^}      # Hello World (already capitalized)
echo ${mixed^}     # HeLLo WoRLd (only first char)

# 2. Uppercase all
echo ${text^^}     # HELLO WORLD
echo ${mixed^^}    # HELLO WORLD

# 3. Lowercase first character
echo ${text,}      # hello World
echo ${mixed,}     # heLLo WoRLd

# 4. Lowercase all
echo ${text,,}     # hello world
echo ${mixed,,}    # hello world

# 5. Toggle case
echo ${text~~}     # hELLO wORLD
echo ${mixed~~}    # hEllO wOrlD

***********

#!/bin/bash
# substring_extraction.sh

text="Bash Shell Scripting"
#     012345678901234567890

# Syntax: ${variable:offset:length}

# 1. Extract from position
echo ${text:5}       # Shell Scripting (from position 5 to end)
echo ${text:0:4}     # Bash (from 0, length 4)
echo ${text:5:5}     # Shell (from 5, length 5)

# 2. Negative offset (from end)
echo ${text: -9}     # Scripting (last 9 characters)
echo ${text: -9:6}   # Script (from 9th-last, length 6)

# 3. Real-world: Extract date components
date_string="2024-10-15"
year=${date_string:0:4}    # 2024
month=${date_string:5:2}   # 10
day=${date_string:8:2}     # 15

echo "Year: $year, Month: $month, Day: $day"

# 4. Extract file extensions
filename="document.backup.tar.gz"
extension=${filename##*.}              # gz
double_ext=${filename#*.}              # backup.tar.gz
name_only=${filename%%.*}              # document
