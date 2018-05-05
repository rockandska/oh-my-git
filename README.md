# Credits

This is an opinionated fork of the wonderful ["Oh My Git"](https://github.com/arialdomartini/oh-my-git/)

Contain merged branchs from :
- arialdomartini/oh-my-git:master
- cy4n/oh-my-git:master
- yutv/oh-my-git:theme

Thanks to them !

**/!\ Still WIP and could be a bit buggy**

Modifications:

- renamed the main function to ```_oh_my_git```, and renamed private functions to ```__oh_my_git_*```
- try to limit the shell variables exposed
- use XDG directory to store user config  of Oh My GIt ( "${XDG_CONFIG_HOME:-$HOME/.config}/oh-my-git" )
- add the possibility to use it as a simulated "status bar" ( "unique" oh-my-git infos bar at the top of the terminal )
- add a reverse mode to activate a mirrored view of the bar ( move the position of oh-my-git infos from right to the left of the screen )
- set VIRTUAL_ENV_DISABLE_PROMPT to false at start to let oh-my-git display the virtualenv based on VIRTUAL_ENV


Breakings changes:

- removed the compatibility with zsh antigen theme ( try to limit this fork to the "srict" minimum for now )
- removed callback function ( i think svirtualenv is displayed correctly without it )
- maybe others i'm not aware of

Side effects:

- With the "status bar" activated, you will loose the top row of the terminal (could be annoying with many lines outputed)

<br>


----------

# Installation
## Fonts

By default oh-my-git config use some symbols present into [Source Code Pro](https://github.com/adobe/Source-Code-Pro) by Adobe patched to include additional glyphs from [Powerline](https://github.com/powerline/powerline) and from Awesome-Terminal-Fonts.

If you don't have or don't want to use a font with additionals glyphs, change the symbols used by oh-my-git by providing new ones inside user config file.

## Bash

One liner for OS X:

    mkdir -p ~/.local/opt/oh-my-git && git clone --depth=1 https://github.com/rockandska/oh-my-git.git ~/.local/opt/oh-my-git && echo source ~/.local/opt/oh-my-git/prompt.sh >> ~/.profile

One liner for Ubuntu:

    mkdir -p ~/.local/opt/oh-my-git && git clone --depth=1 https://github.com/rockandska/oh-my-git.git ~/.local/opt/oh-my-git && echo source ~/.local/opt/oh-my-git/prompt.sh >> ~/.bashrc

Then restart your Terminal.
# User config

The config could be changed either by ENV variable or by adding config files (*.bash) inside ```${XDG_CONFIG_HOME:-$HOME/.config}/oh-my-git/```

Default oh-my-git config could be find inside ```~/.local/opt/oh-my-git/default.cfg.bash```

## Comportement

- ```OMG_ENABLE``` : ```true``` if oh-my-git should be enable, ```false``` if not
- ```OMG_CONDENSED``` : ```true``` if oh-my-git should be minimized, ```false``` if not
- ```OMG_REVERSE``` : ```true``` if oh-my-git need to be pushed to the right of the terminal, ```false``` if not
- ```OMG_STATUS_BAR``` : ```true``` if oh-my-git should be put at the top of the terminal, ```false``` if not
- ```OMG_VIRTUAL_ENV_DISABLE```  : ```true``` if oh-my-git need to let the virtualenv displayed by another PS1 manager, ```false``` if not

## Colors

You can easily change theme by changing the right variable.  


**List of default color variables**

```
OMG_THEME["left_side_color"]="black"
OMG_THEME["left_side_bg"]="bright_white"
OMG_THEME["left_icon_color"]="red"
OMG_THEME["stash_color"]="yellow"
OMG_THEME["right_side_color"]="black"
OMG_THEME["right_side_bg"]="red"
OMG_THEME["right_icon_color"]="bright_white"
OMG_THEME["default_bg"]="black"
```

**Possible colors:** 

- black
- blue
- cyan
- green
- purple
- red
- white
- yellow
- bright_black
- bright_blue
- bright_cyan
- bright_green
- bright_purple
- bright_red
- bright_white
- bright_yellow

## Symbols

**List of default symbol variables**

```
OMG_THEME["omg_is_a_git_repo_symbol"]=""
OMG_THEME["omg_submodules_outdated_symbol"]=""
OMG_THEME["omg_has_untracked_files_symbol"]=""
OMG_THEME["omg_has_adds_symbol"]=""
OMG_THEME["omg_has_deletions_symbol"]=""
OMG_THEME["omg_has_cached_deletions_symbol"]=""
OMG_THEME["omg_has_renames_symbol"]="➔"
OMG_THEME["omg_has_modifications_symbol"]=""
OMG_THEME["omg_has_cached_modifications_symbol"]=""
OMG_THEME["omg_ready_to_commit_symbol"]=""
OMG_THEME["omg_is_on_a_tag_symbol"]=""
OMG_THEME["omg_needs_to_merge_symbol"]=""
OMG_THEME["omg_detached_symbol"]=""
OMG_THEME["omg_can_fast_forward_symbol"]=""
OMG_THEME["omg_has_diverged_symbol"]=""
OMG_THEME["omg_not_tracked_branch_symbol"]=""
OMG_THEME["omg_rebase_tracking_branch_symbol"]=""
OMG_THEME["omg_rebase_interactive_symbol"]=""
OMG_THEME["omg_bisect_symbol"]=""
OMG_THEME["omg_bisect_close_symbol"]=""
OMG_THEME["omg_bisect_done_symbol"]=""
OMG_THEME["omg_merge_tracking_branch_symbol"]=""
OMG_THEME["omg_should_push_symbol"]=""
OMG_THEME["omg_has_stashes_symbol"]=""
OMG_THEME["omg_right_arrow_symbol"]=""
OMG_THEME["omg_left_arrow_symbol"]=""
OMG_THEME["omg_is_virtualenv_symbol"]=""
```


# Disabling oh-my-git
oh-my-git can be disabled on a per-repository basis. Just add a

    [oh-my-git]
    enabled = false

in the `.git/config` file of a repo to revert to the original prompt for that particular repo. This could be handy when working with very huge repository, when the git commands invoked by oh-my-git can slow down the prompt.

# Uninstall

## Bash
* Remove the line `source ~/.local/opt/oh-my-git/prompt.sh` from the terminal boot script (`.profile` or `.bashrc`)
* Delete the oh-my-git repo with a `rm -fr ~/.local/opt/oh-my-git`
* Delete the oh-my-git user config dir with a `rm -fr ~/.config/oh-my-git`

# Functions / variables added or modified in shell by Oh My Git

Shell variables:
```
$ ( set -o posix ; set ) > /tmp/a
$ source ~/Scripts/oh-my-git/prompt.sh
$ ( set -o posix ; set ) > /tmp/b
$ sdiff -s /tmp/a /tmp/b

							      >	OMG_CONDENSED=true
							      >	OMG_DIR=/home/yoann/Scripts/oh-my-git
							      >	OMG_ENABLE=true
							      >	OMG_LOADED=true
							      >	OMG_PREV_IS_GIT_REPO=true
							      >	OMG_PREV_STATUS_BAR=true
							      >	OMG_PS1_ORIGINAL='\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debi
							      >	OMG_REVERSE=true
							      >	OMG_STATUS_BAR=true
							      >	OMG_THEME=([omg_has_cached_deletions_symbol]="" [omg_detache
							      >	OMG_VIRTUAL_ENV_DISABLE=false
							      >	VIRTUAL_ENV_DISABLE_PROMPT=true
BASH_REMATCH=([0]="/")					      |	BASH_REMATCH=()
PROMPT_COMMAND='history -a; history -c; history -r'	      |	PROMPT_COMMAND='_oh_my_git; history -a; history -c; history -
```

Functions:

```
$ declare -F > /tmp/a
$ source ~/Scripts/oh-my-git/prompt.sh
$ declare -F > /tmp/b
$ sdiff -s /tmp/a /tmp/b
							      >	declare -f __oh_my_git_add2array
							      >	declare -f __oh_my_git_build_prompt
							      >	declare -f __oh_my_git_custom_build_prompt
							      >	declare -f __oh_my_git_enrich_append
							      >	declare -f __oh_my_git_get_current_action
							      >	declare -f __oh_my_git_init
							      >	declare -f __oh_my_git_init_prompt
							      >	declare -f __oh_my_git_load_config
							      >	declare -f __oh_my_git_reversearray
							      >	declare -f __oh_my_git_set_color
							      >	declare -f _oh_my_git


```