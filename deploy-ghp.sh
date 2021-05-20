#! /bin/bash

# Creates a GitHub Pages deployment of project files in order to host the project on GitHub Pages

# Potential error codes
E_NO_DEPLOY_DIR=81
E_NO_FILES=82

# Deployment directory
# The default directory is "docs" in a project to be hosted on GitHub Pages
DEPLOY_DIR="docs"

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

# Writes an [ERROR] line to STDOUT followed by a newline character
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
write_info_line()
{
	echo "[INFO] $1"
}

# Writes a regular newline character to STDOUT
write_newline()
{
	echo ""
}

write_info_line "Beginning GitHub Pages project deployment..."

# If there are no files to copy, exit immediately
if [ "${#APPLICATION_FILES[@]}" -eq "0" ]; then
	write_error_exit_line $E_NO_FILES "There are no files to deploy"
fi

# Create the deployment directory if it does not exist
if [ ! -d "$DEPLOY_DIR" ]; then
	write_info_line "Creating deployment directory \"$DEPLOY_DIR\"..."
	mkdir $DEPLOY_DIR

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
write_info_line "Finished file deployment operations"
write_newline

write_info_line "Done"