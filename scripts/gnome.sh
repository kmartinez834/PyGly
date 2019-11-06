#!/bin/sh

restriction_set_names=(
  "BCSDB"
  "GlyGen"
)


if [[ ! ("$(pwd)" =~ "/PyGly/scripts") ]]; then
  # Check for executing folder
  exit
fi

if [ -z "$1" ]
  then
    # Check for tag
    echo "Please provide the release tag number, eg V1.2.3"
    exit
fi

git clone git@github.com:glygen-glycan-data/GNOme.git
python27 ../pygly/GNOme.py writeowl ./GNOme/data/gnome_subsumption_raw.txt ./GNOme.owl ./GNOme/data/mass_lookup_2decimal $1
python27 ../pygly/GNOme.py viewerdata ./GNOme.owl ./GNOme.browser.json ./GNOme.browser.composition.json


for Restriction_set in "${restriction_set_names[@]}"
do
  python27 ../pygly/GNOme.py writeresowl ./GNOme.owl $Restriction_set ./GNOme_$Restriction_set.owl
  python27 ../pygly/GNOme.py viewerdata ./GNOme_$Restriction_set.owl ./GNOme_$Restriction_set.browser.json ./GNOme_$Restriction_set.browser.composition.json
done


cp ./GNOme/convert.sh ./
./convert.sh
mv ./GNOme.* ./GNOme/

for Restriction_set in "${restriction_set_names[@]}"
do
	for file_ext in "owl" "obo" "json" "browser.json" "browser.composition.json"
  do
    	mv ./GNOme_$Restriction_set.$file_ext ./GNOme/restrictions/
  done
done


cd ./GNOme
# echo $(pwd)

git checkout -b "Branch_$1"
git add -A

git commit -m "Version $1"
git push origin "Branch_$1"

rm -rf GNOme
rm convert.sh