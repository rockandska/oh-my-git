__oh_my_git_init() {

	local omg_prompt=()
	local omg_prompt_size=0
	local omg_is_a_git_repo=false

	### FUNCTION DEFINITIONS ###
	function __oh_my_git_custom_build_prompt {
		local var=${1:?}; shift 1;
		local enabled=${1:?}; shift 1;
		local current_commit_hash=${1:-}; shift 1;
		local is_a_git_repo=${1:?}; shift 1;
		local current_branch=${1:-}; shift 1;
		local detached=${1:?}; shift 1;
		local just_init=${1:?}; shift 1;
		local has_upstream=${1:?}; shift 1;
		local has_modifications=${1:?}; shift 1;
		local has_modifications_cached=${1:?}; shift 1;
		local has_adds=${1:?}; shift 1;
		local has_deletions=${1:?}; shift 1;
		local has_deletions_cached=${1:?}; shift 1;
		local has_renames=${1:?}; shift 1;
		local has_untracked_files=${1:?}; shift 1;
		local ready_to_commit=${1:?}; shift 1;
		local tags_at_current_commit=${1:-}; shift 1;
		local has_upstream=${1:?}; shift 1;
		local commits_ahead=${1:?}; shift 1;
		local commits_behind=${1:?}; shift 1;
		local has_diverged=${1:?}; shift 1;
		local should_push=${1:?}; shift 1;
		local will_rebase=${1:?}; shift 1;
		local has_stashes=${1:?}; shift 1;
		local bisect_remain=${1:-}; shift 1;
		local bisect_total=${1:-}; shift 1;
		local bisect_steps=${1:-}; shift 1;
		local submodules_outdated=${1:?}; shift 1;
		local action=${1:-}; shift 1;

		if [[ ${is_a_git_repo:?} == true ]]; then

			#Theme Variables: Text Color + Background
			local left_side left_icon stash right_side right_icon omg_first_separator_color omg_last_separator_color

			__oh_my_git_set_color left_side ${OMG_THEME["left_side_color"]} ${OMG_THEME["left_side_bg"]}
			__oh_my_git_set_color right_side ${OMG_THEME["right_side_color"]} ${OMG_THEME["right_side_bg"]}

			__oh_my_git_set_color left_icon ${OMG_THEME["left_icon_color"]} ${OMG_THEME["left_side_bg"]}
			__oh_my_git_set_color right_icon ${OMG_THEME["right_icon_color"]} ${OMG_THEME["right_side_bg"]}

			__oh_my_git_set_color stash ${OMG_THEME["stash_color"]} ${OMG_THEME["left_side_bg"]}

			__oh_my_git_set_color omg_first_separator_color ${OMG_THEME["left_side_bg"]} ${OMG_THEME["right_side_bg"]}
			__oh_my_git_set_color omg_last_separator_color ${OMG_THEME["right_side_bg"]} ${OMG_THEME["default_bg"]}

			local omg_arrow_symbol

			if [[ ${OMG_REVERSE:?} == false ]];then
				omg_arrow_symbol=${OMG_THEME["omg_right_arrow_symbol"]}
			else
				omg_arrow_symbol=${OMG_THEME["omg_left_arrow_symbol"]}
			fi

			# on filesystem
			local repo_status_symbol
			if [[ ${submodules_outdated:?} == true ]]; then
				repo_status_symbol=${OMG_THEME["omg_submodules_outdated_symbol"]}
			else
				repo_status_symbol=${OMG_THEME["omg_is_a_git_repo_symbol"]}
			fi

			__oh_my_git_add2array omg_prompt ${reset:?}

			__oh_my_git_enrich_append true $repo_status_symbol "${left_side:?}"
			__oh_my_git_enrich_append $has_stashes ${OMG_THEME["omg_has_stashes_symbol"]} "${stash:?}"
			__oh_my_git_enrich_append $has_untracked_files ${OMG_THEME["omg_has_untracked_files_symbol"]} "${left_icon}"
			__oh_my_git_enrich_append $has_modifications ${OMG_THEME["omg_has_modifications_symbol"]} "${left_icon}"
			__oh_my_git_enrich_append $has_deletions ${OMG_THEME["omg_has_deletions_symbol"]} "${left_icon:?}"

			if [[ ${OMG_CONDENSED:?} == true ]] \
				&& {	[[ ${has_adds:?} == true ]] \
					|| [[ ${has_deletions_cached:?} == true ]] \
					|| [[ ${has_renames:?} == true ]]; };then
				local has_modifications_cached
				has_modifications_cached=true
				__oh_my_git_enrich_append $has_modifications_cached ${OMG_THEME["omg_has_cached_modifications_symbol"]} "${left_icon:?}"
			else
				__oh_my_git_enrich_append $has_adds ${OMG_THEME["omg_has_adds_symbol"]} "${left_icon:?}"
				__oh_my_git_enrich_append $has_renames ${OMG_THEME["omg_has_renames_symbol"]} "${left_icon:?}"
				__oh_my_git_enrich_append $has_modifications_cached ${OMG_THEME["omg_has_cached_modifications_symbol"]} "${left_icon:?}"
				__oh_my_git_enrich_append $has_deletions_cached ${OMG_THEME["omg_has_cached_deletions_symbol"]} "${left_icon:?}"
			fi

			# next operation
			__oh_my_git_enrich_append $ready_to_commit ${OMG_THEME["omg_ready_to_commit_symbol"]} "${left_icon:?}"

			# where
			if [[ ${OMG_REVERSE:?} == false ]];then
				__oh_my_git_enrich_append true ${omg_arrow_symbol:?} ${omg_first_separator_color:?} ${left_icon:?}
			else
				__oh_my_git_enrich_append true ${omg_arrow_symbol:?} ${omg_first_separator_color:?} ${left_icon:?}
			fi

			if [[ $detached == true ]]; then
				if [[ "${action:?}" = "rebase" ]]; then
					__oh_my_git_enrich_append $detached ${OMG_THEME["omg_rebase_interactive_symbol"]} "${right_icon:?}"
				elif [[ "${action:?}" = "bisect" ]] && [[ "${bisect_steps:?}" = "0" ]]; then
					__oh_my_git_enrich_append $detached ${OMG_THEME["$omg_bisect_done_symbol"]} "${right_icon:?}"
				elif [[ "${action:?}" = "bisect" ]] && [[ "${bisect_steps:?}" = "~0" ]]; then
					__oh_my_git_enrich_append $detached "${bisect_tested:?}/${bisect_total:?}" "${right_icon:?}"
					__oh_my_git_enrich_append $detached ${OMG_THEME["$omg_bisect_close_symbol"]} "${right_icon:?}"
					__oh_my_git_enrich_append $detached "${bisect_steps:?}" "${right_icon:?}"
				elif [[ "${action:?}" = "bisect" ]]; then
					__oh_my_git_enrich_append $detached "${bisect_tested:?}/${bisect_total:?}" ${right_icon:?}
					__oh_my_git_enrich_append $detached ${OMG_THEME["omg_bisect_symbol"]} "${right_icon:?}"
					__oh_my_git_enrich_append $detached "${bisect_steps:?}" "${right_icon:?}"
				else
					__oh_my_git_enrich_append $detached ${OMG_THEME["omg_detached_symbol"]} "${right_icon:?}"
				fi
				__oh_my_git_enrich_append $detached "(${current_commit_hash:0:7})" "${right_side:?}"
			else
				if [[ $has_upstream == false ]]; then
					__oh_my_git_enrich_append true " -- " ${right_side:?}
					__oh_my_git_enrich_append true ${OMG_THEME["omg_not_tracked_branch_symbol"]} ${right_side:?}
					__oh_my_git_enrich_append true " -- " ${right_side:?}
					__oh_my_git_enrich_append true "(${current_branch:?})" ${right_side:?}
				else
					local type_of_upstream
					if [[ $will_rebase == true ]]; then
						local type_of_upstream=${OMG_THEME["omg_rebase_tracking_branch_symbol"]}
					else
						local type_of_upstream=${OMG_THEME["omg_merge_tracking_branch_symbol"]}
					fi

					if [[ $has_diverged == true ]]; then
						__oh_my_git_enrich_append true " -${commits_behind:?} " ${right_side:?}
						__oh_my_git_enrich_append true ${OMG_THEME["omg_has_diverged_symbol"]} ${right_side:?}
						__oh_my_git_enrich_append true " +${commits_ahead:?} " ${right_icon:?}
					else
						if [[ $commits_behind -gt 0 ]]; then
							__oh_my_git_enrich_append true " -${commits_behind:?} " ${right_side:?}
							__oh_my_git_enrich_append true ${OMG_THEME["omg_can_fast_forward_symbol"]} ${right_icon:?}
							__oh_my_git_enrich_append true " -- " ${right_side:?}
						fi
						if [[ $commits_ahead -gt 0 ]]; then
							__oh_my_git_enrich_append true " -- " ${right_side:?}
							__oh_my_git_enrich_append true ${OMG_THEME["omg_should_push_symbol"]} ${right_icon:?}
							__oh_my_git_enrich_append true " +${commits_ahead:?} " ${right_side:?}
						fi
						if [[ $commits_ahead == 0 && $commits_behind == 0 ]]; then
							__oh_my_git_enrich_append true ' -- ' ${right_side:?}
							__oh_my_git_enrich_append true ' -- ' ${right_side:?}
						fi
					fi
					__oh_my_git_enrich_append true "(${current_branch:?} ${type_of_upstream:?} ${upstream//\/$current_branch/})" ${right_side:?}
				fi
			fi

			if [[ -n ${tags_at_current_commit:-} ]];then
				for tag in ${tags_at_current_commit:?}; do
					__oh_my_git_enrich_append true ${OMG_THEME["omg_is_on_a_tag_symbol"]} ${right_side:?}
					__oh_my_git_enrich_append true "${tag:?}" ${right_side:?}
				done
			fi

			if [[ ${VIRTUAL_ENV:-false} != false ]] && [[ ${OMG_VIRTUAL_ENV_DISABLE} != true ]]; then
				__oh_my_git_enrich_append true ${OMG_THEME["omg_is_virtualenv_symbol"]} "${right_icon:?}"
			fi

			__oh_my_git_enrich_append true ${omg_arrow_symbol:?} ${omg_last_separator_color:?}

		else
			__oh_my_git_enrich_append true "${OMG_PS1_ORIGINAL:?}"
		fi

		__oh_my_git_add2array omg_prompt ${reset:?}
		__oh_my_git_init_prompt ${var}

	}

	function __oh_my_git_add2array {
		local array values
		array=${1:?Missing array name}
		shift

		for values; do
			eval "$array+=(\"\$values\")"
		done
	}

	function __oh_my_git_enrich_append {
		local flag=${1:?flag missing into __oh_my_git_enrich_append call}
		local symbol="${2:?symbol missing into __oh_my_git_enrich_append call}"
		local color=${3:-}
		if [[ $flag == false ]];then
			if [[ ${OMG_CONDENSED:?} == true ]];then
				symbol=''
			else
				symbol='  '
			fi
		fi
		if [[ ${#symbol} -eq 1 ]] && [[ ${symbol:-} !=  "${omg_arrow_symbol:?}" ]] ;then
			symbol="${symbol:-} "
		fi
		((omg_prompt_size+=${#symbol}))
		__oh_my_git_add2array omg_prompt "${reset}${color:-}${symbol:-}${reset}"
	}

	function __oh_my_git_reversearray {
		local arrayname=${1:?Missing array name} array revarray e
		eval "array=( \"\${$arrayname[@]}\" )"
		for e in "${array[@]}"
		do
			revarray=( "$e" "${revarray[@]}" )
		done
		eval "$arrayname=( \"\${revarray[@]}\" )"
	}

	function __oh_my_git_set_color {
		local var=${1:?parameter missing into __oh_my_git_set_color call}
		local color background

		case "${2:?color missing into __oh_my_git_set_color call}" in
			"black") color="30";;
			"blue") color="34";;
			"cyan") color="36";;
			"green") color="32";;
			"purple") color="35";;
			"red") color="31";;
			"white") color="37";;
			"yellow") color="33";;
			"bright_black") color="30;1";;
			"bright_blue") color="34;1";;
			"bright_cyan") color="36;1";;
			"bright_green") color="32;1";;
			"bright_purple") color="35;1";;
			"bright_red") color="31;1";;
			"bright_white") color="37;1";;
			"bright_yellow") color="33;1";;
		esac

		case "${3:?background missing into __oh_my_git_set_color call}" in
			"black") background="40";;
			"blue") background="44";;
			"cyan") background="46";;
			"green") background="42";;
			"purple") background="45";;
			"red") background="41";;
			"white") background="47";;
			"yellow") background="43";;
			"bright_black") background="100";;
			"bright_blue") background="104";;
			"bright_cyan") background="106";;
			"bright_green") background="102";;
			"bright_purple") background="105";;
			"bright_red") background="101";;
			"bright_white") background="107";;
			"bright_yellow") background="103";;
		esac

		local attr=${4:-0}
		eval "$var=\"\e[${attr};${color};${background}m\""
	}

	function __oh_my_git_init_prompt {
		local IFS OIFS
		local var=${1:?missing paramaeter in __oh_my_git_init_prompt call}

		if [[ ${OMG_REVERSE:?} == true ]];then
			__oh_my_git_reversearray omg_prompt
		fi

		OIFS=$IFS
		IFS=''
		eval "${var}=\"${omg_prompt[*]}\""
		omg_is_a_git_repo=${is_a_git_repo}
		IFS=$OIFS
	}

	#### START ###
	if [ -n "${BASH_VERSION:-}" ]; then
		source ${OMG_DIR:?}/base.sh

		local reset='\e[0m'     # Text Reset]'
		local PS1_PROMPT

		__oh_my_git_build_prompt PS1_PROMPT

	fi

	OMG_PS1_PROMPT="${PS1_PROMPT:?}"
	OMG_PS1_PROMPT_SIZE="${omg_prompt_size:?}"
	OMG_IS_GIT_REPO="${omg_is_a_git_repo:?}"
	return 0
}

__oh_my_git_load_config() {
	local PROGRAM_NAME="oh-my-git"
	local CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/$PROGRAM_NAME"
	mkdir -p ${CONFIG_DIR:?}
	chmod 700 ${CONFIG_DIR:?}
	# Source default config file
	source ${OMG_DIR:?}/default.cfg.bash
	shopt -s nullglob
	shopt -s dotglob
	# Source user config files
	local config_files f
	config_files=(${CONFIG_DIR:?}/*.bash)
	(( ${#config_files[*]} )) && \
		for f in ${config_files[*]};do
			source $f
		done
	shopt -u nullglob
	shopt -u dotglob
}

_oh_my_git() {

	# Loading config once by "sourcing"
	if [[ ${OMG_LOADED:-false} == false ]] \
	   || [[ ${1:-} == 'reload' ]] \
	   || [[ ${OMG_ENABLE:-} == "" ]];then
		OMG_LOADED=true
		__oh_my_git_load_config
		clear
	fi

	local OMG_PS1_PROMPT OMG_PS1_PROMPT_SIZE OMG_IS_GIT_REPO
	__oh_my_git_init

	local venv_color
	__oh_my_git_set_color venv_color ${OMG_THEME["venv_color"]} ${OMG_THEME["venv_bg"]}

	local virtualenv=""
	if [[ ${VIRTUAL_ENV:-false} != false ]] && [[ ${OMG_VIRTUAL_ENV_DISABLE:?} != true ]]; then
		virtualenv="${venv_color}($(basename ${VIRTUAL_ENV:?}))\e[0m"
	fi

	local PS1_PROMPT
	PS1_PROMPT=${virtualenv:-}${OMG_PS1_ORIGINAL:?}

	[[ ${OMG_STATUS_BAR:?} != ${OMG_PREV_STATUS_BAR:=false} ]] && clear

	if [[ ${OMG_IS_GIT_REPO:?} == true ]]; then

		: ${COLUMNS:=$(tput cols)}

		if [[ ${OMG_STATUS_BAR:?} == true ]];then
			[[ $(IFS=';' read -sdR -p $'\E[6n' ROW COL;echo "${ROW#*[}") -eq 1 ]] && echo -ne "\n"
			# STATUS BAR
			tput sc
			tput cup 0 0 # position cursor
			if [[ ${OMG_REVERSE:?} == false ]];then
				echo -ne "${OMG_PS1_PROMPT:?}"
				printf '%*s' "$((${COLUMNS:?} - ${OMG_PS1_PROMPT_SIZE:?}))"
			else
				printf '%*s' "$((${COLUMNS:?} - ${OMG_PS1_PROMPT_SIZE:?}))"
				echo -e "${OMG_PS1_PROMPT:?}"
			fi
			tput rc # restore cursor.
		else
			# REVERSE MODE
			if [[ ${OMG_REVERSE:?} == true ]];then
				PS1_PROMPT=$(printf '%*s' "$((${COLUMNS:?} - ${OMG_PS1_PROMPT_SIZE:?}))")${OMG_PS1_PROMPT:?}"\n"${PS1_PROMPT}
			else
				PS1_PROMPT=${OMG_PS1_PROMPT:?}"\n"${PS1_PROMPT:?}
			fi
		fi
	else
		if [[ ${OMG_IS_GIT_REPO:?} != ${OMG_PREV_IS_GIT_REPO:-false} ]] && [[ ${OMG_STATUS_BAR:?} == true ]];then
				tput sc
				tput cup 0 0 # position cursor
				printf '%*s\n' "${COLUMNS:?}" ''
				tput rc # restore cursor.
		fi
	fi

	PS1=${PS1_PROMPT:?}
	OMG_PREV_IS_GIT_REPO=${OMG_IS_GIT_REPO:-false}
	OMG_PREV_STATUS_BAR=${OMG_STATUS_BAR:-false}
}

: ${OMG_DIR:="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"}
: ${OMG_PS1_ORIGINAL:=$PS1}
: ${OMG_LOADED:=false}
: ${VIRTUAL_ENV_DISABLE_PROMPT:=true}


# Config variable
OMG_ENABLE=""
OMG_CONDENSED=""
OMG_REVERSE=""
OMG_STATUS_BAR=""
OMG_VIRTUAL_ENV_DISABLE=""

declare -A OMG_THEME

OMG_THEME["left_side_color"]=""
OMG_THEME["left_side_bg"]=""
OMG_THEME["left_icon_color"]=""
OMG_THEME["stash_color"]=""
OMG_THEME["right_side_color"]=""
OMG_THEME["right_side_bg"]=""
OMG_THEME["right_icon_color"]=""
OMG_THEME["default_bg"]=""
OMG_THEME["venv_color"]=""
OMG_THEME["venv_bg"]=""
OMG_THEME["omg_is_a_git_repo_symbol"]=""
OMG_THEME["omg_submodules_outdated_symbol"]=""
OMG_THEME["omg_has_untracked_files_symbol"]=""
OMG_THEME["omg_has_adds_symbol"]=""
OMG_THEME["omg_has_deletions_symbol"]=""
OMG_THEME["omg_has_cached_deletions_symbol"]=""
OMG_THEME["omg_has_renames_symbol"]=""
OMG_THEME["omg_has_modifications_symbol"]=""
OMG_THEME["omg_has_cached_modifications_symbol"]=""
OMG_THEME["omg_ready_to_commit_symbol"]=""
OMG_THEME["omg_is_on_a_tag_symbol"]=""
OMG_THEME["omg_needs_to_merge_symbol"]=""
OMG_THEME["omg_detached_symbol"]=""
OMG_THEME["omg_can_fast_forward_symbol"]=""
OMG_THEME["omg_has_diverged_symbol"]=""
OMG_THEME["omg_not_tracked_branch_symbol"]=""
OMG_THEME["omg_rebase_tracking_branch_symbol"]=""
OMG_THEME["omg_rebase_interactive_symbol"]=""
OMG_THEME["omg_bisect_symbol"]=""
OMG_THEME["omg_bisect_close_symbol"]=""
OMG_THEME["omg_bisect_done_symbol"]=""
OMG_THEME["omg_merge_tracking_branch_symbol"]=""
OMG_THEME["omg_should_push_symbol"]=""
OMG_THEME["omg_has_stashes_symbol"]=""
OMG_THEME["omg_right_arrow_symbol"]=""
OMG_THEME["omg_left_arrow_symbol"]=""
OMG_THEME["omg_is_virtualenv_symbol"]=""

trap "_oh_my_git reload" SIGWINCH

[[ ! $PROMPT_COMMAND =~ '_oh_my_git' ]] && PROMPT_COMMAND="_oh_my_git; $PROMPT_COMMAND"

