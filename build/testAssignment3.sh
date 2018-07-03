#!/bin/bash

#Name: testAssignment3.sh
#Description: Validates that the java files exist, compile, and pass the tests correctly
#Output: Descriptions of errors found
#Exit Value: Number of errors found, 0 if the files were correct

errors=0
sleep 2
username=$(curl -s -H "Authorization: token $TOKEN" -X GET "https://api.github.com/repos/${SEMAPHORE_REPO_SLUG}/pulls/${PULL_REQUEST_NUMBER}" | jq -r '.user.login')
#username="LuisFernando100"
sleep 2
number=$(curl -s -H "Authorization: token $TOKEN" -X GET "https://raw.githubusercontent.com/WebServicesAndLinkedData/Assignment1/master/$username.csv" | awk -v username=$username -F "\"*,\"*" '{ if($1 == username) print $2}')
number=$(echo $number)
#number=123

#Check if correct directory exists
if [ ! -d "$username-$number" ]; then
  echo "Directory missing ($username-$number). Make sure it has the correct format" "$username-$number" "If the format is correct make sure your data here is correct https://github.com/WebServicesAndLinkedData/Assignment1/blob/master/$username.csv" >&2
  errors=$((errors+1))
else
	#Copy all files to src foulder
	cp -R $username-$number/. ./src/main/java/upm/oeg/wsld/jena/
	#Compile java files
	mvn -q compile
	if [[ $? -eq 0 ]]
	then
		#If compilation was correct run tests
		mvn -q test > tmp 2> /dev/null

		if [[ $? -ne 0 ]]
		then
			#If tests failed show error
			echo "ERROR ON TEST" >&2
			cat tmp 2>/dev/null  | sed -n '/Results :/,/Skipped: */p' | sed 's/<\|>//g' >&2
			errors=$((errors+1))
		fi
	else
		#If compilation was incorrect return Error
		echo "ERROR ON COMPILATION" >&2
		errors=$((errors+1))
	fi

	cat tmp 2> /dev/null

fi

exit $errors
