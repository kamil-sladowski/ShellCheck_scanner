#!/bin/bash
#
# Kamil Sladowski
#
# github_requests.sh
#
#####################################

clone_single_repository (){
    clone_url=$1
    repository_name=$2
    echo "Cloning $clone_url. It may take a moment..."
    git clone -q ${clone_url} "$main_dir/${repository_name}" --depth 1
    if [ $? -eq 0 ] ; then
      rm -rf "${repository_name}/.git"
      echo "Clone $repository_name... DONE"
    else
      echo "Error: Could not clone repository. Check is that exists on github.com"
      exit "$WRONG_REPOSITORY"
    fi
}



get_random_bash_repositories(){
    number_of_draws=$1
    MAX_PAGES=34
    MAX_JSON_ID_PER_PAGE=29

    for i in `seq $number_of_draws`; do
        page=`shuf -i 1-$MAX_PAGES -n 1`
        json_id=`shuf -i 0-$MAX_JSON_ID_PER_PAGE -n 1`
        github_query="https://api.github.com/search/repositories?q=language:bash&sort=stars&order=desc&page=$page"
        clone_url=`curl -s ${github_query} | jq ".items[$json_id].clone_url" | grep -o '[^"]\+://.\+.git'` &> /dev/null
        repo_size=`curl -s ${github_query} | jq ".items[$json_id].size"`
        echo "Drawn repository: $clone_url. Size: $repo_size KB. Will be downloaded only latest version of every file"


        url_without_suffix="${clone_url%.*}"
        clone_name="$(basename "${url_without_suffix}")"
        repository_parameters[$clone_name]=${clone_url}
    done
}