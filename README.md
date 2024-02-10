# Description

This bash script allows you to automatically merge .mp4 files with english .srt subtitles into a .mkv file. <br>
It will ignore any other subtitle languages and will ignore .srt subtitles with less than 30Kb *(usually broken subs)*. <br>
<br>
After it creates the .mkv file, it will rename the movie folder *(not the .mkv file itself)* and remove any release group names, codecs, resolutions etc in order to create a clean folder name. <br>
**This process will happen to all folders that are in the same directory as the script itself, one by one.** <br>

**It was mainly made for the rarbg movies file structure** <br>

## Dependencies:
```
sudo apt-get update && sudo apt-get install mkvtoolnix
```

## Instructions:

Make sure you run this script in the same directory where you have your rarbg movie folders and just wait for those 200 movies to be auto muxed into mkv files. <br>

Download the script in terminal with:
```
wget https://raw.githubusercontent.com/Chillsmeit/rarbg-mkvmerger/main/rarbg_automkvmerger.sh
```
Make the script executable:
```
chmod +x rarbg_automkvmerger.sh
```
Run the script **without** sudo privileges:
```
./rarbg_automkvmerger.sh
```
