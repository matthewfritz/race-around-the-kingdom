#! /bin/bash

# deploy-ghp.sh
# By Matthew Fritz
#
# Creates a GitHub Pages deployment of project files in order to host the project on GitHub Pages.
# The items in the deployment directory can also be automatically pushed upstream based upon
# supplied runtime arguments.
#
# Usage:
#
#    ./deploy-ghp.sh --help
#
# That will display the usage instructions.
#
#    ./deploy-ghp.sh
#
# That will simply perform all steps without pushing upstream.
#
#    ./deploy-ghp.sh -p
#    ./deploy-ghp.sh --push
#
# Those will perform all steps and then push upstream with the default commit message.
#
#    ./deploy-ghp.sh -p -m "Commit message"
#    ./deploy-ghp.sh -p --message "Commit message"
#    ./deploy-ghp.sh --push -m "Commit message"
#    ./deploy-ghp.sh --push --message "Commit message"
#
# Those will perform all steps and then push upstream with a custom commit message.
#
# There is also the option to use a deploy file containing the list of file paths to deploy.
# If a file called "deploy-ghp-files.txt" exists then it will be read and replace the
# default list of files. Each line of the file may contain only one file path.
#
# A list of file paths, one per line, can be generated with either of the following commands:
#    ls |  tr '[:space:]' '\n'
#    ls *.html | tr '[:space:]' '\n' # (allows for file patterns)
#
# Current script version (GitHub Gist):
# https://gist.github.com/matthewfritz/97f08e955c8077d50dfd178aa20c937a

# Potential error codes
E_NO_DEPLOY_DIR=81
E_NO_FILES=82

# Deployment directory
# The default directory is "docs" in a project to be hosted on GitHub Pages
DEPLOY_DIR="docs"

# Default commit message if a custom message is not provided as an argument
DEFAULT_COMMIT_MSG="Updated items in the $DEPLOY_DIR directory for GitHub Pages"

# Path to an optional file that lists the set of files to deploy, one per line;
# this will override the default entries in the APPLICATION_FILES array if the
# file exists
DEPLOY_FILES_PATH="deploy-ghp-files.txt"

# Default array of files/subdirectories to copy directly to the deployment directory;
# this will be overriden by the entries in $DEPLOY_FILES_PATH if it exists
declare -a APPLICATION_FILES=(
   "aggregator.js"
   "dataloader.js"
   "index.html"
   "jquery-1.7.1.min.js"
   "marker.png"
   "places.json"
   "questions.json"
   "ratk_src_20120104.zip"
)

# Array of additional subdirectories that need to be created for reasons other
# than full recursive copies
declare -a ADDITIONAL_SUBDIRS=()

# Writes the script usage instructions to STDOUT followed by a newline character
# Usage: show_usage
show_usage()
{
   echo "deploy-ghp.sh"
   echo "By Matthew Fritz"
   echo
   echo "Creates a GitHub Pages deployment of project files in order to host the project on GitHub Pages."
   echo "The items in the deployment directory can also be automatically pushed upstream based upon"
   echo "supplied runtime arguments."
   echo
   echo "Usage:"
   echo
   echo "   $0 --help"
   echo
   echo "That will display the usage instructions."
   echo
   echo "   $0"
   echo
   echo "That will simply perform all steps without pushing upstream."
   echo
   echo "   $0 -p"
   echo "   $0 --push"
   echo
   echo "Those will perform all steps and then push upstream with the default commit message."
   echo
   echo "   $0 -p -m \"Commit message\""
   echo "   $0 -p --message \"Commit message\""
   echo "   $0 --push -m \"Commit message\""
   echo "   $0 --push --message \"Commit message\""
   echo
   echo "Those will perform all steps and then push upstream with a custom commit message."
   echo
   echo "There is also the option to use a deploy file containing the list of file paths to deploy."
   echo "If a file called \"$DEPLOY_FILES_PATH\" exists then it will be read and replace the"
   echo "default list of files. Each line of the file may contain only one file path."
   echo
   echo "A list of file paths, one per line, can be generated with either of the following commands:"
   echo "   ls | tr '[:space:]' '\n'"
   echo "   ls *.html | tr '[:space:]' '\n' # (allows for file patterns)"
   echo
   echo "Current script version (GitHub Gist):"
   echo "https://gist.github.com/matthewfritz/97f08e955c8077d50dfd178aa20c937a"
}

# Writes an [ERROR] line to STDOUT followed by a newline character
# Usage: write_error_line "Error message"
write_error_line()
{
   echo "[ERROR] $1"
}

# Writes an [ERROR] line to STDOUT and then exits with a numeric exit code
# Usage: write_error_exit_line $E_ERROR_CODE "Error message"
write_error_exit_line()
{
   echo "[ERROR] $2"
   echo "Exiting."
   exit $1
}

# Writes an [INFO] line to STDOUT followed by a newline character
# Usage: write_info_line "Info message"
write_info_line()
{
   echo "[INFO] $1"
}

# Writes a regular newline character to STDOUT
# Usage: write_newline
write_newline()
{
   echo ""
}

# Check runtime arguments in order to determine script behavior
do_upstream_push=false
commit_msg="$DEFAULT_COMMIT_MSG"
case "$#" in
   "1" | "3" )
      if [ "$1" == "--help" ]; then
         # Show script usage
         show_usage
         exit
      else
         if [ "$1" == "-p" ] || [ "$1" == "--push" ]; then
            # We will be pushing
            do_upstream_push=true

            # If the second argument is the commit message flag, use the
            # third argument as the content of the message
            if [ "$2" == "-m" ] || [ "$2" == "--message" ]; then
               commit_msg="$3"
            fi
         fi
      fi
   ;;
esac

write_info_line "Beginning GitHub Pages project deployment..."

# If the optional file containing file paths is present and there is at least
# one path, use that instead
write_newline
if [ -f "$DEPLOY_FILES_PATH" ]; then
   # Read the file list into an array
   declare -a deploy_files
   deploy_files=(`cat "$DEPLOY_FILES_PATH" | tr -d '\r'`) # Windows needs an additional \r deletion

   if [ "${#deploy_files[@]}" -gt "0" ]; then
      # The file contents now become the set of application files to deploy
      write_info_line "Using the list of files from \"$DEPLOY_FILES_PATH\" deploy file for deployment."
      APPLICATION_FILES=("${deploy_files[@]}") # Copy array $deploy_files to $APPLICATION_FILES
   else
      # No files present in optional file
      write_info_line "Deploy file \"$DEPLOY_FILES_PATH\" exists but no files are present. Using default list for deployment."
   fi
else
   write_info_line "Deploy file \"$DEPLOY_FILES_PATH\" does not exist. Using default list of files."
fi
write_newline

# If there are no files to copy, exit immediately
if [ "${#APPLICATION_FILES[@]}" -eq "0" ]; then
   write_error_exit_line $E_NO_FILES "There are no files to deploy"
fi

# Create the deployment directory if it does not exist
if [ ! -d "$DEPLOY_DIR" ]; then
   write_info_line "Creating deployment directory \"$DEPLOY_DIR\"..."
   mkdir "$DEPLOY_DIR"

   # If the deployment directory could not be created, exit immediately
   if [ ! -d "$DEPLOY_DIR" ]; then
      write_error_exit_line $E_NO_DEPLOY_DIR "Deployment directory could not be created"
   fi

   write_info_line "Deployment directory created"
else
   write_info_line "Using \"$DEPLOY_DIR\" as the deployment directory"
fi

# If there are any additional subdirectories specified, create the subtrees
if [ "${#ADDITIONAL_SUBDIRS[@]}" -gt "0" ]; then
   write_info_line "Creating additional subdirectories..."
   
   for ADDITIONAL_SUBDIR in "${ADDITIONAL_SUBDIRS[@]}"
   do
      write_info_line "Creating subdirectory \"$DEPLOY_DIR/$ADDITIONAL_SUBDIR\"..."
      mkdir -p "$DEPLOY_DIR/$ADDITIONAL_SUBDIR"
   done

   write_info_line "Finished creating additional subdirectories"
else
   write_info_line "No additional subdirectories to create."
fi

write_newline
write_info_line "Beginning file deployment operations..."
write_newline

# Copy each application file or subdirectory into the deployment directory
for APP_FILE in "${APPLICATION_FILES[@]}"
do
   if [ -e "$APP_FILE" ]; then
      if [ -f "$APP_FILE" ]; then
         # Single file copy
         cp "$APP_FILE" "$DEPLOY_DIR/$APP_FILE"
         write_info_line "* Copied $APP_FILE to $DEPLOY_DIR/$APP_FILE"
      elif [ -d "$APP_FILE" ]; then
         # Subdirectory so the copy will be recursive
         cp -r "$APP_FILE" "$DEPLOY_DIR"
         write_info_line "* Copied directory $APP_FILE to $DEPLOY_DIR/$APP_FILE"
      fi
   else
      write_info_line "Could not find $APP_FILE. Skipping."
   fi
done

write_newline

# If we will be pushing, perform the necessary operations
if [ "$do_upstream_push" == "true" ]; then
   if [ ! "$commit_msg" == "$DEFAULT_COMMIT_MSG" ]; then
      write_info_line "Pushing directory \"$DEPLOY_DIR\" upstream with custom commit message..."
   else
      write_info_line "Pushing directory \"$DEPLOY_DIR\" upstream with default commit message..."
   fi

   git add "$DEPLOY_DIR"
   git commit -m "$commit_msg"
   git push
else
   write_info_line "Not pushing \"$DEPLOY_DIR\" upstream"
fi

write_newline
write_info_line "Finished file deployment operations"
write_newline

write_info_line "Done"