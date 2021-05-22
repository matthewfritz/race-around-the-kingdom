# Deploy File Overview

## File Contents and Formatting

Contents of optional deploy file `deploy-ghp-files.txt` should be formatted like the following example:

```
file1.html
file2.html
file3.html
img/
file4.html
MKDIR:etc
etc/misc1.txt
etc/misc2.txt
MKDIR:opt/docs
opt/docs/document1.xml
```

Each line may contain only one file path.

### Line-by-Line Operations

* If a line references the path to a file, it will be copied directly with `cp`.
* If a line references the path to a directory, it will be copied recursively with `cp -r`.
* If a line begins with `MKDIR:`, a directory tree will be created with `mkdir -p`.

The contents of this file will override the default entries in the `$APPLICATION_FILES` array and can also override the default entries in the `$ADDITIONAL_SUBDIRS` array.

## Example File Operations

The example performs the following operations with the deployment directory as the target:
1. Copies `file1.html` directly
2. Copies `file2.html` directly
3. Copies `file3.html` directly
4. Copies `img/` directory recursively
5. Copies `file4.html` directly
6. Makes an empty `etc` directory so we can cherry-pick files to copy
7. Copies `etc/misc1.txt` directly
8. Copies `etc/misc2.txt` directly
9. Makes a subtree of `opt/docs` so we can cherry-pick files to copy
10. Copies `opt/docs/document1.xml` directly

The example creates the following deployment directory structure:

```
docs/
   etc/
      misc1.txt
      misc2.txt
   img/
   opt/
      docs/
         document1.xml
   file1.html
   file2.html
   file3.html
   file4.html
```

## Generating the Filename List

You can generate a set of filenames, one per line, with either of these two commands:
1. `ls | tr '[:space:]' '\n'`
2. `ls *.txt | tr '[:space:]' '\n'` (for file patterns)