#!/bin/bash
#
# Kamil Sladowski
#
# Program zaliczeniowy z basha
#
# shellcheck_scanner.sh
#
#####################################

WRONG_ARGS=1
WRONG_REPOSITORY=10
main_dir=$(dirname "$0")
shellcheck_dir="$main_dir/shellcheck"
shellcheck_script="$shellcheck_dir/shellcheck"
clone_urls=()
clone_names=()
declare -A repository_parameters


show_help() {
echo ""
echo ""
echo "Script bases on ShellCheck. Tool written to find bugs in shell scripts. "
echo "More information on https://www.shellcheck.net/"
echo ""
echo "My script is dedicated to checking repositories from github.com "
echo "It downloads to current directory shellcheck binary. "
echo "After this, it clones github's repository, scans them, generates report file and deletes checked out files."
echo ""
echo "There are two different work scenarios: "
echo "1. Checking any number of random repositories. They will be drawn by the script; "
echo "2. Checking the one, indicated repository. In this mode you need to provide"
echo "   repository name and nick of user, to whom it belongs on github.com"
echo ""
echo ""
echo "Take a look at possible options, to run the script with one of available scenario:"
echo "$0 usage: [-r REPOSITORY -u USERNAME] or [-n NUMBER]"
echo ""
grep " .)\ #" $0
}


usage() {
show_help
exit $WRONG_ARGS
}

parse_args(){
[ $# -eq 0 ] && usage

while getopts ":hn:r:u:" arg; do
  case ${arg} in
    u) # USERNAME - Specify username to whom belongs repository
      username=${OPTARG}
      ;;
    r) # REPOSITORY - Specify repository name
      repository_name=${OPTARG}
      ;;
    n) # NUMBER - Specify number of random repositories to check
      [[ ${OPTARG} =~ ^[0-9]+$ ]] \
      && number_of_draws=${OPTARG} \
      || echo "Error: Parameter n should be integer"
      ;;
    h) # HELP - Display help
      show_help
      exit 0
      ;;
    help) # HELP - Display help
      show_help
      exit 0
      ;;
    *)
    usage
    exit 1
    ;;
  esac
done
}

parse_args $*


check_required_packags (){
	required_packages=(git wget tar shuf jq egrep ) # xz-utils
	i=0
	for package in "${required_packages[@]}"
	do
		which ${package} > /dev/null
		if ! [ $? = 0 ]
		then
		 echo "Error: $package should be installed"
		 let i++
		fi
	done

	if ! [ $i = 0 ]
	then
		exit $i
	fi
}


source "$main_dir/shellcheck_downloader.sh"
source "$main_dir/github_requests.sh"
source "$main_dir/script_checker.sh"

check_required_packags
download_shellcheck_binary

	if [ -z "$username" ] || [ -z "$repository_name" ] ; then
		if ! [ -z "$number_of_draws" ]; then
		  run_random_repo_scan_scenario
		else
		  usage
		fi
	else
	run_specific_repo_scan_scenario
fi


exit 0