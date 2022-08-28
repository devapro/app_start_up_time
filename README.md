### Measuring difference of stat time between two releases

Script for running application N times and collect statistics of the time from start to the first frame
It can be useful for comparing start-up time between releases.
Example of the usage:

```bash
/bin/bash ./bash/startup_time_measurement.sh Phone_API_30 release/v1.0.1 release/v1.0.2
```

**Phone_API_30** - name of the emulator (or you can use real device)
**release/v1.0.1** - previous release brunch
**release/v1.0.2** - new release branch

