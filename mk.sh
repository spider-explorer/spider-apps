#! bash -uvx
function processApp() {
  cwd=$1
  app=$2
  path_spec=$3
  cd $cwd
  scoop install $app
  scoop update $app
  version=`scoop-console-x86_64-static.exe --latest $app | awk '{print $1}'`
  echo $version
  path=`scoop-console-x86_64-static.exe --latest $app | awk '{print $2}'`
  echo $path
  #exists=`$cwd/gitlab-console-x86_64-static.exe --action exists --project spider-explorer/spider-software .software/$app/$app-$version.7z`
  url=https://gitlab.com/spider-explorer/spider-software/-/raw/main/.software/$app/$app-$version.7z
  json=`echo "$json" | jq -r --arg app "$app" --arg version "$version" --arg path_spec "$path_spec" --arg url "$url" '.software[$app] = {"version":$version, "ext":"7z", "path":$path_spec, "url":$url}'`
  if [ -e $cwd/.software/$app/$app-$version.7z.001 ]; then
    return 0
  fi
  if [ -e "$path" ]; then
    echo exist
    cd $cwd
    mkdir -p .software/$app
    cd .software/$app
    cd $path
    if [ "$app" == "opera" ]; then cp -rp launcher.exe opera.exe; fi
    7z.exe a -r -v3m $cwd/.software/$app/$app-$version.7z * -x!"User Data" -x!"profile" -x!"distribution"
    #$cwd/gitlab-console-x86_64-static.exe --action upload --project spider-explorer/spider-software $cwd/.software/$app/$app-$version.7z --path .software/$app/
    if [ -e $cwd/.software/$app/$app-$version.7z ]; then
      mv $cwd/.software/$app/$app-$version.7z $cwd/.software/$app/$app-$version.7z.001
    fi
  fi
}
cwd=`pwd`
scoop install git
scoop bucket add main
scoop bucket add extras
scoop bucket add java
#json=`cat ./investigate.json`
json="{}"
processApp $cwd vim "."
processApp $cwd sed "."
echo "$json"
echo "$json" > spider-software.json
dos2unix spider-software.json
#$cwd/gitlab-console-x86_64-static.exe --action upload --project spider-explorer/spider-software spider-software.json
