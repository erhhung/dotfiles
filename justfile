# https://cheatography.com/linux-china/cheat-sheets/justfile/
# https://just.systems/man/en/chapter_23.html

set shell := ["bash","-uc"]

WHITE := `printf $WHITE`
NOCLR := `printf $NOCLR`

@_default:
  just --justfile {{justfile()}} --list --unsorted --list-heading $'{{WHITE}}Recipes:{{NOCLR}}\n'

@_fstype path:
  mount | egrep "\son\s+$(realpath "{{path}}")\s" | sed -En 's/.*[(]([a-z]+),.*/\1/p'

@mount_k8s:
  if [ ! "$(just _fstype ~/k8s)" ]; then \
    mount_nfs -o vers=3,proto=tcp,rw,nodev,nosuid,soft,nolock,intr,timeo=100,retrans=5,rsize=16384,wsize=16384 \
      qnap.fourteeners.local:/k8s_data ~/k8s; \
  fi

@umount_k8s:
  if [ "$(just _fstype ~/k8s)" ]; then \
    diskutil umount ~/k8s > /dev/null; \
  fi
