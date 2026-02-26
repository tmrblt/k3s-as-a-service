cat << EOF > decode.sh
#!/bin/bash
#
[ "$BASH" ] && function whence
{
        type -p "$@"
}
#
PATH_SCRIPT="$(cd $(/usr/bin/dirname $(whence -- $0 || echo $0));pwd)"

cat ${PATH_SCRIPT}/pull-secret.txt|jq .|grep -B1 auth.:|xargs -n5|awk '{ print $1,$4}'|while read site auth
do
        my_login="$(echo $auth|base64 -id|cut -f1 -d:)"
        my_pwd="$(echo $auth|base64 -id|cut -f2 -d: |sed -e 's@,$@@')"
        my_url="$(echo $site)"
        echo -e "\n * https://${my_url}"
        echo -e "\tLOGIN: $my_login"
        echo -e "\tPWD: $my_pwd"
done
EOF
