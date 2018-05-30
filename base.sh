#!/usr/bin/env bash
function __oh_my_git_get_current_action () {
    local info="$(git rev-parse --git-dir 2> /dev/null)"
    if [ -n "$info" ]; then
        local action
        if [ -f "$info/rebase-merge/interactive" ]
        then
            action=${is_rebasing_interactively:-"rebase -i"}
        elif [ -d "$info/rebase-merge" ]
        then
            action=${is_rebasing_merge:-"rebase -m"}
        else
            if [ -d "$info/rebase-apply" ]
            then
                if [ -f "$info/rebase-apply/rebasing" ]
                then
                    action=${is_rebasing:-"rebase"}
                elif [ -f "$info/rebase-apply/applying" ]
                then
                    action=${is_applying_mailbox_patches:-"am"}
                else
                    action=${is_rebasing_mailbox_patches:-"am/rebase"}
                fi
            elif [ -f "$info/MERGE_HEAD" ]
            then
                action=${is_merging:-"merge"}
            elif [ -f "$info/CHERRY_PICK_HEAD" ]
            then
                action=${is_cherry_picking:-"cherry-pick"}
            elif [ -f "$info/BISECT_LOG" ]
            then
                action=${is_bisecting:-"bisect"}
            fi
        fi

        if [[ -n $action ]]; then printf "%s" "${1-}$action${2-}"; fi
    fi
}

function __oh_my_git_build_prompt {
    local return_prompt=${1:?prompt variable missing into __oh_my_git_build_prompt call}
    local return_prompt_size=${2:?prompt size variable missing into __oh_my_git_build_prompt call}
    local return_is_a_git_repo=${3:?is a git repo variable missing into __oh_my_git_build_prompt call}

    # Git info
    local current_commit_hash=$(git rev-parse HEAD 2> /dev/null)
    if [[ -n $current_commit_hash ]];then 
	    local is_a_git_repo=true
	    # Exit if we need to
	    local enabled=`git config --get oh-my-git.enabled 2> /dev/null`
	    if [[ ${enabled} == false ]] || [[ ${OMG_ENABLE} == false ]]; then
		eval "${return_is_a_git_repo}=\"${is_a_git_repo:-false}\""
		return 0;
	    fi
    else
	    return 0
    fi

    local prompt=""

    if [[ $is_a_git_repo == true ]]; then
        local current_branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
        local current_branch_sanitized=${current_branch//\$/💩}
        if [[ $current_branch_sanitized == 'HEAD' ]]; then local detached=true; fi

        local number_of_logs="$(git log --pretty=oneline -n1 2> /dev/null | wc -l)"
        if [[ $number_of_logs -eq 0 ]]; then
            local just_init=true
        else
            local upstream=$(git rev-parse --symbolic-full-name --abbrev-ref @{upstream} 2> /dev/null)
            if [[ -n "${upstream}" && "${upstream}" != "@{upstream}" ]]; then local has_upstream=true; fi

            local git_status="$(git status --porcelain 2> /dev/null)"
            local action="$(__oh_my_git_get_current_action)"

            if [[ $git_status =~ ($'\n'|^).M ]]; then local has_modifications=true; fi
            if [[ $git_status =~ ($'\n'|^)M ]]; then local has_modifications_cached=true; fi
            if [[ $git_status =~ ($'\n'|^)A ]]; then local has_adds=true; fi
            if [[ $git_status =~ ($'\n'|^).D ]]; then local has_deletions=true; fi
            if [[ $git_status =~ ($'\n'|^)D ]]; then local has_deletions_cached=true; fi
            if [[ $git_status =~ ($'\n'|^)R ]]; then local has_renames=true; fi
            if [[ $git_status =~ ($'\n'|^)[MAD] && ! $git_status =~ ($'\n'|^).[MAD\?] ]]; then local ready_to_commit=true; fi

            local number_of_untracked_files=$(\grep -c "^??" <<< "${git_status}")
            if [[ $number_of_untracked_files -gt 0 ]]; then local has_untracked_files=true; fi

            local tags_at_current_commit=$(git tag --points-at $current_commit_hash 2> /dev/null)

            if [[ $has_upstream == true ]]; then
                local commits_diff="$(git log --pretty=oneline --topo-order --left-right ${current_commit_hash}...${upstream} 2> /dev/null)"
                local commits_ahead=$(\grep -c "^<" <<< "$commits_diff")
                local commits_behind=$(\grep -c "^>" <<< "$commits_diff")
            fi

            if [[ $commits_ahead -gt 0 && $commits_behind -gt 0 ]]; then local has_diverged=true; fi
            if [[ $has_diverged == false && $commits_ahead -gt 0 ]]; then local should_push=true; fi

            local will_rebase=$(git config --get branch.${current_branch_sanitized}.rebase 2> /dev/null)

            local number_of_stashes="$(git stash list -n1 2> /dev/null | wc -l)"
            if [[ $number_of_stashes -gt 0 ]]; then local has_stashes=true; fi

            if [ "${action}" = "bisect" ]; then
                local bisect_log=$(git bisect log)
                local bisect_first=$(grep 'git bisect good' <<< "${bisect_log}" | head -n1 | cut -d' ' -f4)
                local bisect_last=$(grep 'git bisect bad' <<< "${bisect_log}" | head -n1 | cut -d' ' -f4)
                local bisect_total=$(git log --pretty=oneline ${bisect_first}..${bisect_last} 2> /dev/null | wc -l)
                local bisect_total=$(bc <<< "${bisect_total} - 1")
                local bisect_remain=$(git bisect view --pretty=oneline 2> /dev/null | wc -l)
                local bisect_remain=$(bc <<< "${bisect_remain} / 2")
                local bisect_tested=$(bc <<< "${bisect_total} - ${bisect_remain}")
                if [[ ${bisect_remain} -ne 0 ]]; then
                    local bisect_steps=$(bc -l <<< "a=l(${bisect_remain})/l(2); scale=0; (a+0.5)/1")
                    local bisect_steps="~${bisect_steps}"
                else
                    local bisect_steps="0"
                fi
            fi

            local toplevel=$(git rev-parse --show-toplevel)
            local modules=$(git -C ${toplevel} config --file .gitmodules --name-only --get-regexp path 2> /dev/null | sed 's/\.path$//')
            local submodules_outdated=false
            local module=''
            for module in ${modules}; do
                # obtain the module configuration
                local module_path=$(git -C "${toplevel}" config --file .gitmodules ${module}.path)
                local module_branch=$(git -C "${toplevel}" config --file .gitmodules ${module}.branch)
                if [ -z "${module_branch}" ]; then continue; fi
                # determine whether the branch is out of date (with cached data)
		if [[ -d "${toplevel}/${module_path}/.git" ]];then
			# spawn a background update of our cached information
			(git -C "${toplevel}/${module_path}" remote update &) 1>/dev/null 2>/dev/null
			local branch_rev=$(git -C "${toplevel}/${module_path}" rev-parse origin/${module_branch} 2> /dev/null)
                	local head_rev=$(git -C "${toplevel}/${module_path}" rev-parse HEAD 2> /dev/null)
			if [[ "${head_rev}" != "${branch_rev}" ]]; then
			    submodules_outdated=true;
			fi
		fi
            done
        fi
    fi

    local custom_build_prompt_prompt custom_build_prompt_size custom_build_prompt_is_a_git_repo
    __oh_my_git_custom_build_prompt \
	custom_build_prompt_prompt \
	custom_build_prompt_size \
	custom_build_prompt_is_a_git_repo \
        ${enabled:-true} \
        ${current_commit_hash:-""} \
        ${is_a_git_repo:-false} \
        ${current_branch_sanitized:-""} \
        ${detached:-false} \
        ${just_init:-false} \
        ${has_upstream:-false} \
        ${has_modifications:-false} \
        ${has_modifications_cached:-false} \
        ${has_adds:-false} \
        ${has_deletions:-false} \
        ${has_deletions_cached:-false} \
        ${has_renames:-false} \
        ${has_untracked_files:-false} \
        ${ready_to_commit:-false} \
        ${tags_at_current_commit:-""} \
        ${has_upstream:-false} \
        ${commits_ahead:-false} \
        ${commits_behind:-false} \
        ${has_diverged:-false} \
        ${should_push:-false} \
        ${will_rebase:-false} \
        ${has_stashes:-false} \
        ${bisect_tested:-""} \
        ${bisect_total:-""} \
        ${bisect_steps:-""} \
        ${submodules_outdated:-false} \
        ${action}

    eval "$return_prompt=\"$custom_build_prompt_prompt\""
    eval "$return_prompt_size=\"$custom_build_prompt_size\""
    eval "$return_is_a_git_repo=\"${custom_build_prompt_is_a_git_repo}\""
}
