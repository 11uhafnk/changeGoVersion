#!/bin/sh

majorVersion=1
version=${1:-'latest'}
subversion=${2:-'latest'}


function getLatest {
    max=0
    for val in ${@}; do
        if [[ $max -lt $val ]]; then
            max=$val
        fi
    done

    echo $max
}

function getAllVersions {
    pattern=${1:-'go_$majorVersion.'}
    for val in $(ls -d $pattern*); do
        p=${val#$pattern}
        echo ${p%.*}
    done
}

function dowload {
    if [[ "$version" -eq "latest" ]] ||  [[ "$subversion" -eq "latest" ]] || [[ -d /usr/local/go_$majorVersion.$version.$subversion ]]; then
        return
    fi

    wget -O /var/tmp/go_$majorVersion.$version.$subversion.tar.gz https://golang.org/dl/go1.$version.$subversion.linux-amd64.tar.gz || exit 1
    tar -C /var/tmp -xzf /var/tmp/go_$majorVersion.$version.$subversion.tar.gz
    sudo mv /var/tmp/go /usr/local/go_$majorVersion.$version.$subversion
}

pushd $(pwd)
cd /usr/local

dowload

if [[ $version -eq 'latest' ]]; then
    version=$(getLatest $(getAllVersions go_$majorVersion.) )
fi

if [[ $subversion -eq 'latest' ]]; then
    subversion=$(getLatest $(getAllVersions "go_$majorVersion.$version.") )
fi

if [[ ! -d "go_$majorVersion.$version.$subversion" ]]; then
    echo "Required version not exist or not available"
    exit 1
fi


echo "set go_$majorVersion.$version.$subversion"
sudo rm -Rf go
sudo cp -r "go_$majorVersion.$version.$subversion" go

popd