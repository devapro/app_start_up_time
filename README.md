### Measuring difference of stat time between two APK

#### How to add to the project

app/build.gradle.kts
```kotlin
plugins {
    ....
    id 'androidx.benchmark'
}
```

/build.gradle.kts
```kotlin
buildscript {
....

    dependencies {
        classpath("androidx.benchmark:benchmark-gradle-plugin:1.1.1")
    }
}
```

Script for running application N times and collect statistics of the time from start to the first frame
It can be useful for comparing start-up time between releases.

### Benchmark

```bash
/bin/bash ./startup_time_rooted.sh release/v1.0.1 release/v1.0.2 Phone_API_30
```

Optional parameters:

**Phone_API_30** - name of the emulator (or you can use real device) - device/emulator should be rooted

Required parameters:
**release/v1.0.1** - previous release brunch
**release/v1.0.2** - new release branch

Or for non rooted device, you can use this script, the difference only in Lock clocks on rooted device
```bash
/bin/bash ./startup_time.sh release/v1.0.1 release/v1.0.2 Phone_API_30
```

### Activity manager

```bash
/bin/bash ./startup_time_am.sh release/v1.0.1 release/v1.0.2 Phone_API_30
```