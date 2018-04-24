__oh_my_git_init() (

	local omg_prompt=()
	local omg_prompt_size=0
	local omg_is_a_git_repo=false

	### FUNCTION DEFINITIONS ###
	function __omg_custom_build_prompt {
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

		local is_virtualenv="${VIRTUAL_ENV:-false}"
		local virtualenv=""
		if [[ $is_virtualenv != false ]]; then
			virtualenv=$(basename ${VIRTUAL_ENV:?})
		fi

		#Theme Variables: Text Color + Background
		local left_side left_icon stash right_side right_icon omg_first_separator_color omg_last_separator_color

		__omg_set_color left_side ${OMG_THEME["left_side_color"]} ${OMG_THEME["left_side_bg"]}
		__omg_set_color left_icon ${OMG_THEME["left_icon_color"]} ${OMG_THEME["left_side_bg"]}
		__omg_set_color stash ${OMG_THEME["stash_color"]} ${OMG_THEME["left_side_bg"]}
		__omg_set_color right_side ${OMG_THEME["right_side_color"]} ${OMG_THEME["right_side_bg"]}
		__omg_set_color right_icon ${OMG_THEME["right_icon_color"]} ${OMG_THEME["right_side_bg"]}
		__omg_set_color omg_first_separator_color ${OMG_THEME["right_icon_color"]} ${OMG_THEME["right_side_bg"]}
		__omg_set_color omg_last_separator_color ${OMG_THEME["right_side_bg"]} ${OMG_THEME["default_bg"]}

		local omg_arrow_symbol

		if [[ ${OMG_REVERSE:?} -eq 0 ]];then
			omg_arrow_symbol=${omg_right_arrow_symbol:?}
		else
			omg_arrow_symbol=${omg_left_arrow_symbol:?}
		fi

		if [[ ${is_a_git_repo:?} == true ]]; then

			# on filesystem
			if [[ ${submodules_outdated:?} == true ]]; then
				repo_status_symbol=${omg_submodules_outdated_symbol:?}
			else
				repo_status_symbol=${omg_is_a_git_repo_symbol:?}
			fi

			__oh_my_git_add2array omg_prompt ${reset:?}

			__omg_enrich_append true $repo_status_symbol ${left_side:?}
			__omg_enrich_append $has_stashes $omg_has_stashes_symbol "${stash:?}"
			__omg_enrich_append $has_untracked_files $omg_has_untracked_files_symbol "${left_icon}"
			__omg_enrich_append $has_modifications $omg_has_modifications_symbol "${left_icon}"
			__omg_enrich_append $has_deletions $omg_has_deletions_symbol "${left_icon:?}"

			if [[ ${OMG_CONDENSED:?} == true ]] \
				&& {	[[ ${has_adds:?} == true ]] \
					|| [[ ${has_deletions_cached:?} == true ]] \
					|| [[ ${has_renames:?} == true ]]; };then
				has_modifications_cached=true
				__omg_enrich_append $has_modifications_cached $omg_has_cached_modifications_symbol "${left_icon:?}"
			else
				__omg_enrich_append $has_adds $omg_has_adds_symbol "${left_icon:?}"
				__omg_enrich_append $has_renames $omg_has_renames_symbol "${left_icon:?}"
				__omg_enrich_append $has_modifications_cached $omg_has_cached_modifications_symbol "${left_icon:?}"
				__omg_enrich_append $has_deletions_cached $omg_has_cached_deletions_symbol "${left_icon:?}"
			fi

			# next operation
			__omg_enrich_append $ready_to_commit $omg_ready_to_commit_symbol "${left_icon:?}"

			# where
			if [[ ${OMG_REVERSE:?} -eq 0 ]];then
				__omg_enrich_append true ${omg_arrow_symbol:?} ${omg_first_separator_color:?}
			else
				__omg_enrich_append true ${omg_arrow_symbol:?} ${omg_first_separator_color:?} ${left_icon:?}
			fi

			if [[ $detached == true ]]; then
				if [[ "${action:?}" = "rebase" ]]; then
					__omg_enrich_append $detached $omg_rebase_interactive_symbol "${right_icon:?}"
				elif [[ "${action:?}" = "bisect" ]] && [[ "${bisect_steps:?}" = "0" ]]; then
					__omg_enrich_append $detached "$omg_bisect_done_symbol" "${right_icon:?}"
				elif [[ "${action:?}" = "bisect" ]] && [[ "${bisect_steps:?}" = "~0" ]]; then
					__omg_enrich_append $detached "${bisect_tested:?}/${bisect_total:?}" "${right_icon:?}"
					__omg_enrich_append $detached "$omg_bisect_close_symbol" "${right_icon:?}"
					__omg_enrich_append $detached "${bisect_steps:?}" "${right_icon:?}"
				elif [[ "${action:?}" = "bisect" ]]; then
					__omg_enrich_append $detached "${bisect_tested:?}/${bisect_total:?}"
					__omg_enrich_append $detached $omg_bisect_symbol "${right_icon:?}"
					__omg_enrich_append $detached "${bisect_steps:?}" "${right_icon:?}"
				else
					__omg_enrich_append $detached $omg_detached_symbol "${right_icon:?}"
				fi
				__omg_enrich_append $detached "(${current_commit_hash:0:7})" "${right_side:?}"
			else
				if [[ $has_upstream == false ]]; then
					__omg_enrich_append true " -- " ${right_side:?}
					__omg_enrich_append true ${omg_not_tracked_branch_symbol:?} ${right_side:?}
					__omg_enrich_append true " -- " ${right_side:?}
					__omg_enrich_append true "(${current_branch:?})" ${right_side:?}
				else
					if [[ $will_rebase == true ]]; then
						local type_of_upstream=$omg_rebase_tracking_branch_symbol
					else
						local type_of_upstream=$omg_merge_tracking_branch_symbol
					fi

					if [[ $has_diverged == true ]]; then
						__omg_enrich_append true " -${commits_behind:?} " ${right_side:?} 
						__omg_enrich_append true "${omg_has_diverged_symbol:?}" ${right_side:?}
						__omg_enrich_append true " +${commits_ahead:?} " ${right_icon:?}
					else
						if [[ $commits_behind -gt 0 ]]; then
							__omg_enrich_append true " -${commits_behind:?} " ${right_side:?} 
							__omg_enrich_append true "${omg_can_fast_forward_symbol:?}" ${right_icon:?}
							__omg_enrich_append true " -- " ${right_side:?}
						fi
						if [[ $commits_ahead -gt 0 ]]; then
							__omg_enrich_append true " -- " ${right_side:?}
							__omg_enrich_append true "${omg_should_push_symbol:?}" ${right_icon:?}
							__omg_enrich_append true " +${commits_ahead:?} " ${right_side:?}
						fi
						if [[ $commits_ahead == 0 && $commits_behind == 0 ]]; then
							__omg_enrich_append true " --    -- " ${right_side:?}
						fi
					fi
					__omg_enrich_append true "(${current_branch:?} ${type_of_upstream:?} ${upstream//\/$current_branch/})" ${right_side:?}
				fi
			fi

			if [[ -n ${tags_at_current_commit:-} ]];then
				for tag in ${tags_at_current_commit:?}; do
					__omg_enrich_append true "${omg_is_on_a_tag_symbol:?}" ${right_side:?}
					__omg_enrich_append true "${tag:?}" ${right_side:?}
				done
			fi

			if [[ ${is_virtualenv:?} != false ]]; then
				__omg_enrich_append ${is_virtualenv:?} "${omg_is_virtualenv_symbol:?}" "${right_icon:?}"
				__omg_enrich_append ${is_virtualenv:?} "${virtualenv:-}" "${right_icon:?}"
			fi
			__omg_enrich_append true ${omg_arrow_symbol:?} ${omg_last_separator_color:?}
			__omg_enrich_append true "$(eval_prompt_callback_if_present)"

		else
			__omg_enrich_append true "$(eval_prompt_callback_if_present)"
			__omg_enrich_append true "${OMG_PS1_ORIGINAL:?}"
			if [[ ${is_virtualenv:?} != false ]]; then
				__omg_enrich_append true "${virtualenv:?}${omg_is_virtualenv_symbol:?}"
			fi
		fi

		__oh_my_git_add2array omg_prompt ${reset:?}
		__oh_my_git_init_prompt

	}

	function __oh_my_git_add2array {
		local array values
		array=${1:?Missing array name}
		shift

		for values; do
			eval "$array+=(\"\$values\")"
		done
	}

	function __omg_enrich_append {
		local flag=${1:?}
		local symbol="${2:-}"
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

	function __omg_set_color {
		local var=${1:?}
		local color=${colors_array[$2]}
		local background=${backgrounds_array[$3]}
		local attr=${4:-0}
		eval "$var=\"\e[${attr};${color};${background}m\""
	}

	function __oh_my_git_init_prompt {
		local IFS OIFS

		if [[ ${OMG_REVERSE:?} -eq 1 ]];then
			__oh_my_git_reversearray omg_prompt
		fi

		OIFS=$IFS
		IFS=''
		PS1_PROMPT="${omg_prompt[*]}"
		omg_is_a_git_repo=${is_a_git_repo}
		IFS=$OIFS
	}

	#### START ###
	if [[ ${OMG_ENABLE:?} -eq 1 ]];then
		if [ -n "${BASH_VERSION:-}" ]; then
			local DIR
			DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
			source ${DIR:?}/base.sh

			: local ${omg_is_a_git_repo_symbol:=''}
			: local ${omg_submodules_outdated_symbol:=''}
			: local ${omg_has_untracked_files_symbol:=''}        #                ?    
			: local ${omg_has_adds_symbol:=''}
			: local ${omg_has_deletions_symbol:=''}
			: local ${omg_has_cached_deletions_symbol:=''}
			: local ${omg_has_renames_symbol:='➔'}                # 
			: local ${omg_has_modifications_symbol:=''}
			: local ${omg_has_cached_modifications_symbol:=''}
			: local ${omg_ready_to_commit_symbol:=''}            #   →
			: local ${omg_is_on_a_tag_symbol:=''}                #       
			: local ${omg_needs_to_merge_symbol:=''}             # ᄉ
			: local ${omg_detached_symbol:=''}                  #   
			: local ${omg_can_fast_forward_symbol:=''}
			: local ${omg_has_diverged_symbol:=''}               #   
			: local ${omg_not_tracked_branch_symbol:=''}        #   
			: local ${omg_rebase_tracking_branch_symbol:=''}     #   
			: local ${omg_rebase_interactive_symbol:=''}
			: local ${omg_bisect_symbol:=''}
			: local ${omg_bisect_close_symbol:=''}
			: local ${omg_bisect_done_symbol:=''}
			: local ${omg_merge_tracking_branch_symbol:=''}      #  
			: local ${omg_should_push_symbol:=''}                #    
			: local ${omg_has_stashes_symbol:=''}
			: local ${omg_right_arrow_symbol:=''}
			: local ${omg_left_arrow_symbol:=''}
			: local ${omg_is_virtualenv_symbol:=''}
			local reset='\e[0m'     # Text Reset]'
			local colors_array backgrounds_array

			declare -A colors_array=(
				["black"]=30
				["blue"]=34
				["cyan"]=36
				["green"]=32
				["purple"]=35
				["red"]=31
				["white"]=37
				["yellow"]=33
				["bright_black"]='30;1'
				["bright_blue"]='34;1'
				["bright_cyan"]='36;1'
				["bright_green"]='32;1'
				["bright_purple"]='35;1'
				["bright_red"]='31;1'
				["bright_white"]='37;1'
				["bright_yellow"]='33;1'
			)

			declare -A backgrounds_array=(
				["black"]=40
				["blue"]=44
				["cyan"]=46
				["green"]=42
				["purple"]=45
				["red"]=41
				["white"]=47
				["yellow"]=43
				["bright_black"]='100'
				["bright_blue"]='104'
				["bright_cyan"]='106'
				["bright_green"]='102'
				["bright_purple"]='105'
				["bright_red"]='101'
				["bright_white"]='107'
				["bright_yellow"]='103'
			)

			#Assign default theme colors if they are not already defined in ~/.bashrc
			[ ! ${OMG_THEME["left_side_color"]+abc} ]  && OMG_THEME["left_side_color"]="black"
			[ ! ${OMG_THEME["left_side_bg"]+abc} ]     && OMG_THEME["left_side_bg"]="white"
			[ ! ${OMG_THEME["left_icon_color"]+abc} ]  && OMG_THEME["left_icon_color"]="red"
			[ ! ${OMG_THEME["stash_color"]+abc} ]      && OMG_THEME["stash_color"]="yellow"
			[ ! ${OMG_THEME["right_side_color"]+abc} ] && OMG_THEME["right_side_color"]="black"
			[ ! ${OMG_THEME["right_side_bg"]+abc} ]    && OMG_THEME["right_side_bg"]="red"
			[ ! ${OMG_THEME["right_icon_color"]+abc} ] && OMG_THEME["right_icon_color"]="white"
			[ ! ${OMG_THEME["default_bg"]+abc} ]       && OMG_THEME["default_bg"]="black"


			__omg_build_prompt

			PS2_PROMPT="\e[0;33m→${reset:?} "
		fi
	else
		# OMG NOT ENABLE
		PS1_PROMPT=${OMG_PS1_ORIGINAL:?}
		PS2_PROMPT=${OMG_PS2_ORIGINAL:?}
	fi

	echo "local OMG_PS1_PROMPT='${PS1_PROMPT:?}'"
	echo "local OMG_PS1_PROMPT_SIZE='${omg_prompt_size:?}'"
	echo "local OMG_IS_GIT_REPO='${omg_is_a_git_repo:?}'"
	echo "local OMG_PS2_PROMPT='${PS2_PROMPT:?}'"
	return 0
)

_oh_my_git() {
	local PS1_PROMPT
	local PROGRAM_NAME="oh-my-git"
	local CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/$PROGRAM_NAME"
	local CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/$PROGRAM_NAME"
	local DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/$PROGRAM_NAME"
	if [[ ${OMG_LOADED:?} -eq 0 ]] || [[ ${1:-} == 'reload' ]];then
		mkdir -p ${CACHE_DIR:?} ${CONFIG_DIR:?} ${DATA_DIR:?}
		chmod 700 ${CACHE_DIR:?} ${CONFIG_DIR:?} ${DATA_DIR:?}
		shopt -s nullglob
		shopt -s dotglob
		config_files=(${CONFIG_DIR:?}/*.bash)
		(( ${#config_files[*]} )) && \
			for f in ${config_files[*]};do
				source $f
			done
		shopt -u nullglob
		shopt -u dotglob
	fi


	# Init OMG_PS1_PROMPT OMG_PS1_PROMPT_SIZE OMG_IS_GIT_REPO OMG_PS2_PROMPT
	eval $(__oh_my_git_init)

	# STATUS BAR SWITCH
	if [[ ${OMG_STATUS_BAR:?} -ne ${OMG_PREV_STATUS_BAR:?} ]];then
		[[ ${OMG_PREV_STATUS_BAR:?} -eq 0 ]] && clear
		[[ ${OMG_STATUS_BAR:?} -eq 1 ]] && echo -ne "\n"
	fi

	if [[ ${OMG_STATUS_BAR:?} -eq 1 ]];then
		# REVERSE SWITCH
		# GIT REPO SWITCH
		# Clean upper line when changes occur in status display
		if [[ ${OMG_REVERSE:?} -ne ${OMG_PREV_REVERSE:?} ]] || [[ ${OMG_IS_GIT_REPO:?} != ${OMG_PREV_IS_GIT_REPO:?} ]];then
			tput sc
			tput cup "0" "0"
			printf '%*s\n' "${COLUMNS:-$(tput cols)}" ''
			tput rc
		fi
	fi

	if [[ ${OMG_IS_GIT_REPO:?} == true ]]; then
		# STATUS BAR
		if [[ ${OMG_STATUS_BAR:?} -eq 1 ]];then
			tput sc
			if [[ ${OMG_REVERSE:?} -eq 0 ]];then
				tput cup "0" "0"
			else
				tput cup "0" "$((${COLUMNS:-$(tput cols)} - ${OMG_PS1_PROMPT_SIZE:?}))" # position cursor
			fi
			echo -ne "${OMG_PS1_PROMPT:?}"
			tput rc # restore cursor.
			PS1_PROMPT=${OMG_PS1_ORIGINAL:?}
		else
			PS1_PROMPT=${OMG_PS1_PROMPT:?}"\n"${OMG_PS1_ORIGINAL:?}
		fi
	else
		PS1_PROMPT=${OMG_PS1_ORIGINAL:?}
	fi

	OMG_PREV_STATUS_BAR=${OMG_STATUS_BAR:?}
	OMG_PREV_IS_GIT_REPO=${OMG_IS_GIT_REPO:?}
	OMG_PREV_REVERSE=${OMG_REVERSE:?}
	OMG_LOADED=1

	PS1=${PS1_PROMPT:?}
	PS2=${OMG_PS2_PROMPT:?}
}

if [ ${#OMG_THEME[@]} -eq 0 ]; then
	declare -A OMG_THEME
fi
: ${OMG_ENABLE:=1}
: ${OMG_LOADED:=0}
: ${OMG_CONDENSED:=true}
: ${OMG_REVERSE:=0}
: ${OMG_STATUS_BAR:=0}

: ${OMG_PS1_ORIGINAL:=$PS1}
: ${OMG_PS2_ORIGINAL:=$PS2}
: ${OMG_PREV_STATUS_BAR:=0}
: ${OMG_PREV_REVERSE:=0}
: ${OMG_PREV_IS_GIT_REPO:=false}
: ${OMG_PREV_LOADED:=0}

[[ ! $PROMPT_COMMAND =~ '_oh_my_git' ]] && PROMPT_COMMAND="_oh_my_git; $PROMPT_COMMAND"
