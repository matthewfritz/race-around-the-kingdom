#! /bin/bash

# deploy-ghp.sh
# By Matthew Fritz
#
# Creates a GitHub Pages deployment of project files in order to host the project on GitHub Pages.
# Realistically, this can also be used for any kind of copy-based operation with an arbitrary set
# of files and/or directories.
#
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
# That will simply perform all deployment steps without pushing upstream.
#
#    ./deploy-ghp.sh -c
#    ./deploy-ghp.sh --check
#
# Those will check the set of deployment files for validity and then exit without deploying.
#
#    ./deploy-ghp.sh -p
#    ./deploy-ghp.sh --push
#
# Those will perform all deployment steps and then push upstream with the default commit message.
#
#    ./deploy-ghp.sh -p -m "Commit message"
#    ./deploy-ghp.sh -p --message "Commit message"
#    ./deploy-ghp.sh --push -m "Commit message"
#    ./deploy-ghp.sh --push --message "Commit message"
#
# Those will perform all deployment steps and then push upstream with a custom commit message.
#
# The default deployment configuration options can be overridden at runtime using an
# optional configuration file named "deploy-ghp-config.conf". If that file exists, the
# relevant configuration values will be loaded.
#
# There is also the option to use a deploy file containing the list of file paths to deploy.
# If a file called "deploy-ghp-files.txt" exists then it will be read and replace the
# default list of files. Each line of the file may contain only one file path.
#
# If a line in "deploy-ghp-files.txt" begins with the token "MKDIR:", a matching directory
# tree will be created with the "mkdir -p" command.
#
# A list of file paths, one per line, can be generated with either of the following commands:
#    ls |  tr '[:space:]' '\n'
#    ls *.html | tr '[:space:]' '\n' # (allows for file patterns)
#
# Current script version (GitHub Gist):
# https://gist.github.com/matthewfritz/97f08e955c8077d50dfd178aa20c937a
#
# Comment with instructions on creating the "deploy-ghp-config.conf" config file:
# https://gist.github.com/matthewfritz/97f08e955c8077d50dfd178aa20c937a#gistcomment-3752801
#
# Comment with instructions on creating the "deploy-ghp-files.txt" deploy file:
# https://gist.github.com/matthewfritz/97f08e955c8077d50dfd178aa20c937a#gistcomment-3752526

# Potential error codes
E_NO_DEPLOY_DIR=81
E_NO_FILES=82

# Deployment directory
# The default directory is "docs" in a project to be hosted on GitHub Pages
DEPLOY_DIR="docs"

# Default commit message if a custom message is not provided as an argument
DEFAULT_COMMIT_MSG="Deployed necessary items to the $DEPLOY_DIR directory"

# Path to an optional file that provides the set of configuration options to
# use when performing the deployment
DEPLOY_CONFIG_PATH="deploy-ghp-config.conf"

# Path to an optional file that lists the set of files to deploy, one per line;
# this will override the default entries in the APPLICATION_FILES array if the
# file exists
DEPLOY_FILES_PATH="deploy-ghp-files.txt"

# Default array of files/subdirectories to copy directly to the deployment directory;
# this will be overridden by the entries in $DEPLOY_FILES_PATH if it exists
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
# than full recursive copies; this can be overridden by lines in $DEPLOY_FILES_PATH
# that begin with the token "MKDIR:"
declare -a ADDITIONAL_SUBDIRS=()

# Performs a validity check on all files within $APPLICATION_FILES to determine
# what files and/or directories will be deployed successfully. Validity checks
# will only generate output if there is some kind of error.
# Usage: check_deployment_files
check_deployment_files()
{
   write_info_line "Performing validity check on deployment file list..."

   local dep_file_count=0
   local skip_file_count=0

   # Check validity of each path in the deployment file list
   for dep_file in "${APPLICATION_FILES[@]}"
   do
      # Existence check first
      if [ -e "$dep_file" ]; then
         # Type check on the deployment file entry
         if [ -f "$dep_file" ] || [ -d "$dep_file" ]; then
            (( dep_file_count++ ))
         else
            # Not a file or directory
            write_error_line "* Deployment file entry \"$dep_file\" is not a file or directory. Skipping."
            (( skip_file_count++ ))
         fi
      else
         write_error_line "* Deployment file entry \"$dep_file\" does not exist. Skipping."
         (( skip_file_count++ ))
      fi
   done

   write_newline
   write_info_line "$dep_file_count item(s) valid for deployment. $skip_file_count item(s) skipped."
   write_info_line "Finished deployment file list validity check"
}

# Writes the script usage instructions to STDOUT followed by a newline character
# Usage: show_usage
show_usage()
{
   echo "deploy-ghp.sh"
   echo "By Matthew Fritz"
   echo
   echo "Creates a GitHub Pages deployment of project files in order to host the project on GitHub Pages."
   echo "Realistically, this can also be used for any kind of copy-based operation with an arbitrary set"
   echo "of files and/or directories."
   echo
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
   echo "  $0 -c"
   echo "  $0 --check"
   echo
   echo "Those will check the set of deployment files for validity and then exit without deploying."
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
   echo "The default deployment configuration options can be overridden at runtime using an"
   echo "optional configuration file named \"$DEPLOY_CONFIG_PATH\". If that file exists, the"
   echo "relevant configuration values will be loaded."
   echo
   echo "There is also the option to use a deploy file containing the list of file paths to deploy."
   echo "If a file called \"$DEPLOY_FILES_PATH\" exists then it will be read and replace the"
   echo "default list of files. Each line of the file may contain only one file path."
   echo
   echo "If a line in \"$DEPLOY_FILES_PATH\" begins with the token \"MKDIR:\", a matching directory"
   echo "tree will be created with the \"mkdir -p\" command."
   echo
   echo "A list of file paths, one per line, can be generated with either of the following commands:"
   echo "   ls | tr '[:space:]' '\n'"
   echo "   ls *.html | tr '[:space:]' '\n' # (allows for file patterns)"
   echo
   echo "Current script version (GitHub Gist):"
   echo "https://gist.github.com/matthewfritz/97f08e955c8077d50dfd178aa20c937a"
   echo
   echo "Comment with instructions on creating the \"$DEPLOY_CONFIG_PATH\" config file:"
   echo "https://gist.github.com/matthewfritz/97f08e955c8077d50dfd178aa20c937a#gistcomment-3752801"
   echo
   echo "Comment with instructions on creating the \"$DEPLOY_FILES_PATH\" deploy file:"
   echo "https://gist.github.com/matthewfritz/97f08e955c8077d50dfd178aa20c937a#gistcomment-3752526"
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
do_deploy_check=false
do_upstream_push=false
commit_msg="$DEFAULT_COMMIT_MSG"
case "$#" in
   "1" | "3" )
      if [ "$1" == "--help" ]; then
         # Show script usage
         show_usage
         exit
      elif [ "$1" == "-c" ] || [ "$1" == "--check" ]; then
         # We will be checking deployment file list validity
         do_deploy_check=true
      elif [ "$1" == "-p" ] || [ "$1" == "--push" ]; then
         # We will be pushing
         do_upstream_push=true

         # If the second argument is the commit message flag, use the
         # third argument as the content of the message
         if [ "$2" == "-m" ] || [ "$2" == "--message" ]; then
            commit_msg="$3"
         fi
      fi
   ;;
esac

write_info_line "Beginning project deployment..."

# Load the deployment configuration file if it exists
write_newline
if [ -f "$DEPLOY_CONFIG_PATH" ]; then
   write_info_line "Using the deployment configuration from \"$DEPLOY_CONFIG_PATH\" config file."
   . "$DEPLOY_CONFIG_PATH"
else
   write_info_line "Config file \"$DEPLOY_CONFIG_PATH\" does not exist. Using default configuration."
fi
write_newline

# Display configuration
write_info_line "* Deployment directory: \"$DEPLOY_DIR\""
write_info_line "* Default commit message: \"$DEFAULT_COMMIT_MSG\""
write_info_line "* Deploy file list path: \"$DEPLOY_FILES_PATH\""

# If the optional file containing file paths is present and there is at least
# one path, use that instead
write_newline
if [ -f "$DEPLOY_FILES_PATH" ]; then
   # Read the file list into an array
   declare -a deploy_files
   deploy_files=(`cat "$DEPLOY_FILES_PATH" | tr -d '\r'`) # Windows needs an additional \r deletion
   let dep_file_len="${#deploy_files[@]}"

   if [ "${#deploy_files[@]}" -gt "0" ]; then
      # The file contents now become the set of application files to deploy
      write_info_line "Using the list of files from \"$DEPLOY_FILES_PATH\" deploy file for deployment."
      APPLICATION_FILES=("${deploy_files[@]}") # Copy array $deploy_files to $APPLICATION_FILES

      # Resolve any optional directories that may be present in the file
      declare -a optional_dirs=()
      let dep_file_index="0"
      while [ "$dep_file_index" -lt "$dep_file_len" ]
      do
         # If the line begins with "MKDIR:" then add the directory to the array
         # without the leading "MKDIR:" token
         deploy_file="${deploy_files[$dep_file_index]}"
         if [ "${#deploy_file}" -gt "6" ] && [ "${deploy_file:0:6}" == "MKDIR:" ]; then
            optional_dirs[${#optional_dirs[*]}]=${deploy_file#"MKDIR:"}

            # Remove the line from the $APPLICATION_FILES array so we don't create
            # erroneous output when checking path existence during file deployment
            unset APPLICATION_FILES[$dep_file_index]
         fi

         (( dep_file_index++ ))
      done

      if [ "${#optional_dirs[@]}" -gt "0" ]; then
         ADDITIONAL_SUBDIRS=("${optional_dirs[@]}")
      fi
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

# If we are merely performing a deployment file list validation check, perform it
# and then exit directly
if [ "$do_deploy_check" == "true" ]; then
   check_deployment_files
   exit
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
write_newline

# If there are any additional subdirectories specified, create the subtrees
if [ "${#ADDITIONAL_SUBDIRS[@]}" -gt "0" ]; then
   write_info_line "Creating additional subdirectories..."
   write_newline
   
   for ADDITIONAL_SUBDIR in "${ADDITIONAL_SUBDIRS[@]}"
   do
      write_info_line "* Creating subdirectory \"$DEPLOY_DIR/$ADDITIONAL_SUBDIR\"..."
      mkdir -p "$DEPLOY_DIR/$ADDITIONAL_SUBDIR"
   done

   write_newline
   write_info_line "Finished creating additional subdirectories"
else
   write_info_line "No additional subdirectories to create."
fi

write_newline
write_info_line "Beginning file deployment operations..."
write_newline

# Copy each application file or subdirectory into the deployment directory
num_deployed_files=0
num_skipped_files=0
for APP_FILE in "${APPLICATION_FILES[@]}"
do
   if [ -e "$APP_FILE" ]; then
      if [ -f "$APP_FILE" ]; then
         # Single file copy
         cp "$APP_FILE" "$DEPLOY_DIR/$APP_FILE"
         write_info_line "* Copied $APP_FILE to $DEPLOY_DIR/$APP_FILE"
         (( num_deployed_files++ ))
      elif [ -d "$APP_FILE" ]; then
         # Subdirectory so the copy will be recursive
         cp -r "$APP_FILE" "$DEPLOY_DIR"
         write_info_line "* Copied directory $APP_FILE to $DEPLOY_DIR/$APP_FILE"
         (( num_deployed_files++ ))
      else
         # Not a file or directory
         write_error_line "* Path \"$APP_FILE\" is not a file or directory. Skipping."
         (( num_skipped_files++ ))
      fi
   else
      write_info_line "* Could not find $APP_FILE. Skipping."
      (( num_skipped_files++ ))
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
write_info_line "$num_deployed_files item(s) deployed. $num_skipped_files item(s) skipped."
write_info_line "Finished file deployment operations"
write_newline

write_info_line "Finished project deployment"
write_info_line "Done"