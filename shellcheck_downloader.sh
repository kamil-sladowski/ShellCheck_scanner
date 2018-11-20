#!/bin/bash
#
# Kamil Sladowski
#
# shellcheck_downloader.sh
#
#####################################




download_shellcheck_binary (){
    if ! [ -e "$shellcheck_script" ]
    then
        echo "Downloading ShellCheck binary"
        mkdir $shellcheck_dir # && cd $shell_check_dir
        wget -q https://storage.googleapis.com/shellcheck/shellcheck-stable.linux.x86_64.tar.xz -P $shellcheck_dir
        tar xf ${shellcheck_dir}/shellcheck-stable.linux.x86_64.tar.xz --strip 1 -C ${shellcheck_dir}
        if ! [ $? = 0 ]
        then
         echo "Error: Could not download ShellCheck binary"
         exit 2
		else
		 echo "Download ShellCheck binary... DONE"
        fi
    else
        echo "ShellCheck binary already downloaded"
    fi
}