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
# ./deploy-ghp.sh --help
#
# That will display the usage instructions.
#
# ./deploy-ghp.sh
#
# That will simply perform all steps without pushing upstream.
#
# ./deploy-ghp.sh -p
# ./deploy-ghp.sh --push
#
# Those will perform all steps and then push upstream with the default commit message.
#
# ./deploy-ghp.sh -p -m "Commit message"
# ./deploy-ghp.sh -p --message "Commit message"
# ./deploy-ghp.sh --push -m "Commit message"
# ./deploy-ghp.sh --push --message "Commit message"
#
# Those will perform all steps and then push upstream with a custom commit message.

# Potential error codes
E_NO_DEPLOY_DIR=81
E_NO_FILES=82

# Deployment directory
# The default directory is "docs" in a project to be hosted on GitHub Pages
DEPLOY_DIR="docs"

# Default commit message if a custom message is not provided as an argument
DEFAULT_COMMIT_MSG="Updated items in the $DEPLOY_DIR directory for GitHub Pages"

# Array of files/subdirectories to copy directly to the deployment directory
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
	echo "$0 --help"
	echo
	echo "That will display the usage instructions."
	echo
	echo "$0"
	echo
	echo "That will simply perform all steps without pushing upstream."
	echo
	echo "$0 -p"
	echo "$0 --push"
	echo
	echo "Those will perform all steps and then push upstream with the default commit message."
	echo
	echo "$0 -p -m \"Commit message\""
	echo "$0 -p --message \"Commit message\""
	echo "$0 --push -m \"Commit message\""
	echo "$0 --push --message \"Commit message\""
	echo
	echo "Those will perform all steps and then push upstream with a custom commit message."
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
			write_info_line "Copied $APP_FILE to $DEPLOY_DIR/$APP_FILE"
		elif [ -d "$APP_FILE" ]; then
			# Subdirectory so the copy will be recursive
			cp -r "$APP_FILE" "$DEPLOY_DIR"
			write_info_line "Copied directory $APP_FILE to $DEPLOY_DIR/$APP_FILE"
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