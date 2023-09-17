#!/bin/bash

shopt -s globstar nocaseglob

# Find movie folders
while IFS= read -r -d '' movie; do

	# Skip the current directory
	if [ "$movie" != "." ]; then

		# Get the movie name from the folder name
		movie_name=$(basename "$movie")

		# Find the movie file inside the movie folder
		movie_file=$(find "$movie" -maxdepth 1 -type f -iname "*.mp4" -print -quit)

		# Check if movie file exists
		if [ -n "$movie_file" ]; then

			# Find all subtitle files inside the movie folder with English-related words in the name and size greater than 30kB
			subtitles=$(find "$movie" -type f -iname "*.srt" -iname "*[Ee][Nn]*[Gg]*[Ll]*[Ii]*[Ss]*[Hh]*" -size +30k)

			# Check if any suitable subtitle files were found
			if [ -n "$subtitles" ]; then
        			merged_subtitle_args=()
        			default_sub_index=0
        			sub_index=0
        			default_sub_found=false

				# Loop through each subtitle file
				while IFS= read -r subtitle; do

				# Determine if it should be the default subtitle or not
				if [ "$sub_index" -eq "$default_sub_index" ]; then
					merged_subtitle_args+=(--default-track "$sub_index" --language "$sub_index":eng --track-name "$sub_index":"English" "$subtitle")
					default_sub_found=true
          			else
					merged_subtitle_args+=(--language "$sub_index":eng --track-name "$sub_index":"English" "$subtitle")
				fi

				((sub_index++))
				done <<< "$subtitles"

				# If the default subtitle index is out of range, set the default to the first subtitle track
				if [ "$default_sub_found" = false ]; then
					merged_subtitle_args=(--default-track 0 "${merged_subtitle_args[@]}")
				fi

				# Merge movie and subtitles using mkvmerge
				mkvmerge -o "$movie/${movie_name}.mkv" "${merged_subtitle_args[@]}" "$movie_file"
				echo "Merged subtitles with $movie_name."

				# Save the name of the .mp4 file without extension
				mp4_name=$(basename "$movie_file" .mp4)

				# Delete the original .mp4 file
				rm "$movie_file"

				# Delete any sub-folders inside the movie folder
				find "$movie" -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} +

				# Delete .txt, .nfo, and .exe files inside the movie folder
				find "$movie" -type f \( -iname "*.txt" -o -iname "*.nfo" -o -iname "*.exe" \) -exec rm -f {} +

				# Rename the .mkv file to the original .mp4 name with .mkv extension
				mv "$movie/${movie_name}.mkv" "$movie/${mp4_name}.mkv"
				echo "Renamed ${movie_name}.mkv to ${mp4_name}.mkv."
      			else
        			echo "No suitable subtitles found for $movie_name."
      			fi
    		else
      			echo "No movie file found in $movie_name."
    		fi
	fi

done < <(find . -maxdepth 1 -type d -name "*[!.]*" -print0)

echo "All movies processed."

# Rename movie folders
find . -maxdepth 1 -type d -name "*[!.]*" -print0 | while IFS= read -r -d '' folder; do
	folder_name=$(basename "$folder")

	# Remove "-" and keywords
	folder_name=$(echo "$folder_name" | sed -E 's/-|x265|RARBG|x264|h264|UNRATED|HEVC|10bit|REMASTERED|PROPER|BluRay|1080p|720p|EXTENDED|WEBRip|IMAX//gi')

	# Remove dates. Checks for 4 numbers together that go from 0 to 9
	folder_name=$(echo "$folder_name" | sed -E 's/([0-9]{4})//g')

	# Replace "." with spaces
	folder_name="${folder_name//./ }"

	# Remove extra spaces
	folder_name=$(echo "$folder_name" | tr -s ' ')

	# Remove spaces at the end of the name
	folder_name=$(echo "$folder_name" | sed 's/[[:space:]]*$//')

	# Rename folder
	if [ "$folder_name" != "$folder" ]; then
		mv "$folder" "$folder_name"
		echo "Renamed folder $folder to $folder_name"
	fi
done

echo "All folders renamed."
