#! /bin/bash

PACKAGE_NAME="com.example.starttime.measure"
FIRST_ACTIVITY="com.example.starttime.measure/MainActivity"
RELEASE_BUILD_VARIANT="installRelease"

run_tests () {
	echo "Run tests"
	TOTAL_TIME=0
	TOTAL_CYCLES=30
	MAX_TIME=0
	MIN_TIME=0
	for i in $(seq 1 $TOTAL_CYCLES)
		do
			adb shell am force-stop $PACKAGE_NAME
			sleep 1
			RESULT=$(adb shell am start-activity -W -n $FIRST_ACTIVITY | grep "TotalTime" | cut -d ' ' -f 2)
			TOTAL_TIME=$(($TOTAL_TIME+$RESULT))
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

build_and_install () {
	echo "Uninstall apk"
	adb uninstall $PACKAGE_NAME >> /dev/null
	if [ $? -eq 0 ]; then
	   echo OK
	else
	   echo Was not installed
	fi


	./gradlew clean >> /dev/null
	### install release build
	echo "Build release apk and install"
	./gradlew $RELEASE_BUILD_VARIANT >> /dev/null
	if [ $? -eq 0 ]; then
	   echo OK
	else
	   echo FAIL
	   exit 1
	fi
}


FAIL_LOCK_COUNTER=0

try_lock () {
	### lock clocks
	echo "Try to lock clocks"
	./gradlew lockClocks  >> /dev/null
	if [ $? -eq 0 ]; then
		sleep 1
		echo OK
	else
		echo FAIL
		FAIL_LOCK_COUNTER=1+$FAIL_LOCK_COUNTER
		if [ $FAIL_LOCK_COUNTER -eq 3 ]; then
			exit 1
		else
			try_lock
		fi
	fi
}


### run emulator
$ANDROID_HOME/emulator/emulator -avd $1  >> /dev/null &
adb wait-for-device
sleep 100

try_lock

git checkout $2 #test/v0.0.1

build_and_install

run_tests

git checkout $3 #test/v0.0.2

build_and_install

run_tests


### unlock
echo "Unlock clocks"
./gradlew unlockClocks  >> /dev/null


### turn of emulator
adb devices | grep emulator | cut -f1 | while read line; do adb -s $line emu kill; done