# race

As a runner, I wanted a utility for calculating running times and paces.
I wrote this script so I could enter distances and times to find out what pace I need to run at.
I also wanted to set a distance and pace and calculate the finishing time.

```
# find the pace for a 40 minute 10k
$ race 10 40:00
> 4:00
# find the finishing time for 10k at 4:00/km
$ race -t 10 4:00
> 40:00 
```

## Usage
My preferred method to use this script is adding a symlink to /usr/local/bin

Make the script executable, then create the link
```
$ chmod +x race.sh
$ ln -s ./race.sh /usr/local/bin/race
```

From there, run the help option to see how it's used
```
$ race -h
```