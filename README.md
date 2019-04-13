# Standup Shuffle

Iterates over a shuffled list of team members for daily standup.

## Features:

- Iterates over a shuffled list of team members
- Selection of missing team members on program start
- Supports 3(!) Commands: "Next, Back, Quit"
- Highlights upcoming team member with a :fearful: emoji
- Tracks time for each team member
- Shows a 1-minute progress bar
- Shows summary at end (includes total time)
- Adds additional spent time to team member if using the 'Back' command
- Shows :tada: emoji on summary screen
- Logs data in csv file

## Installation

### Prerequisites

```bash
$ ruby -v
ruby 2.5.3p105 (2018-10-18 revision 65156) [x86_64-darwin17]

$ bundler -v
Bundler version 2.0.1
```

### Installing

Install `rbenv` if you don't have it. It manages different versions of `Ruby` like `pyenv` for `Python`. 
Here is a good instruction: https://github.com/rbenv/rbenv#homebrew-on-macos.

Install Ruby and make it standard ruby if you like.
```bash
rbenv install 2.5.3
rbenv global 2.5.3
rbenv local 2.5.3
```

Clone the repo:
```bash
$ git clone git@github.com:fate83/standup-shuffle.git
```

Change into repo dir:
```bash
cd standup-shuffle
```

Install dependencies:
```bash
bundle install
```

Create your `members.txt` file:
```bash
echo "Member 1" >> members.txt
echo "Member 2" >> members.txt
echo "Member 3" >> members.txt
echo "Member 4" >> members.txt
echo "Member 5" >> members.txt
```

Start Standup Shuffle
```bash
bundle exec ruby standup_shuffle.rb
```

And here we go:
```
Anyone missing? (Use arrow keys, press Space to select and Enter to finish, and letter keys to filter)
‣ ⬡ Member 1
  ⬡ Member 2
  ⬡ Member 3
  ⬡ Member 4
  ⬡ Member 5
```

Select missing members:
```
Anyone missing? Member 1, Member 4
  ⬢ Member 1
  ⬡ Member 2
  ⬡ Member 3
‣ ⬢ Member 4
  ⬡ Member 5
```

And have fun with your standup:
```
Standup Shuffle Version 1.0
Start time: 
Current time: 19:48:51
+------+--------+----+
|      |Member  |Time|
+------+--------+----+
|  XX  |Member 2| -  |
|  XX  |Member 5| -  |
|  XX  |Member 3| -  |
+------+--------+----+
Press a key to start? 
```
`XX` = emojis.

## Versioning

Version 1.0

## Authors

* **Fabian Müller** - *Initial work* -


## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
