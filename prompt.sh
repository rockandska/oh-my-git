#!/usr/bin/env bash
#
# Collect Git repository informations
# Display those informations as a status bar if request
# Display those informations to a newline inside PS1 if request
# Could be used to provide those informations to another PS1 manager

declare -A OMG_THEME

: ${OMG_DISPLAY:=true}
: ${OMG_ENABLE:=true}
: ${OMG_CONDENSED:=true}
: ${OMG_REVERSE:=false}
: ${OMG_STATUS_BAR:=false}

: ${OMG_PS1_ORIGINAL:=$PS1}
: ${OMG_PROMPT:=}
: ${OMG_PROMPT_SIZE:=0}
: ${OMG_IS_GIT_REPO=false}
: ${OMG_PREV_IS_GIT_REPO:=false}

_omg_return_color() {

	local _return_var=${1:?var where to return result missing into ${FUNCNAME[0]} call}
	local _color
	local _background

	case "${2:?color missing into ${FUNCNAME[0]} call}" in
		"Black") _color="30";;
		"Blue") _color="34";;
		"Cyan") _color="36";;
		"Default") _color="39";;
		"Green") _color="32";;
		"Purple") _color="35";;
		"Red") _color="31";;
		"White") _color="37";;
		"Yellow") _color="33";;
		"LightBlack") _color="90";;
		"LightBlue") _color="94";;
		"LightCyan") _color="96";;
		"LightGreen") _color="92";;
		"LightPurple") _color="95";;
		"LightRed") _color="91";;
		"LightWhite") _color="97";;
		"LightYellow") _color="93";;
	esac

	case "${3:?background missing into ${FUNCNAME[0]} call}" in
		"Black") _background="40";;
		"Blue") _background="44";;
		"Cyan") _background="46";;
		"Default") _background="49";;
		"Green") _background="42";;
		"Purple") _background="45";;
		"Red") _background="41";;
		"White") _background="47";;
		"Yellow") _background="43";;
		"LightBlack") _background="100";;
		"LightBlue") _background="104";;
		"LightCyan") _background="106";;
		"LightGreen") _background="102";;
		"LightPurple") _background="105";;
		"LightRed") _background="101";;
		"LightWhite") _background="107";;
		"LightYellow") _background="103";;
	esac

	eval "${_return_var}=\"${_color};${_background}m\""
}

__oh_my_git_add2array() {
	local _array 
	local _values
	_array=${1:?Missing array name}
	shift
	for _values; do
		eval "${_array}+=(\"\${_values}\")"
	done
}

__oh_my_git_enrich_append() {
	local flag=${1:?flag missing into __oh_my_git_enrich_append call}
	local symbol="${2:?symbol missing into __oh_my_git_enrich_append call}"
	local color=${3:-}
	local attr=${4:-0}
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
	__oh_my_git_add2array omg_prompt "${reset}\e[${attr};${color:-}${symbol:-}${reset}"
}

__oh_my_git_reversearray() {
	local arrayname=${1:?Missing array name} array revarray e
	eval "array=( \"\${$arrayname[@]}\" )"
	for e in "${array[@]}"
	do
		revarray=( "$e" "${revarray[@]}" )
	done
	eval "$arrayname=( \"\${revarray[@]}\" )"
}

__oh_my_git_init_prompt() {
	local IFS OIFS
	local var=${1:?missing parameter in __oh_my_git_init_prompt call}

	if [[ ${OMG_REVERSE:?} == true ]];then
		__oh_my_git_reversearray omg_prompt
	fi

	OIFS=$IFS
	IFS=''
	eval "${var}=\"${omg_prompt[*]}\""
	omg_is_a_git_repo=${is_a_git_repo}
	IFS=$OIFS
}

__oh_my_git_custom_build_prompt() {
	local return_prompt=${1:?}; shift 1;
	local return_prompt_size=${1:?}; shift 1;
	local return_is_a_git_repo=${1:?}; shift 1;
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

	local omg_prompt=()
	local omg_prompt_size=0
	local omg_is_a_git_repo=false

	local reset='\e[0m'     # Text Reset]'

	if [[ ${is_a_git_repo:?} == true ]]; then

		#Theme Variables: Text Color + Background
		local left_side left_icon stash right_side right_icon omg_first_separator_color omg_last_separator_color

		_omg_return_color left_side ${OMG_THEME["left_side_color"]} ${OMG_THEME["left_side_bg"]}
		_omg_return_color right_side ${OMG_THEME["right_side_color"]} ${OMG_THEME["right_side_bg"]}

		_omg_return_color left_icon ${OMG_THEME["left_icon_color"]} ${OMG_THEME["left_side_bg"]}
		_omg_return_color right_icon ${OMG_THEME["right_icon_color"]} ${OMG_THEME["right_side_bg"]}

		_omg_return_color stash ${OMG_THEME["stash_color"]} ${OMG_THEME["left_side_bg"]}

		_omg_return_color omg_first_separator_color ${OMG_THEME["left_side_bg"]} ${OMG_THEME["right_side_bg"]}
		_omg_return_color omg_last_separator_color ${OMG_THEME["last_separator_color"]} ${OMG_THEME["last_separator_bg"]}

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
			__oh_my_git_enrich_append true ${omg_arrow_symbol:?} ${omg_first_separator_color:?}
		else
			__oh_my_git_enrich_append true ${omg_arrow_symbol:?} ${omg_first_separator_color:?}
		fi

		if [[ $detached == true ]]; then
			if [[ "${action:-}" = "rebase" ]]; then
				__oh_my_git_enrich_append $detached ${OMG_THEME["omg_rebase_interactive_symbol"]} "${right_icon:?}"
			elif [[ "${action:-}" = "bisect" ]] && [[ "${bisect_steps:?}" = "0" ]]; then
				__oh_my_git_enrich_append $detached ${OMG_THEME["$omg_bisect_done_symbol"]} "${right_icon:?}"
			elif [[ "${action:-}" = "bisect" ]] && [[ "${bisect_steps:?}" = "~0" ]]; then
				__oh_my_git_enrich_append $detached "${bisect_tested:?}/${bisect_total:?}" "${right_icon:?}"
				__oh_my_git_enrich_append $detached ${OMG_THEME["$omg_bisect_close_symbol"]} "${right_icon:?}"
				__oh_my_git_enrich_append $detached "${bisect_steps:?}" "${right_icon:?}"
			elif [[ "${action:-}" = "bisect" ]]; then
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

		if [[ ${VIRTUAL_ENV:-false} != false ]] && [[ ${OMG_NOPS1} == false ]]; then
			__oh_my_git_enrich_append true ${OMG_THEME["omg_is_virtualenv_symbol"]} "${right_icon:?}"
		fi

		__oh_my_git_enrich_append true ${omg_arrow_symbol:?} ${omg_last_separator_color:?}

	else
		__oh_my_git_enrich_append true "${OMG_PS1_ORIGINAL:?}"
	fi

	__oh_my_git_add2array omg_prompt ${reset:?}
	__oh_my_git_init_prompt ${return_prompt}
	eval "$return_prompt_size=\"$omg_prompt_size\""
	eval "$return_is_a_git_repo=\"$omg_is_a_git_repo\""
}

__oh_my_git_load_config() {
	if [[ ${OMG_LOADED:-false} == false ]] \
	   || [[ ${1:-} == 'reload' ]]; then 
		local PROGRAM_NAME="oh-my-git"
		local CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/$PROGRAM_NAME"
		[[ ! -d ${CONFIG_DIR:?} ]] && { mkdir -p ${CONFIG_DIR:?}; chmod 700 ${CONFIG_DIR:?}; }
		# Source default config file
		: ${OMG_DIR:="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"}
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
		OMG_LOADED=true
	fi
}

__oh_my_git_init() {
	local _return_omg_prompt=${1:?} && shift
	local _return_omg_prompt_size=${1:?} && shift
	local _return_omg_is_git_repo=${1:?} && shift
	local _return_omg_fill_prompt_size=${1:?} && shift

	: ${COLUMNS:=$(tput cols)}
	: ${LINES:=$(tput lines)}

	source ${OMG_DIR:?}/base.sh

	local _omg_build_prompt 
	local _omg_size_build_prompt
	local _is_a_git_repo_build_prompt
	__oh_my_git_build_prompt \
		_omg_build_prompt \
		_omg_size_build_prompt \
		_is_a_git_repo_build_prompt

	local _omg_fill_prompt_size_build_prompt
	_omg_fill_prompt_size_build_prompt="$((${COLUMNS:?} - ${_omg_size_build_prompt:=0} + 1))"

	# Fill the prompt if reverse mode
	if [[ ${OMG_REVERSE:?} == true && ${_omg_size_build_prompt:?} != "0" ]];then
		_omg_build_prompt="\033[${_omg_fill_prompt_size_build_prompt}G${_omg_build_prompt}"
	fi

	eval "${_return_omg_prompt}='${_omg_build_prompt}'"
	eval "${_return_omg_prompt_size}=\"${_omg_size_build_prompt}\""
	eval "${_return_omg_is_git_repo}=\"${_is_a_git_repo_build_prompt:=false}\""
	eval "${_return_omg_fill_prompt_size}=\"${_omg_fill_prompt_size_build_prompt:=false}\""
	return 0
}

__oh_my_git_display() {

	# Clean upper line
	if [[ ${OMG_IS_GIT_REPO:?} != ${OMG_PREV_IS_GIT_REPO:-${OMG_IS_GIT_REPO:?}} && ${OMG_PREV_STATUS_BAR:-} == true ]] \
		|| [[ ${OMG_STATUS_BAR:?} != ${OMG_PREV_STATUS_BAR:-${OMG_STATUS_BAR}} ]] \
		|| [[ ${OMG_DISPLAY:?} != ${OMG_PREV_DISPLAY:-${OMG_DISPLAY:?}} && ${OMG_PREV_STATUS_BAR:-} == true ]];then
		# only if we are not at the bottom of the terminal
		if [[ $(IFS=';' read -sdR -p $'\E[6n' ROW COL;echo "${ROW#*[}") -lt ${LINES:?} ]];then
			tput sc
			tput cup 0 0 # position cursor
			printf '%*s\n' "${COLUMNS:?}" ''
			tput rc # restore cursor.
		fi
	fi

	[[ ${OMG_STATUS_BAR:?} != ${OMG_PREV_STATUS_BAR:-} ]] && clear

	if [[ ${OMG_DISPLAY} == true ]];then
		local _venv_color
		_omg_return_color _venv_color ${OMG_THEME["venv_color"]} ${OMG_THEME["venv_bg"]}

		local _virtualenv=""
		if [[ ${VIRTUAL_ENV:-false} != false ]]; then
			_virtualenv="${venv_color}($(basename ${VIRTUAL_ENV:?}))\e[0m"
		fi

		local _ps1_prompt
		_ps1_prompt="${_virtualenv:-}${OMG_PS1_ORIGINAL:?}"

		if [[ ${OMG_IS_GIT_REPO:?} == true ]] && [[ ${OMG_ENABLE} == true ]]; then
			if [[ ${OMG_STATUS_BAR:?} == true ]];then
				# Press return if we are on first line
				[[ $(IFS=';' read -sdR -p $'\E[6n' ROW COL;echo "${ROW#*[}") -eq 1 ]] && echo -ne "\n"
				# STATUS BAR
				tput sc # position save cursor
				tput cup 0 0 # position cursor
				if [[ ${OMG_REVERSE:?} == false ]];then
					echo -ne "${OMG_PROMPT:?}"
				else
					printf '%*b' "${omg_fill_prompt_size}" "${OMG_PROMPT:?}"
				fi
				tput rc # restore cursor.
				PS1="${_ps1_prompt:?}"
			else
				PS1="${OMG_PROMPT:?}\n"${_ps1_prompt:?}
			fi
		else
			PS1=${_ps1_prompt}
		fi
	else
		PS1=${OMG_PS1_ORIGINAL}
	fi

	OMG_PREV_IS_GIT_REPO=${OMG_IS_GIT_REPO:?}
	OMG_PREV_STATUS_BAR=${OMG_STATUS_BAR:?}
	OMG_PREV_DISPLAY=${OMG_DISPLAY:?}

}

#oh_my_git_fillps1() {
#	local bg_color=$1                  # Set the background color
#	local fg_color=$2                  # Set the foregropund color
#	local fill_separator="${3:- }"	   # Fill the line with the character
#	local fill_size="${4:-$((${COLUMNS:=$(tput cols)} - 1))}"	   # Fill the line with the character
#	PS1+=$(section_end $fg_color $bg_color)
#	PS1+=$(section_content $fg_color $bg_color "$(printf "%${fill_size}s" | tr ' ' "${fill_separator}")")
#	__last_color=$bg_color
#	PS1+=$(section_end $__last_color 'Default')
#	PS1+="\033[0G"
#}

oh_my_git_pureline() {
	local bg_color=${1:-Default}                  			# Set the filling background color
	local fg_color=${2:-Default}					# Set the filling foregropund color
	local fill_separator="${3:- }"	   				# Fill the line with the character
	local content

	local omg_fill_prompt_size
	__oh_my_git_load_config

	OMG_STATUS_BAR=false;


	if [[ "$OMG_REVERSE" == true ]];then
		OMG_THEME["last_separator_bg"]="${bg_color}"
		OMG_THEME["last_separator_color"]="${OMG_THEME["right_side_bg"]}"
		__oh_my_git_init OMG_PROMPT OMG_PROMPT_SIZE OMG_IS_GIT_REPO omg_fill_prompt_size
		if [[ "${OMG_IS_GIT_REPO:?}" == true ]] && [[ ${OMG_ENABLE} == true ]];then
			PS1="${colors[${fg_color}]}${colors[On_${bg_color}]}$(printf "%$((${COLUMNS:=$(tput cols)} - 1))s" | tr ' ' "${fill_separator}")${colors[${bg_color}]}${colors['On_Default']}${symbols[hard_separator]}${OMG_PROMPT}\033[0G${PS1}"
		else
			PS1="${colors[${fg_color}]}${colors[On_${bg_color}]}$(printf "%$((${COLUMNS:=$(tput cols)} - 1))s" | tr ' ' "${fill_separator}")${colors[${bg_color}]}${colors['On_Default']}${symbols[hard_separator]}\033[0G${PS1}"
		fi
	else
		__oh_my_git_init OMG_PROMPT OMG_PROMPT_SIZE OMG_IS_GIT_REPO omg_fill_prompt_size
		if [[ "${OMG_IS_GIT_REPO:?}" == true ]] && [[ ${OMG_ENABLE} == true ]];then
			PS1+=$(section_end ${OMG_THEME["left_side_color"]} ${OMG_THEME["left_side_bg"]})
			OMG_PROMPT=${OMG_PROMPT%${OMG_THEME["omg_right_arrow_symbol"]}*}
			PS1+=$(section_content $fg_color ${OMG_THEME["right_side_bg"]} "${OMG_PROMPT}\e[0m")
			__last_color=${OMG_THEME["right_side_bg"]}
		fi
		PS1="${colors[${fg_color}]}${colors[On_${bg_color}]}$(printf "%$((${COLUMNS:=$(tput cols)} - 1))s" | tr ' ' "${fill_separator}")${colors[${bg_color}]}${colors['On_Default']}${symbols[hard_separator]}\033[0G${PS1}"
	fi
}

oh_my_git() {
	if [ -n "${BASH_VERSION:-}" ]; then

		case "${1}" in
			reload)
				__oh_my_git_load_config ${1-};
				return 0;;
			enable)
				[[ ! $PROMPT_COMMAND =~ 'oh_my_git;' ]] && PROMPT_COMMAND="oh_my_git; $PROMPT_COMMAND";
				return 0;;
			disable)
				PS1=${OMG_PS1_ORIGINAL};
				PROMPT_COMMAND=${PROMPT_COMMAND/oh_my_git; /};
				return 0;;
		esac

		local omg_fill_prompt_size
		__oh_my_git_load_config;
		__oh_my_git_init OMG_PROMPT OMG_PROMPT_SIZE OMG_IS_GIT_REPO omg_fill_prompt_size
		__oh_my_git_display;
	fi
}
