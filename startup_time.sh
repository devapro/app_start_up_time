#! /bin/bash

PACKAGE_NAME="com.example.starttime.measure"
FIRST_ACTIVITY="com.example.starttime.measure/.MainActivity"
RELEASE_BUILD_VARIANT="assembleRelease"

run_tests () {
	echo "Run tests"
	TOTAL_TIME=0
	TOTAL_CYCLES=3
	MAX_TIME=0
	MIN_TIME=0
	for i in $(seq 1 $TOTAL_CYCLES)
		do
			adb shell am force-stop $PACKAGE_NAME
			adb shell pm clear $PACKAGE_NAME
			sleep 1
			RESULT=$(adb shell am start-activity -W -n ${FIRST_ACTIVITY} | grep "TotalTime" | cut -d ' ' -f 2)
			# check if not empty
			if [ -z "$RESULT" ]
			then
            echo "adb shell am start-activity return error"
            exit 1
      fi
			TOTAL_TIME=$((TOTAL_TIME+RESULT))
			if [[ $MAX_TIME < $RESULT ]]; then
				MAX_TIME=$RESULT
			fi
			if [[ $MIN_TIME == 0 ]]; then
				MIN_TIME=$RESULT
			fi
			if [[ $MIN_TIME > $RESULT ]]; then
				MIN_TIME=$RESULT
			fi
		done
	echo "Average time: $(($TOTAL_TIME/$TOTAL_CYCLES))"
	echo "Max time: $MAX_TIME"
	echo "Min time: $MIN_TIME"
}

install () {
	echo "Uninstall apk"
	adb uninstall $PACKAGE_NAME >> /dev/null
	if [ $? -eq 0 ]; then
	   echo OK
	else
	   echo Was not installed
	fi

  echo "Install apk"
  adb install -d "/tmp/$1.apk"
  if [ $? -eq 0 ]; then
  	   echo OK
  	else
  	   echo Was not installed
  	   exit 1
  	fi
}

build () {
	./gradlew clean >> /dev/null
	### install release build
	echo "Build release apk"
	./gradlew $RELEASE_BUILD_VARIANT >> /dev/null
	if [ $? -eq 0 ]; then
	   echo OK
	   ### replace with relevant path
	   cp ./app/build/outputs/apk/release/app-release.apk "/tmp/$1.apk"
	else
	   echo FAIL
	   exit 1
	fi
}


### run emulator
if [ -z "$3" ]; then
  echo "You didn't provide emulator name. Will be used active emulator or device"
else
  $ANDROID_HOME/emulator/emulator -avd $1  >> /dev/null &
  adb wait-for-device
  sleep 100
fi

git checkout $2 #release/v1.0.1

build 1

git checkout $3 #release/v1.0.2

build 2

install 1

run_tests

install 2

run_tests

### turn of emulator
if [ -z "$3" ]; then
  echo "You didn't provide emulator name. Was used active emulator or device"
else
  adb devices | grep emulator | cut -f1 | while read line; do adb -s $line emu kill; done
fi