#/bin/bash
#

function showMenu {
#dispaly menu
cat << EOF
d|D) show disk usages
m|M) show memory usages
s|S) show swap usages
q|Q) quit
EOF
}

showMenu
