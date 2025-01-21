In this work, the size of a user-submitted folder is calculated. 
If a folder's fullness exceeds a user-specified percentage, older files in the folder are archived until the folder exceeds the transferred percentage.
A script was also created with basic tests to check the correctness of the main script. 
## Description of scripts
### `chapter.sh`
- Creates a virtual image of the partition
- Formats the partition in ext4 format and mounts it
- Removes old partitions
### `lab1.sh`
- Monitors the size of a given directory.
- Archives files when the threshold is exceeded.
- Saves archives in the user's home directory and compresses them.
### `tests.sh`
- Contains tests to check the basic functionality of the main script.

(Second year university)
