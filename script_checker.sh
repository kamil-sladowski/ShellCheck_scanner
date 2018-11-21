#!/bin/bash
#
# Kamil Sladowski
#
# script_checker.sh
#
#####################################

scan_all_bash_scripts_from_single_repository (){
    name=$1
    repository_destination_dir="$main_dir/$name"
    repository_results_dir="$main_dir/${name}_results"
    if [ -d "$repository_results_dir" ] ; then
        echo ""
        i=0
        while [ -d $repository_results_dir-$i ] ; do
            let i++
        done
        repository_results_dir=$repository_results_dir-$i
    fi

    mkdir "$repository_results_dir"
	echo "Created directory for results:"
	echo "$repository_results_dir"
    report_file="$repository_results_dir/$name.txt"
    touch ${report_file}
	echo "Scanning following files:"
    find ${repository_destination_dir} -iname "*.bash" -o -iname "*.sh" | while read filename; do
        echo "Scanning file:   $filename"
        $shellcheck_script ${filename} >> ${report_file}
        if ! [ $? -ne 0 ]; then
            echo "Can not scan $filename"
            echo "Check if this is shell script!"
        fi
    done

    find ${repository_destination_dir} -type f ! -name "*.*" -exec file {} \; | grep 'shell script' | egrep -o '^[^:]+' | while read filename; do
        echo "Scanning file:   $filename"
        $shellcheck_script ${filename} >> ${report_file}
        if ! [ $? -ne 0 ]; then
            echo "Can not scan $filename"
            echo "Check if this is shell script!"
        fi
    done

	echo "Scanning... DONE"
	if [[ -s ${report_file} ]]; then
		echo "Report file is available on: `pwd`/$report_file"
	else
		echo "ShellCheck did not find any comments."
		rm ${report_file}
	fi

    rm -rf ${repository_destination_dir}
}




run_specific_repo_scan_scenario(){
	repository_data_url="https://api.github.com/repos/${username}/${repository_name}"
	clone_url=`curl -s ${repository_data_url} | jq '.clone_url' | grep -o '[^"]\+://.\+.git'`
	echo "URL address of repository to scan:"
	echo "$clone_url"
	clone_single_repository ${clone_url} ${repository_name}
	scan_all_bash_scripts_from_single_repository "$repository_name"
}


run_random_repo_scan_scenario(){
	get_random_bash_repositories ${number_of_draws}

	for name in "${!repository_parameters[@]}"
	do
	  echo "Repository to scan: $name"
	  echo "Github url: ${repository_parameters[$name]}"
	   clone_single_repository ${repository_parameters[$name]} ${name}
	   scan_all_bash_scripts_from_single_repository ${name}
	done
}
