#!/bin/bash

BR_VERSION="System Tar & Restore 3.8"
BR_SEP="::"

color_variables() {
  BR_NORM='\e[00m'
  BR_RED='\e[00;31m'
  BR_GREEN='\e[00;32m'
  BR_YELLOW='\e[00;33m'
  BR_BLUE='\e[00;34m'
  BR_MAGENTA='\e[00;35m'
  BR_CYAN='\e[00;36m'
  BR_BOLD='\033[1m'
}


BRargs=`getopt -o "I:d:C:u:enNa:qr:s:b:h:g:S:f:U:l:p:R:toNm:k:c:O:" -l "Interface:,destination:,Compression:,user-options:,exclude-home,no-hidden,no-color,archiver:,quiet,root:,swap:,boot:,home:,grub:,syslinux:,file:,url:,username:,password:,quiet,rootsubvolname:,transfer,only-hidden,no-color,mount-options:,kernel-options:,custom-partitions:,archiver:,other-subvolumes:,help" -n "$1" -- "$@"`

if [ "$?" -ne "0" ]; then
  echo "See $0 --help"
  exit
fi

eval set -- "$BRargs";

while true; do
  case "$1" in
    -I|--interface)
      BRinterface=$2
      shift 2
    ;;
    -u|--user-options)
      BRuseroptions="Yes"
      BR_USER_OPTS=$2
      BRmode="Backup"
      BRbackup="y"
      shift 2
    ;;
    -d|--destination)
      BRFOLDER=$2
      BRmode="Backup"
      BRbackup="y"
      shift 2
    ;;
    -C|--compression)
      BRcompression=$2
      BRmode="Backup"
      BRbackup="y"
      shift 2
    ;;
    -e|--exclude-home)
      BRhome="No"
      BRmode="Backup"
      BRbackup="y"
      shift
    ;;
    -n|--no-hidden)
      BRhidden="No"
      BRmode="Backup"
      BRbackup="y"
      shift
    ;;
    -N|--no-color)
      BRnocolor="y"
      shift
    ;;
    -a|--archiver)
      BRarchiver=$2
      shift 2
    ;;
    -q|--quiet)
      BRcontinue="y"
      BRquiet="y"
      BRedit="n"
      shift
    ;;
  -r|--root)
      BRroot=$2
      BRmode="Both"
      BRboth="y"
      shift 2
    ;;
    -s|--swap)
      BRswap=$2
      BRmode="Both"
      BRboth="y"
      shift 2
    ;;
    -b|--boot)
      BRboot=$2
      BRmode="Both"
      BRboth="y"
      shift 2
    ;;
    -h|--home)
      BRhome=$2
      BRmode="Both"
      BRboth="y"
      shift 2
    ;;
    -g|--grub)
      BRgrub=$2
      BRmode="Both"
      BRboth="y"
      shift 2
    ;;
    -S|--syslinux)
      BRsyslinux=$2
      BRmode="Both"
      BRboth="y"
      shift 2
    ;;
    -f|--file)
      BRmode="Restore"
      BRboth="y"
      BRfile=$2
      shift 2
    ;;
    -U|--url)
      BRmode="Restore"
      BRboth="y"
      BRurl=$2
      shift 2
    ;;
    -l|--username)
      BRusername=$2
      BRmode="Restore"
      BRboth="y"
      shift 2
    ;;
    -p|--password)
      BRpassword=$2
      BRmode="Restore"
      BRboth="y"
      shift 2
    ;;
    -R|--rootsubvolname)
      BRrootsubvol="y"
      BRrootsubvolname=$2
      BRmode="Both"
      BRboth="y"
      shift 2
    ;;
    -t|--transfer)
      BRmode="Transfer"
      BRrestore="off"
      BRboth="y"
      shift
    ;;
    -o|--only-hidden)
      BRhidden="y"
      BRmode="Transfer"
      BRboth="y"
      shift
    ;;
    -m|--mount-options)
      BRmountoptions="Yes"
      BR_MOUNT_OPTS=$2
      BRmode="Both"
      BRboth="y"
      shift 2
    ;;
    -k|--kernel-options)
      BR_KERNEL_OPTS=$2
      BRmode="Both"
      BRboth="y"
      shift 2
    ;;
    -c|--custom-partitions)
      BRcustom="y"
      BRother="y"
      BRcustomparts=($2)
      BRcustomold="$2"
      BRmode="Both"
      BRboth="y"
      shift 2
    ;;
    -a|--archiver)
      BRarchiver=$2
      shift 2
    ;;
    -O|--other-subvolumes)
      BRsubvolother="y"
      BRsubvols=($2)
      BRmode="Both"
      BRboth="y"
      shift 2
    ;;
    --help)
      BR_BOLD='\033[1m'
      BR_NORM='\e[00m'
      echo -e "
${BR_BOLD}$BR_VERSION

${BR_BOLD}General:${BR_NORM}
  -I, --interface           interface to use (cli dialog)
  -N, --no-color            disable colors
  -q, --quiet               dont ask, just run
  -a, --archiver            select archiver (tar bsdtar)

${BR_BOLD}Backup Mode:${BR_NORM}
  -d, --destination         backup folder path
  -e, --exclude-home	    exclude /home directory (keep hidden files and folders)
  -n, --no-hidden           dont keep home's hidden files and folders (use with -h)
  -C, --compression         compression type (gzip xz)
  -u, --user-options        additional tar options (See tar --help or man bsdtar)

${BR_BOLD}Restore Mode:${BR_NORM}
  -f,  --file               backup file path
  -U,  --url                url
  -l,  --username           username
  -p,  --password           password

${BR_BOLD}Transfer Mode:${BR_NORM}
  -t,  --transfer           activate transfer mode
  -o,  --only-hidden        transfer /home's hidden files and folders only

${BR_BOLD}Partitions:${BR_NORM}
  -r,  --root               target root partition
  -h,  --home               target home partition
  -b,  --boot               target boot partition
  -s,  --swap               swap partition
  -c,  --custom-partitions  specify custom partitions (mountpoint=device)
  -m,  --mount-options      comma-separated list of mount options (root partition)

${BR_BOLD}Bootloader:${BR_NORM}
  -g,  --grub               target disk for grub
  -S,  --syslinux           target disk for syslinux
  -k,  --kernel-options     additional kernel options (syslinux)

${BR_BOLD}Btrfs Subvolumes:${BR_NORM}
  -R,  --rootsubvolname     subvolume name for /
  -O,  --other-subvolumes   specify other subvolumes (subvolume path e.g /home /var /usr ...)

--help	print this page
"
      unset BR_BOLD BR_NORM
      exit
      shift
    ;;
    --)
      shift
      break
    ;;
  esac
done

if [ -z "$BRnocolor" ]; then
  color_variables
fi

echo -e "\n${BR_BOLD}$BR_VERSION${BR_NORM}\n"

if [ $(id -u) -gt 0 ]; then
  echo -e "[${BR_RED}ERROR${BR_NORM}] Script must run as root"
  exit
fi

if [ -n "$BRbackup" ] && [ -n "$BRboth" ]; then
  echo -e "[${BR_RED}ERROR${BR_NORM}] Conflicting modes"
  exit
fi

if [ -n "$BRinterface" ] && [ ! "$BRinterface" = "cli" ] && [ ! "$BRinterface" = "dialog" ]; then
  echo -e "[${BR_RED}ERROR${BR_NORM}] Wrong interface name: $BRinterface. Available options: cli dialog"
  BRSTOP="y"
fi

if [ -n "$BRarchiver" ] && [ ! "$BRarchiver" = "tar" ] && [ ! "$BRarchiver" = "bsdtar" ]; then
  echo -e "[${BR_RED}ERROR${BR_NORM}] Wrong archiver: $BRarchiver. Available options: tar bsdtar"
  BRSTOP="y"
fi

if [ -n "$BRSTOP" ]; then
  exit
fi

if [ "$BRmode" = "Transfer" ] && [ -z "$BRhidden" ]; then
  BRhidden="n"
fi

PS3="Enter number or Q to quit: "

if [ -z "$BRmode" ]; then
  echo -e "\n${BR_CYAN}Select Mode:${BR_NORM}"
  select c in "Backup" "Restore" "Transfer"; do
    if [ $REPLY = "q" ] || [ $REPLY = "Q" ]; then
      echo -e "${BR_YELLOW}Aborted by User${BR_NORM}"
      exit
    elif [[ "$REPLY" = [0-9]* ]] && [ "$REPLY" -eq 1 ]; then
      BRmode="Backup"
      break
    elif [[ "$REPLY" = [0-9]* ]] && [ "$REPLY" -eq 2 ]; then
      BRmode="Restore"
      break
    elif [[ "$REPLY" = [0-9]* ]] && [ "$REPLY" -eq 3 ]; then
      BRmode="Transfer"
      break
    else
      echo -e "${BR_RED}Please enter a valid option from the list${BR_NORM}"
    fi
  done
fi

if [ -z "$BRinterface" ]; then
  echo -e "\n${BR_CYAN}Select interface:${BR_NORM}"
  select c in "CLI" "Dialog"; do
    if [ $REPLY = "q" ] || [ $REPLY = "Q" ]; then
      echo -e "${BR_YELLOW}Aborted by User${BR_NORM}"
      exit
    elif [[ "$REPLY" = [0-9]* ]] && [ "$REPLY" -eq 1 ]; then
      BRinterface="cli"
      break
    elif [[ "$REPLY" = [0-9]* ]] && [ "$REPLY" -eq 2 ]; then
      BRinterface="dialog"
      break
    else
      echo -e "${BR_RED}Please enter a valid option from the list${BR_NORM}"
    fi
  done
fi

if [ "$BRinterface" = "Dialog" ] && [ -z $(which dialog 2> /dev/null) ];then
  echo -e "[${BR_RED}ERROR${BR_NORM}] Package dialog is not installed. Install the package and re-run the script"
  exit
fi

if [ "$BRmode" = "Backup" ]; then

  info_screen() {
    echo -e "\n${BR_YELLOW}This mode will make a tar backup image of this system."
    echo -e "\n==>Make sure you have enough free space."
    echo -e "\n==>Also make sure you have GRUB or SYSLINUX packages installed."
    echo -e "\nGRUB PACKAGES:"
    echo "->Arch: grub-bios"
    echo "->Debian: grub-pc"
    echo "->Fedora: grub2"
    echo -e "\nSYSLINUX PACKAGES:"
    echo "->Arch: syslinux"
    echo "->Debian: syslinux extlinux"
    echo -e "->Fedora: syslinux syslinux-extlinux${BR_NORM}"
    echo -e "\n${BR_CYAN}Press ENTER to continue.${BR_NORM}"
  }

  exit_screen() {
    if [ -f /tmp/b_error ]; then
      echo -e "${BR_RED}\nAn error occurred. Check "$BRFOLDER"/backup.log for details.\n\n${BR_CYAN}Press ENTER to exit.${BR_NORM}"
    else
      echo -e "${BR_CYAN}\nCompleted. Backup archive and log saved in $BRFOLDER\n\nPress ENTER to exit.${BR_NORM}"
    fi
  }

  exit_screen_quiet() {
    if [ -f /tmp/b_error ]; then
      echo -e "${BR_RED}\nAn error occurred.\n\nCheck "$BRFOLDER"/backup.log for details${BR_NORM}"
    else
      echo -e "${BR_CYAN}\nCompleted.\n\nBackup archive and log saved in $BRFOLDER${BR_NORM}"
    fi
  }

  show_summary() {
    echo -e "${BR_YELLOW}DESTINATION:"
    echo "$BRFOLDER"

    echo -e "\nARCHIVER OPTIONS:"
    echo "Archiver: $BRarchiver"
    echo "Compression: $BRcompression"

    echo -e "\nHOME DIRECTORY:"
    if [ "$BRhome" = "Yes" ]; then
      echo "Include"
    elif [ "$BRhome" = "No" ] && [ "$BRhidden" = "Yes" ]; then
      echo "Only hidden files and folders"
    elif [ "$BRhome" = "No" ] && [ "$BRhidden" = "No" ]; then
      echo "Exclude"
    fi

    if [ "$BRfedoratar" = "y" ] && [ "$BRarchiver" = "tar" ]; then
      echo -e "\nEXTRA OPTIONS:"
      echo "--acls --selinux --xattrs"
    fi

    if [ -n "$BR_USER_OPTS" ]; then
      echo -e "\nUSER OPTIONS:"
      echo "$BR_USER_OPTS"
    fi

    echo -e "\nFOUND BOOTLOADERS:"
    if [ -d /usr/lib/grub/i386-pc ]; then
      echo -e "Grub"
    fi
    if which extlinux &>/dev/null; then
      echo "Syslinux"
    fi
    if [ ! -d /usr/lib/grub/i386-pc ] && [ -z $(which extlinux 2> /dev/null) ];then
      echo "None or not supported"
    fi
    echo -e "${BR_NORM}"
  }

  dir_list() {
    DEFAULTIFS=$IFS
    IFS=$'\n'
    for D in "$BRpath"*; do [ -d "${D}" ] && echo "$( basename ${D// /\\} ) dir"; done
    IFS=$DEFAULTIFS
  }

  show_path() {
    BRcurrentpath="$BRpath"
    if [[ "$BRcurrentpath" == *//* ]]; then
      BRcurrentpath="${BRcurrentpath#*/}"
    fi
  }

  set_tar_options() {
    if [ "$BRarchiver" = "tar" ]; then
      BR_TAROPTS="$BR_USER_OPTS --sparse --exclude=/run/* --exclude=/dev/* --exclude=/proc/* --exclude=lost+found --exclude=/sys/* --exclude=/media/* --exclude=/tmp/* --exclude=/mnt/* --exclude=.gvfs"
      if [ "$BRhome" = "No" ] && [ "$BRhidden" = "No" ] ; then
        BR_TAROPTS="${BR_TAROPTS} --exclude=/home/*"
      elif [ "$BRhome" = "No" ] && [ "$BRhidden" = "Yes" ] ; then
        find /home/*/* -maxdepth 0 -iname ".*" -prune -o -print > /tmp/excludelist
        BR_TAROPTS="${BR_TAROPTS} --exclude-from=/tmp/excludelist"
      fi
      if [ "$BRfedoratar" = "y" ]; then
        BR_TAROPTS="${BR_TAROPTS} --acls --selinux --xattrs"
      fi
    elif [ "$BRarchiver" = "bsdtar" ]; then
      BR_TAROPTS=("$BR_USER_OPTS" --exclude=/run/*?* --exclude=/dev/*?* --exclude=/proc/*?* --exclude=/sys/*?* --exclude=/media/*?* --exclude=/tmp/*?* --exclude=/mnt/*?* --exclude=.gvfs --exclude=lost+found)
      if [ "$BRhome" = "No" ] && [ "$BRhidden" = "No" ] ; then
        BR_TAROPTS+=(--exclude=/home/*?*)
      elif [ "$BRhome" = "No" ] && [ "$BRhidden" = "Yes" ] ; then
        find /home/*/* -maxdepth 0 -iname ".*" -prune -o -print > /tmp/excludelist
        BR_TAROPTS+=(--exclude-from=/tmp/excludelist)
      fi
    fi
  }

  run_calc() {
    if [ "$BRarchiver" = "tar" ]; then
      $BRarchiver cvf /dev/null ${BR_TAROPTS} --exclude="$BRFOLDER" / 2> /dev/null | tee /tmp/filelist | while read ln; do a=$(( a + 1 )) && echo -en "\rCalculating: $a Files"; done
    elif [ "$BRarchiver" = "bsdtar" ]; then
      $BRarchiver cvf /dev/null ${BR_TAROPTS[@]} --exclude="$BRFOLDER" / 2>&1 | tee /tmp/filelist | while read ln; do a=$(( a + 1 )) && echo -en "\rCalculating: $a Files"; done
    fi
  }

  run_tar() {
    if [ "$BRarchiver" = "tar" ]; then
      if [ "$BRcompression" = "gzip" ]; then
        $BRarchiver cvpzf "$BRFile".tar.gz ${BR_TAROPTS} --exclude="$BRFOLDER" / && (echo "System compressed successfully" >> "$BRFOLDER"/backup.log) || touch /tmp/b_error
      elif [ "$BRcompression" = "xz" ]; then
        $BRarchiver cvpJf "$BRFile".tar.xz ${BR_TAROPTS} --exclude="$BRFOLDER" / && (echo "System compressed successfully" >> "$BRFOLDER"/backup.log) || touch /tmp/b_error
      fi
    elif [ "$BRarchiver" = "bsdtar" ]; then
      if [ "$BRcompression" = "gzip" ]; then
        $BRarchiver cvpzf "$BRFile".tar.gz ${BR_TAROPTS[@]} --exclude="$BRFOLDER" / 2>&1 && (echo "System compressed successfully" >> "$BRFOLDER"/backup.log) || touch /tmp/b_error
      elif [ "$BRcompression" = "xz" ]; then
        $BRarchiver cvpJf "$BRFile".tar.xz ${BR_TAROPTS[@]} --exclude="$BRFOLDER" / 2>&1 && (echo "System compressed successfully" >> "$BRFOLDER"/backup.log) || touch /tmp/b_error
      fi
    fi
  }

  prepare() {
    touch /target_architecture.$(uname -m)
    BRFOLDER_IN=(`echo ${BRFOLDER}/Backup-$(date +%d-%m-%Y) | sed 's://*:/:g'`)
    BRFOLDER="${BRFOLDER_IN[@]}"
    if [ "$BRinterface" = "cli" ]; then
      echo -e "\n${BR_SEP}CREATING ARCHIVE"
    fi
    mkdir -p "$BRFOLDER"
    echo "--------------$(date +%d-%m-%Y-%T)--------------" >> "$BRFOLDER"/backup.log
    sleep 1
    BRFile="$BRFOLDER"/Backup-$(hostname)-$(date +%d-%m-%Y-%T)
  }

  if [ -z "$BRnocolor" ]; then
    color_variables
  fi

  BR_WRK="[${BR_CYAN}WORKING${BR_NORM}] "

  if [ -f /etc/yum.conf ]; then
    BRfedoratar="y"
  fi

  if [ ! -d "$BRFOLDER" ] && [ -n "$BRFOLDER" ]; then
    echo -e "[${BR_RED}ERROR${BR_NORM}] Directory does not exist: $BRFOLDER"
    BRSTOP="y"
  fi

  if [ -n "$BRcompression" ] && [ ! "$BRcompression" = "gzip" ] && [ ! "$BRcompression" = "xz" ]; then
    echo -e "[${BR_RED}ERROR${BR_NORM}] Wrong compression type: $BRcompression. Supported compressors: gzip xz"
    BRSTOP="y"
  fi

  if [ -n "$BRSTOP" ]; then
    exit
  fi

  if [ -z "$BRhidden" ]; then
    BRhidden="Yes"
  fi

  if [ -n "$BRFOLDER" ]; then
    if [ -z "$BRhome" ]; then
      BRhome="Yes"
    fi
    if [ -z "$BRuseroptions" ]; then
      BRuseroptions="No"
    fi
  fi

  if [ "$BRinterface" = "cli" ]; then
    DEFAULTIFS=$IFS
    IFS=$'\n'

    if [ -z "$BRFOLDER" ]; then
      info_screen
      read -s a
    fi

    while [ -z "$BRFOLDER" ]; do
      echo -e "\n${BR_CYAN}The default folder for creating the backup image is / (root).\nSave in the default folder?${BR_NORM}"
      read -p "(Y/n): " an

      if [ -n "$an" ]; then
        def=$an
      else
        def="y"
      fi

      if [ "$def" = "y" ] || [ "$def" = "Y" ]; then
        BRFOLDER="/"
      elif [ "$def" = "n" ] || [ "$def" = "N" ]; then
        while [ -z "$BRFOLDER" ] || [ ! -d "$BRFOLDER" ]; do
          echo -e "\n${BR_CYAN}Enter the path where the backup will be created${BR_NORM}"
          read -e -p "Path: " BRFOLDER
          if [ ! -d "$BRFOLDER" ]; then
            echo -e "${BR_RED}Directory does not exist${BR_NORM}"
          fi
        done
      else
        echo -e "${BR_RED}Please enter a valid option${BR_NORM}"
      fi
    done

    if [ -z "$BRhome" ]; then
      echo -e "\n${BR_CYAN}Home (/home) directory options:${BR_NORM}"
      select c in "Include" "Only hidden files and folders" "Exclude"; do
        if [ $REPLY = "q" ] || [ $REPLY = "Q" ]; then
          echo -e "${BR_YELLOW}Aborted by User${BR_NORM}"
          exit
        elif [ "$REPLY" = "1" ]; then
          BRhome="Yes"
          break
        elif [ "$REPLY" = "2" ]; then
          BRhome="No"
          BRhidden="Yes"
          break
        elif [ "$REPLY" = "3" ]; then
          BRhome="No"
          BRhidden="No"
          break
        else
          echo -e "${BR_RED}Please select a valid option from the list${BR_NORM}"
        fi
      done
    fi

    if [ -z "$BRarchiver" ]; then
      echo -e "\n${BR_CYAN}Select archiver:${BR_NORM}"
      select c in "tar    (GNU Tar)" "bsdtar (Libarchive Tar)"; do
        if [ $REPLY = "q" ] || [ $REPLY = "Q" ]; then
          echo -e "${BR_YELLOW}Aborted by User${BR_NORM}"
          exit
        elif [[ "$REPLY" = [0-9]* ]] && [ "$REPLY" -eq 1 ]; then
          BRarchiver="tar"
          break
        elif [[ "$REPLY" = [0-9]* ]] && [ "$REPLY" -eq 2 ]; then
          BRarchiver="bsdtar"
          break
        else
          echo -e "${BR_RED}Please enter a valid option from the list${BR_NORM}"
        fi
      done
    fi

    if [ "$BRarchiver" = "bsdtar" ] && [ -z $(which bsdtar 2> /dev/null) ]; then
      echo -e "[${BR_RED}ERROR${BR_NORM}] Package bsdtar is not installed. Install the package and re-run the script"
      exit
    fi

    if [ -z "$BRcompression" ]; then
      echo -e "\n${BR_CYAN}Select the type of compression:${BR_NORM}"
      select c in "gzip (Fast, big file)" "xz   (Slow, smaller file)"; do
        if [ $REPLY = "q" ] || [ $REPLY = "Q" ]; then
          echo -e "${BR_YELLOW}Aborted by User${BR_NORM}"
          exit
        elif [[ "$REPLY" = [0-9]* ]] && [ "$REPLY" -eq 1 ]; then
          BRcompression="gzip"
          break
        elif [[ "$REPLY" = [0-9]* ]] && [ "$REPLY" -eq 2 ]; then
          BRcompression="xz"
          break
        else
          echo -e "${BR_RED}Please enter a valid option from the list${BR_NORM}"
        fi
      done
    fi

    while [ -z "$BRuseroptions" ]; do
      echo -e "\n${BR_CYAN}Enter additional $BRarchiver options?${BR_NORM}"
      read -p "(y/N):" an

      if [ -n "$an" ]; then
        def=$an
      else
        def="n"
      fi

      if [ "$def" = "y" ] || [ "$def" = "Y" ]; then
        BRuseroptions="Yes"
        read -p "Enter options (See tar --help or man bsdtar):" BR_USER_OPTS
      elif [ $def = "n" ] || [ $def = "N" ]; then
        BRuseroptions="No"
      else
        echo -e "${BR_RED}Please enter a valid option${BR_NORM}"
      fi
    done

    IFS=$DEFAULTIFS

    echo -e "\n${BR_SEP}SUMMARY"
    show_summary

    while [ -z "$BRcontinue" ]; do
      echo -e "${BR_CYAN}Continue?${BR_NORM}"
      read -p "(Y/n):" an

      if [ -n "$an" ]; then
        def=$an
      else
        def="y"
      fi

      if [ "$def" = "y" ] || [ "$def" = "Y" ]; then
        BRcontinue="y"
      elif [ "$def" = "n" ] || [ "$def" = "N" ]; then
        BRcontinue="n"
        echo -e "${BR_YELLOW}Aborted by User${BR_NORM}"
        exit
      else
        echo -e "${BR_RED}Please enter a valid option${BR_NORM}"
      fi
    done

    prepare
    set_tar_options
    run_calc
    total=$(cat /tmp/filelist | wc -l)
    sleep 1
    echo " "
    if [ "$BRarchiver" = "bsdtar" ]; then
      run_tar | tee /tmp/bsdtar_out
    elif [ "$BRarchiver" = "tar" ]; then
      run_tar 2>>"$BRFOLDER"/backup.log
    fi | while read ln; do b=$(( b + 1 )) && echo -en "\rCompressing: $(($b*100/$total))%"; done

    echo -ne "\n${BR_WRK}Setting permissions"
    OUTPUT=$(chmod ugo+rw -R "$BRFOLDER" 2>&1) && echo -e "\r[${BR_GREEN}SUCCESS${BR_NORM}]" || echo -e "\r[${BR_RED}FAILURE${BR_NORM}\n$OUTPUT]"

    if [ "$BRarchiver" = "bsdtar" ] && [ -f /tmp/b_error ]; then
      cat /tmp/bsdtar_out >> "$BRFOLDER"/backup.log
    fi

    if [ -z "$BRquiet" ]; then
      exit_screen; read -s a
    else
      exit_screen_quiet
    fi

  elif [ "$BRinterface" = "dialog" ]; then
    exec 3>&1
    unset BR_NORM BR_RED BR_GREEN BR_YELLOW BR_BLUE BR_MAGENTA BR_CYAN BR_BOLD

    if [ -z "$BRFOLDER" ]; then
      dialog --title "$BR_VERSION" --msgbox "$(info_screen)" 22 70
    fi

    if [ -z "$BRFOLDER" ]; then
      dialog --yesno "The default folder for creating the backup image is / (root).\n\nSave in the default folder?" 8 65
      if [ "$?" = "0" ]; then
        BRFOLDER="/"
      else
        BRpath=/
        while [ -z "$BRFOLDER" ]; do
          show_path
          BRselect=$(dialog --title "$BRcurrentpath" --no-cancel --extra-button --extra-label Set --menu "Set destination folder: (Highlight a directory and press Set)" 30 90 30 "<--UP" .. $(dir_list) 2>&1 1>&3)
          if [ "$?" = "3" ]; then
            if [ "$BRselect" = "<--UP" ]; then
              BRpath="$BRpath"
            else
              BRFOLDER="$BRpath${BRselect//\\/ }/"
              if [[ "$BRpath" == *//* ]]; then
                BRFOLDER="${BRFOLDER#*/}"
              fi
            fi
          else
            if [ "$BRselect" = "<--UP" ]; then
              BRpath="$(dirname "$BRpath")/"
            else
              BRpath="$BRpath$BRselect/"
              BRpath="${BRpath//\\/ }"
            fi
          fi
        done
      fi
    fi

    if [ -z "$BRhome" ]; then
      REPLY=$(dialog --cancel-label Quit --menu "Home (/home) directory options:" 13 50 13 1 Include 2 "Only hidden files and folders" 3 Exclude 2>&1 1>&3)
      if [ "$?" = "1" ]; then exit; fi

      if [ "$REPLY" = "1" ]; then
        BRhome="Yes"
      elif [ "$REPLY" = "2" ]; then
        BRhome="No"
        BRhidden="Yes"
      elif [ "$REPLY" = "3" ]; then
        BRhome="No"
        BRhidden="No"
      fi
    fi

    if [ -z "$BRarchiver" ]; then
      BRarchiver=$(dialog --cancel-label Quit --menu "Select archiver:" 12 35 12 tar "GNU Tar" bsdtar "Libarchive Tar" 2>&1 1>&3)
      if [ "$?" = "1" ]; then exit; fi
    fi

    if [ "$BRarchiver" = "bsdtar" ] && [ -z $(which bsdtar 2> /dev/null) ]; then
      if [ -z "$BRnocolor" ]; then
        color_variables
      fi
      echo -e "[${BR_RED}ERROR${BR_NORM}] Package bsdtar is not installed. Install the package and re-run the script"
      exit
    fi

    if [ -z "$BRcompression" ]; then
      BRcompression=$(dialog --cancel-label Quit --menu "Select compression type:" 12 35 12 gzip "Fast, big file" xz "Slow, smaller file" 2>&1 1>&3)
      if [ "$?" = "1" ]; then exit; fi
    fi

    if [ -z "$BRuseroptions" ]; then
      dialog --yesno "Specify additional $BRarchiver options?" 6 39
      if [ "$?" = "0" ]; then
        BRuseroptions="Yes"
        BR_USER_OPTS=$(dialog --no-cancel --inputbox "Enter options: (See tar --help or man bsdtar)" 8 70 2>&1 1>&3)
      else
        BRuseroptions="No"
      fi
    fi

    if [ -z "$BRcontinue" ]; then
      dialog --title "Summary" --yes-label "OK" --no-label "Quit" --yesno "$(show_summary) $(echo -e "\n\nPress OK to continue or Quit to abort.")" 0 0
      if [ "$?" = "1" ]; then exit; fi
    fi

    prepare
    set_tar_options
    run_calc | dialog --progressbox 3 40
    total=$(cat /tmp/filelist | wc -l)
    sleep 1

    if [ "$BRarchiver" = "bsdtar" ]; then
      run_tar | tee /tmp/bsdtar_out
    elif [ "$BRarchiver" = "tar" ]; then
      run_tar 2>>"$BRFOLDER"/backup.log
    fi |

    while read ln; do
      b=$(( b + 1 ))
      per=$(($b*100/$total))
      if [[ $per -gt $lastper ]]; then
        lastper=$per
        echo $lastper
      fi
    done | dialog --gauge "Compressing..." 0 50

    chmod ugo+rw -R "$BRFOLDER" 2>> "$BRFOLDER"/backup.log

    if [ "$BRarchiver" = "bsdtar" ] && [ -f /tmp/b_error ]; then
      cat /tmp/bsdtar_out >> "$BRFOLDER"/backup.log
    fi

    if [ -f /tmp/b_error ]; then diag_tl="Error"; else diag_tl="Info"; fi

    if [ -z "$BRquiet" ]; then
      dialog --yes-label "OK" --no-label "View Log" --title "$diag_tl" --yesno "$(exit_screen)" 0 0
      if [ "$?" = "1" ]; then dialog --textbox "$BRFOLDER"/backup.log 0 0; fi
    else
      dialog --title "$diag_tl" --infobox "$(exit_screen_quiet)" 0 0
    fi
  fi

  if [ -f /tmp/excludelist ]; then rm /tmp/excludelist; fi
  if [ -f /tmp/b_error ]; then rm /tmp/b_error; fi
  if [ -f /tmp/filelist ]; then rm /tmp/filelist; fi
  if [ -f /tmp/bsdtar_out ]; then rm /tmp/bsdtar_out; fi
  if [ -f /target_architecture.$(uname -m) ]; then rm /target_architecture.$(uname -m); fi

elif [ "$BRmode" = "Restore" ] || [ "$BRmode" = "Transfer" ] || [ "$BRmode" = "Both" ]; then

  info_screen() {
    if [ "$BRmode" = "Restore" ]; then
      echo -e "\n${BR_YELLOW}This mode will restore a backup image of your system in user defined partitions."
    elif [ "$BRmode" = "Transfer" ]; then
      echo -e "\n${BR_YELLOW}This mode will transfer this system in user defined partitions."
    fi
    echo -e "\n==>Make sure you have created and formatted at least one partition\n   for root (/) and optionally partitions for /home and /boot."
    echo -e "\n==>Make sure that target LVM volume groups are activated and target\n   RAID arrays are properly assembled."
    echo -e "\n==>If you didn't include /home directory in the backup and you already \n   have a seperate /home partition, simply enter it when prompted."
    if [ "$BRmode" = "Restore" ]; then
      echo -e "\n==>Also make sure that this system and the system you want to restore\n   have the same architecture."
      echo -e "\n==>In case of GNU tar, Fedora backups can only be restored from a Fedora\n   enviroment, due to extra tar options.${BR_NORM}"
      echo -e "\n${BR_CYAN}Press ENTER to continue.${BR_NORM}"
    fi
  }

  exit_screen() {
    if [ -f /tmp/bl_error ]; then
      echo -e "\n${BR_RED}Error installing $BRbootloader. Check /tmp/restore.log for details.\n\n${BR_CYAN}Press ENTER to unmount all remaining (engaged) devices.${BR_NORM}"
    elif [ -n "$BRgrub" ] || [ -n "$BRsyslinux" ]; then
      echo -e "\n${BR_CYAN}Completed. Log: /tmp/restore.log\n\nPress ENTER to unmount all remaining (engaged) devices, then reboot your system.${BR_NORM}"
    else
      echo -e "\n${BR_CYAN}Completed. Log: /tmp/restore.log"
      echo -e "\n${BR_YELLOW}No bootloader found, so this is the right time to install and\nupdate one. To do so:"
      echo -e "\n==>For internet connection to work, on a new terminal with root\n   access enter: cp -L /etc/resolv.conf /mnt/target/etc/resolv.conf"
      echo -e "\n==>Then chroot into the restored system: chroot /mnt/target"
      echo -e "\n==>Install and update a bootloader"
      echo -e "\n==>When done, leave chroot: exit"
      echo -e "\n==>Finally, return to this window and press ENTER to unmount\n   all remaining (engaged) devices.${BR_NORM}"
    fi
  }

  exit_screen_quiet() {
    if [ -f /tmp/bl_error ]; then
      echo -e "\n${BR_RED}Error installing $BRbootloader.\nCheck /tmp/restore.log for details.${BR_NORM}"
    else
      echo -e "\n${BR_CYAN}Completed. Log: /tmp/restore.log${BR_NORM}"
    fi
  }

  ok_status() {
    echo -e "\r[${BR_GREEN}SUCCESS${BR_NORM}]"
    custom_ok="y"
  }

  error_status() {
    echo -e "\r[${BR_RED}FAILURE${BR_NORM}\n$OUTPUT]"
    BRSTOP="y"
  }

  item_type() {
    if [ -d "$BRpath/$f" ]; then
      echo dir
    else
      echo -
    fi
  }

  file_list() {
    DEFAULTIFS=$IFS
    IFS=$'\n'
    for f in $(ls --group-directories-first "$BRpath"); do echo "${f// /\\}" $(item_type); done
    IFS=$DEFAULTIFS
  }

  show_path() {
    if [ "$BRpath" = "/" ]; then
      BRcurrentpath="/"
    else
      BRcurrentpath="${BRpath#*/}/"
    fi
  }

  detect_root_fs_size() {
    BRfsystem=$(blkid -s TYPE -o value $BRroot)
    BRfsize=$(lsblk -d -n -o size 2> /dev/null $BRroot)
  }

  detect_filetype() {
    if file "$BRfile" | grep -w gzip > /dev/null; then
      BRfiletype="gz"
    elif file "$BRfile" | grep -w XZ > /dev/null; then
      BRfiletype="xz"
    else
      BRfiletype="wrong"
    fi
  }

  detect_filetype_url() {
    if file /mnt/target/fullbackup | grep -w gzip > /dev/null; then
      BRfiletype="gz"
    elif file /mnt/target/fullbackup | grep -w XZ > /dev/null; then
      BRfiletype="xz"
    else
      BRfiletype="wrong"
    fi
  }

  detect_distro() {
    if [ "$BRmode" = "Restore" ]; then
      if grep -Fxq "etc/yum.conf" /tmp/filelist 2>/dev/null; then
        BRdistro="Fedora"
      elif grep -Fxq "etc/pacman.conf" /tmp/filelist 2>/dev/null; then
        BRdistro="Arch"
      elif grep -Fxq "etc/apt/sources.list" /tmp/filelist 2>/dev/null; then
        BRdistro="Debian"
      else
        BRdistro="Unsupported"
      fi

    elif [ "$BRmode" = "Transfer" ]; then
      if [ -f /etc/yum.conf ]; then
        BRdistro="Fedora"
      elif [ -f /etc/pacman.conf ]; then
        BRdistro="Arch"
      elif [ -f /etc/apt/sources.list ]; then
        BRdistro="Debian"
      else
        BRdistro="Unsupported"
      fi
    fi
  }

  detect_syslinux_root() {
    if [[ "$BRroot" == *mapper* ]]; then
      echo "root=$BRroot"
    else
      echo "root=UUID=$(blkid -s UUID -o value $BRroot)"
    fi
  }

  detect_fstab_root() {
    if [[ "$BRroot" == *dev/md* ]]; then
      echo "$BRroot"
    else
      echo "UUID=$(blkid -s UUID -o value $BRroot)"
    fi
  }

  detect_partition_table() {
    if [[ "$BRsyslinux" == *md* ]]; then
      BRsyslinuxdisk="$BRdev"
    else
      BRsyslinuxdisk="$BRsyslinux"
    fi
    if dd if="$BRsyslinuxdisk" skip=64 bs=8 count=1 2>/dev/null | grep -w "EFI PART" > /dev/null; then
      BRpartitiontable="gpt"
    else
      BRpartitiontable="mbr"
    fi
  }

  set_syslinux_flags_and_paths() {
    if [ "$BRpartitiontable" = "gpt" ]; then
      echo "Setting legacy_boot flag on $BRdev$BRpart"
      sgdisk $BRdev --attributes=$BRpart:set:2 &>> /tmp/restore.log || touch /tmp/bl_error
      BRsyslinuxmbr="gptmbr.bin"
    else
      echo "Setting boot flag on $BRdev$BRpart"
      sfdisk $BRdev -A $BRpart &>> /tmp/restore.log || touch /tmp/bl_error
      BRsyslinuxmbr="mbr.bin"
    fi
    if [ "$BRdistro" = Debian ]; then
      BRsyslinuxpath="/mnt/target/usr/lib/syslinux"
    elif [ $BRdistro = Fedora ]; then
      BRsyslinuxpath="/mnt/target/usr/share/syslinux"
    fi
  }

  generate_syslinux_cfg() {
    echo -e "UI menu.c32\nPROMPT 0\nMENU TITLE Boot Menu\nTIMEOUT 50" > /mnt/target/boot/syslinux/syslinux.cfg
    if [ "$BRfsystem" = "btrfs" ] && [ "$BRrootsubvol" = "y" ]; then
      syslinuxrootsubvol="rootflags=subvol=$BRrootsubvolname"
    fi
    for BRinitrd in `find /mnt/target/boot -name vmlinuz* | sed 's_/mnt/target/boot/vmlinuz-*__'` ; do
      if [ $BRdistro = Arch ]; then
        echo -e "LABEL arch\n\tMENU LABEL Arch $BRinitrd\n\tLINUX ../vmlinuz-$BRinitrd\n\tAPPEND $(detect_syslinux_root) $syslinuxrootsubvol $BR_KERNEL_OPTS rw\n\tINITRD ../initramfs-$BRinitrd.img" >> /mnt/target/boot/syslinux/syslinux.cfg
        echo -e "LABEL archfallback\n\tMENU LABEL Arch $BRinitrd fallback\n\tLINUX ../vmlinuz-$BRinitrd\n\tAPPEND $(detect_syslinux_root) $syslinuxrootsubvol $BR_KERNEL_OPTS rw\n\tINITRD ../initramfs-$BRinitrd-fallback.img" >> /mnt/target/boot/syslinux/syslinux.cfg
      elif [ $BRdistro = Debian ]; then
        echo -e "LABEL debian\n\tMENU LABEL Debian-$BRinitrd\n\tLINUX ../vmlinuz-$BRinitrd\n\tAPPEND $(detect_syslinux_root) $syslinuxrootsubvol $BR_KERNEL_OPTS ro quiet\n\tINITRD ../initrd.img-$BRinitrd" >> /mnt/target/boot/syslinux/syslinux.cfg
      elif [ $BRdistro = Fedora ]; then
        echo -e "LABEL fedora\n\tMENU LABEL Fedora-$BRinitrd\n\tLINUX ../vmlinuz-$BRinitrd\n\tAPPEND $(detect_syslinux_root) $syslinuxrootsubvol $BR_KERNEL_OPTS ro quiet\n\tINITRD ../initramfs-$BRinitrd.img" >> /mnt/target/boot/syslinux/syslinux.cfg
      fi
    done
  }

  run_tar() {
    if [ "$BRarchiver" = "tar" ]; then
      if [ "$BRfiletype" = "gz" ]; then
        $BRarchiver xvpfz /mnt/target/fullbackup -C /mnt/target && (echo "System decompressed successfully" >> /tmp/restore.log)
      elif [ "$BRfiletype" = "xz" ]; then
        $BRarchiver xvpfJ /mnt/target/fullbackup -C /mnt/target && (echo "System decompressed successfully" >> /tmp/restore.log)
      fi
    elif [ "$BRarchiver" = "bsdtar" ]; then
      if [ "$BRfiletype" = "gz" ]; then
        $BRarchiver xvpfz /mnt/target/fullbackup -C /mnt/target 2>&1 && (echo "System decompressed successfully" >> /tmp/restore.log) || touch /tmp/r_error
      elif [ "$BRfiletype" = "xz" ]; then
        $BRarchiver xvpfJ /mnt/target/fullbackup -C /mnt/target 2>&1 && (echo "System decompressed successfully" >> /tmp/restore.log) || touch /tmp/r_error
      fi
    fi
  }

  run_calc() {
    if [ "$BRhidden" = "n" ]; then
      rsync -av / /mnt/target --exclude={/dev/*,/proc/*,/sys/*,/tmp/*,/run/*,/mnt/*,/media/*,lost+found,/home/*/.gvfs} --dry-run 2> /dev/null | tee /tmp/filelist
    elif [ "$BRhidden" = "y" ]; then
      rsync -av / /mnt/target --exclude={/dev/*,/proc/*,/sys/*,/tmp/*,/run/*,/mnt/*,/media/*,lost+found,/home/*/.gvfs,/home/*/[^.]*} --dry-run 2> /dev/null | tee /tmp/filelist
    fi
  }

  run_rsync() {
    if [ "$BRhidden" = "n" ]; then
      rsync -aAXv / /mnt/target --exclude={/dev/*,/proc/*,/sys/*,/tmp/*,/run/*,/mnt/*,/media/*,lost+found,/home/*/.gvfs} && (echo "System transferred successfully" >> /tmp/restore.log)
    elif [ "$BRhidden" = "y" ]; then
      rsync -aAXv / /mnt/target --exclude={/dev/*,/proc/*,/sys/*,/tmp/*,/run/*,/mnt/*,/media/*,lost+found,/home/*/.gvfs,/home/*/[^.]*} && (echo "System transferred successfully" >> /tmp/restore.log)
    fi
  }

  count_gauge() {
    while read ln; do
      b=$(( b + 1 ))
      per=$(($b*100/$total))
      if [[ $per -gt $lastper ]]; then
        lastper=$per
        echo $lastper
      fi
    done
  }

  count_gauge_wget() {
    while read ln; do
      if [[ $ln -gt $lastln ]]; then
        lastln=$ln
        echo $lastln
      fi
    done
  }

  hide_used_parts() {
    grep -vw -e `echo /dev/"${BRroot##*/}"` -e `echo /dev/"${BRswap##*/}"` -e `echo /dev/"${BRhome##*/}"` -e `echo /dev/"${BRboot##*/}"`
  }

  hide_used_parts_lvm() {
    grep -vw -e `echo /dev/mapper/"${BRroot##*/}"` -e `echo /dev/mapper/"${BRswap##*/}"` -e `echo /dev/mapper/"${BRhome##*/}"` -e `echo /dev/mapper/"${BRboot##*/}"`
  }

  part_list_cli() {
    for f in $(find /dev -regex "/dev/[hs]d[a-z][0-9]+"); do echo -e "$f $(lsblk -d -n -o size $f)"; done | sort | hide_used_parts
    for f in $(find /dev/mapper/ | grep '-'); do echo -e "$f $(lsblk -d -n -o size $f)"; done | hide_used_parts_lvm
    for f in $(find /dev -regex "^/dev/md[0-9]+$"); do echo -e "$f $(lsblk -d -n -o size $f)"; done | hide_used_parts
  }

  part_list_dialog() {
    for f in $(find /dev -regex "/dev/[hs]d[a-z][0-9]+"); do echo -e "$f $(lsblk -d -n -o size $f)|$(blkid -s TYPE -o value $f)"; done | sort
    for f in $(find /dev/mapper/ | grep '-'); do echo -e "$f $(lsblk -d -n -o size $f)|$(blkid -s TYPE -o value $f)"; done
    for f in $(find /dev -regex "^/dev/md[0-9]+$"); do echo -e "$f $(lsblk -d -n -o size $f)|$(blkid -s TYPE -o value $f)"; done
  }

  disk_list_dialog() {
    for f in /dev/[hs]d[a-z]; do echo -e "$f $(lsblk -d -n -o size $f)"; done
    for f in $(find /dev -regex "^/dev/md[0-9]+$"); do echo -e "$f $(lsblk -d -n -o size $f)"; done
  }

  update_part_list() {
    list=(`part_list_cli 2>/dev/null`)
  }

  disk_report() {
    for i in /dev/[hs]d[a-z]; do
      echo -e "\n$i  ($(lsblk -d -n -o model $i)  $(lsblk -d -n -o size $i))"
      for f in $i[0-9]; do echo -e "\t\t$f  $(blkid -s TYPE -o value $f)  $(lsblk -d -n -o size $f)  $(lsblk -d -n -o mountpoint 2> /dev/null $f)"; done
    done
  }

  check_input() {
    if [ -n "$BRfile" ] && [ ! -f "$BRfile" ]; then
      echo -e "[${BR_RED}ERROR${BR_NORM}] File not found: $BRfile"
      BRSTOP="y"
    elif [ -n "$BRfile" ]; then
      detect_filetype
      if [ "$BRfiletype" = "wrong" ]; then
        echo -e "[${BR_RED}ERROR${BR_NORM}] Invalid file type. File must be a gzip or xz compressed archive"
        BRSTOP="y"
      fi
    fi

    if [ -n "$BRfile" ] && [ -n "$BRurl" ]; then
      echo -e "[${BR_YELLOW}WARNING${BR_NORM}] Dont use both local file and url at the same time"
      BRSTOP="y"
    fi

    if [ -n "$BRfile" ] || [ -n "$BRurl" ] && [ -z "$BRarchiver" ]; then
      echo -e "[${BR_YELLOW}WARNING${BR_NORM}] You must specify archiver"
      BRSTOP="y"
    fi

    if [ -n "$BRfile" ] || [ -n "$BRurl" ] && [ -n "$BRrestore" ]; then
      echo -e "[${BR_YELLOW}WARNING${BR_NORM}] Dont use local file / url and transfer mode at the same time"
      BRSTOP="y"
    fi

    if [ "$BRmode" = "Transfer" ]; then
      if [ -z $(which rsync 2> /dev/null) ];then
        echo -e "[${BR_RED}ERROR${BR_NORM}] Package rsync is not installed. Install the package and re-run the script"
        BRSTOP="y"
      fi
      if [ -n "$BRgrub" ] && [ ! -d /usr/lib/grub/i386-pc ]; then
        echo -e "[${BR_RED}ERROR${BR_NORM}] Grub not found"
        BRSTOP="y"
      elif [ -n "$BRsyslinux" ] && [ -z $(which extlinux 2> /dev/null) ];then
        echo -e "[${BR_RED}ERROR${BR_NORM}] Syslinux not found"
        BRSTOP="y"
      fi
    fi

    if [ -n "$BRhome" ] || [ -n "$BRboot" ] || [ -n "$BRother" ] || [ -n "$BRrootsubvol" ] || [ -n "$BRsubvolother" ] && [ -z "$BRroot" ]; then
      echo -e "[${BR_RED}ERROR${BR_NORM}] You must specify a target root partition."
      BRSTOP="y"
    fi

    if [ -n "$BRroot" ]; then
      for i in $(find /dev -regex "/dev/[hs]d[a-z][0-9]+"); do if [[ $i == ${BRroot} ]] ; then BRrootcheck="true" ; fi; done
      for i in $(find /dev/mapper/ | grep '-'); do if [[ $i == ${BRroot} ]] ; then BRrootcheck="true" ; fi; done
      for i in $(find /dev -regex "^/dev/md[0-9]+$"); do if [[ $i == ${BRroot} ]] ; then BRrootcheck="true" ; fi; done
      if [ ! "$BRrootcheck" = "true" ]; then
        echo -e "[${BR_RED}ERROR${BR_NORM}] Wrong root partition: $BRroot"
        BRSTOP="y"
      elif pvdisplay 2>&1 | grep -w $BRroot > /dev/null; then
        echo -e "[${BR_YELLOW}WARNING${BR_NORM}] $BRroot contains lvm physical volume, refusing to use it. Use a logical volume instead"
        BRSTOP="y"
      elif [[ ! -z `lsblk -d -n -o mountpoint 2> /dev/null $BRroot` ]]; then
        echo -e "[${BR_YELLOW}WARNING${BR_NORM}] $BRroot is already mounted as $(lsblk -d -n -o mountpoint 2> /dev/null $BRroot), refusing to use it"
        BRSTOP="y"
      fi
    fi

    if [ -n "$BRswap" ]; then
      for i in $(find /dev -regex "/dev/[hs]d[a-z][0-9]+"); do if [[ $i == ${BRswap} ]] ; then BRswapcheck="true" ; fi; done
      for i in $(find /dev/mapper/ | grep '-'); do if [[ $i == ${BRswap} ]] ; then BRswapcheck="true" ; fi; done
      for i in $(find /dev -regex "^/dev/md[0-9]+$"); do if [[ $i == ${BRswap} ]] ; then BRswapcheck="true" ; fi; done
      if [ ! "$BRswapcheck" = "true" ]; then
        echo -e "[${BR_RED}ERROR${BR_NORM}] Wrong swap partition: $BRswap"
        BRSTOP="y"
      elif pvdisplay 2>&1 | grep -w $BRswap > /dev/null; then
        echo -e "[${BR_YELLOW}WARNING${BR_NORM}] $BRswap contains lvm physical volume, refusing to use it. Use a logical volume instead"
        BRSTOP="y"
      fi
      if [ "$BRswap" == "$BRroot" ]; then
        echo -e "[${BR_YELLOW}WARNING${BR_NORM}] $BRswap already used"
        BRSTOP="y"
      fi
    fi

    if [ "$BRcustom" = "y" ]; then
      BRdevused=(`for i in ${BRcustomparts[@]}; do BRdevice=$(echo $i | cut -f2 -d"=") && echo $BRdevice; done | sort | uniq -d`)
      BRmpointused=(`for i in ${BRcustomparts[@]}; do BRmpoint=$(echo $i | cut -f1 -d"=") && echo $BRmpoint; done | sort | uniq -d`)
      if [ -n "$BRdevused" ]; then
        for a in ${BRdevused[@]}; do
          echo -e "[${BR_YELLOW}WARNING${BR_NORM}] $a already used"
          BRSTOP="y"
        done
      fi
      if [ -n "$BRmpointused" ]; then
        for a in ${BRmpointused[@]}; do
          echo -e "[${BR_YELLOW}WARNING${BR_NORM}] Duplicate mountpoint: $a"
          BRSTOP="y"
        done
      fi

      while read ln; do
        BRmpoint=$(echo $ln | cut -f1 -d"=")
        BRdevice=$(echo $ln | cut -f2 -d"=")

        for i in $(find /dev -regex "/dev/[hs]d[a-z][0-9]+"); do if [[ $i == ${BRdevice} ]] ; then BRcustomcheck="true" ; fi; done
        for i in $(find /dev/mapper/ | grep '-'); do if [[ $i == ${BRdevice} ]] ; then BRcustomcheck="true" ; fi; done
        for i in $(find /dev -regex "^/dev/md[0-9]+$"); do if [[ $i == ${BRdevice} ]] ; then BRcustomcheck="true" ; fi; done
        if [ ! "$BRcustomcheck" = "true" ]; then
          echo -e "[${BR_RED}ERROR${BR_NORM}] Wrong $BRmpoint partition: $BRdevice"
          BRSTOP="y"
        elif pvdisplay 2>&1 | grep -w $BRdevice > /dev/null; then
          echo -e "[${BR_YELLOW}WARNING${BR_NORM}] $BRdevice contains lvm physical volume, refusing to use it. Use a logical volume instead"
          BRSTOP="y"
        elif [[ ! -z `lsblk -d -n -o mountpoint 2> /dev/null $BRdevice` ]]; then
          echo -e "[${BR_YELLOW}WARNING${BR_NORM}] $BRdevice is already mounted as $(lsblk -d -n -o mountpoint 2> /dev/null $BRdevice), refusing to use it"
          BRSTOP="y"
        fi
        if [ "$BRdevice" == "$BRroot" ] || [ "$BRdevice" == "$BRswap" ]; then
          echo -e "[${BR_YELLOW}WARNING${BR_NORM}] $BRdevice already used"
          BRSTOP="y"
        fi
        if [ "$BRmpoint" = "/" ]; then
          echo -e "[${BR_YELLOW}WARNING${BR_NORM}] Dont assign root partition as custom"
          BRSTOP="y"
        fi
        if [ "$BRsubvolother" = "y" ]; then
          for item in "${BRsubvols[@]}"; do
            if [[ "$BRmpoint" == *"$item"* ]] && [[ "$item" == *"$BRmpoint"* ]]; then
              echo -e "[${BR_YELLOW}WARNING${BR_NORM}] Dont use partitions inside btrfs subvolumes"
              BRSTOP="y"
            fi
          done
        fi
        if [[ ! "$BRmpoint" == /* ]]; then
          echo -e "[${BR_YELLOW}WARNING${BR_NORM}] Wrong mountpoint syntax: $BRmpoint"
          BRSTOP="y"
        fi
        unset BRcustomcheck
      done < <( for a in ${BRcustomparts[@]}; do BRmpoint=$(echo $a | cut -f1 -d"="); BRdevice=$(echo $a | cut -f2 -d"="); echo "$BRmpoint=$BRdevice"; done )
    fi

    if [ "$BRsubvolother" = "y" ]; then
      BRsubvolused=(`for i in ${BRsubvols[@]}; do echo $i; done | sort | uniq -d`)
      if [ -n "$BRsubvolused" ]; then
        for a in ${BRsubvolused[@]}; do
          echo -e "[${BR_YELLOW}WARNING${BR_NORM}] Duplicate subvolume: $a"
          BRSTOP="y"
        done
      fi

      while read ln; do
        if [[ ! "$ln" == /* ]]; then
          echo -e "[${BR_YELLOW}WARNING${BR_NORM}] Wrong subvolume syntax: $ln"
          BRSTOP="y"
        fi
        if [ "$ln" = "/" ]; then
          echo -e "[${BR_YELLOW}WARNING${BR_NORM}] Use -R to assign root subvolume"
          BRSTOP="y"
        fi
      done < <( for a in ${BRsubvols[@]}; do echo $a; done )
    fi

    if [ -n "$BRgrub" ]; then
      for i in /dev/[hs]d[a-z]; do if [[ $i == ${BRgrub} ]] ; then BRgrubcheck="true" ; fi; done
      for i in $(find /dev -regex "^/dev/md[0-9]+$"); do if [[ $i == ${BRgrub} ]] ; then BRgrubcheck="true" ; fi; done
      if [ ! "$BRgrubcheck" = "true" ]; then
        echo -e "[${BR_RED}ERROR${BR_NORM}] Wrong disk for grub: $BRgrub"
        BRSTOP="y"
      fi
    fi

    if [ -n "$BRsyslinux" ]; then
      for i in /dev/[hs]d[a-z]; do if [[ $i == ${BRsyslinux} ]] ; then BRsyslinuxcheck="true" ; fi; done
      for i in $(find /dev -regex "^/dev/md[0-9]+$"); do if [[ $i == ${BRsyslinux} ]] ; then BRsyslinuxcheck="true" ; fi; done
      if [ ! "$BRsyslinuxcheck" = "true" ]; then
        echo -e "[${BR_RED}ERROR${BR_NORM}] Wrong disk for syslinux: $BRsyslinux"
        BRSTOP="y"
      fi
      if [[ "$BRsyslinux" == *md* ]]; then
        for f in `cat /proc/mdstat | grep $(echo "$BRsyslinux" | cut -c 6-) | grep -oP '[hs]d[a-z][0-9]'` ; do
          BRdev=`echo /dev/$f | cut -c -8`
        done
      fi
      detect_partition_table
      if [ "$BRpartitiontable" = "gpt" ] && [ -z $(which sgdisk 2> /dev/null) ]; then
        echo -e "[${BR_RED}ERROR${BR_NORM}] Package gptfdisk/gdisk is not installed. Install the package and re-run the script"
        BRSTOP="y"
      fi
    fi

    if [ -n "$BRgrub" ] && [ -n "$BRsyslinux" ]; then
      echo -e "[${BR_YELLOW}WARNING${BR_NORM}] Dont use both bootloaders at the same time"
      BRSTOP="y"
    fi

    if [ "$BRarchiver" = "bsdtar" ] && [ -z $(which bsdtar 2> /dev/null) ]; then
      echo -e "[${BR_RED}ERROR${BR_NORM}] Package bsdtar is not installed. Install the package and re-run the script"
      BRSTOP="y"
    fi

    if [ -n "$BRSTOP" ]; then
      exit
    fi
  }

  mount_all() {
    echo -e "\n${BR_SEP}MOUNTING"
    echo -ne "${BR_WRK}Making working directory"
    OUTPUT=$(mkdir /mnt/target 2>&1) && ok_status || error_status

    echo -ne "${BR_WRK}Mounting $BRroot"
    OUTPUT=$(mount -o $BR_MOUNT_OPTS $BRroot /mnt/target 2>&1) && ok_status || error_status
    if [ -n "$BRSTOP" ]; then
      echo -e "\n[${BR_RED}ERROR${BR_NORM}] Error while mounting partitions"
      clean_files
      rm -r /mnt/target
      exit
    fi

    if [ "$(ls -A /mnt/target | grep -vw "lost+found")" ]; then
      echo -e "[${BR_RED}ERROR${BR_NORM}] Root partition not empty, refusing to use it"
      echo -e "[${BR_CYAN}INFO${BR_NORM}] Root partition must be formatted and cleaned"
      echo -ne "${BR_WRK}Unmounting $BRroot"
      sleep 1
      OUTPUT=$(umount $BRroot 2>&1) && (ok_status && rm_work_dir) || (error_status && echo -e "[${BR_YELLOW}WARNING${BR_NORM}] /mnt/target remained")
      exit
    fi

    if [ "$BRfsystem" = "btrfs" ] && [ "$BRrootsubvol" = "y" ]; then
      echo -ne "${BR_WRK}Creating $BRrootsubvolname"
      OUTPUT=$(btrfs subvolume create /mnt/target/$BRrootsubvolname 2>&1 1> /dev/null) && ok_status || error_status

      if [ "$BRsubvolother" = "y" ]; then
        while read ln; do
          echo -ne "${BR_WRK}Creating $BRrootsubvolname$ln"
          OUTPUT=$(btrfs subvolume create /mnt/target/$BRrootsubvolname$ln 2>&1 1> /dev/null) && ok_status || error_status
        done< <(for a in "${BRsubvols[@]}"; do echo "$a"; done | sort)
      fi

      echo -ne "${BR_WRK}Unmounting $BRroot"
      OUTPUT=$(umount $BRroot 2>&1) && ok_status || error_status

      echo -ne "${BR_WRK}Mounting $BRrootsubvolname"
      OUTPUT=$(mount -t btrfs -o $BR_MOUNT_OPTS,subvol=$BRrootsubvolname $BRroot /mnt/target 2>&1) && ok_status || error_status
      if [ -n "$BRSTOP" ]; then
        echo -e "\n[${BR_RED}ERROR${BR_NORM}] Error while making subvolumes"
        unset BRSTOP
        clean_unmount_in
      fi
    fi

    if [ "$BRcustom" = "y" ]; then
      BRsorted=(`for i in ${BRcustomparts[@]}; do echo $i; done | sort -k 1,1 -t =`)
      unset custom_ok
      for i in ${BRsorted[@]}; do
        BRdevice=$(echo $i | cut -f2 -d"=")
        BRmpoint=$(echo $i | cut -f1 -d"=")
        echo -ne "${BR_WRK}Mounting $BRdevice"
        mkdir -p /mnt/target$BRmpoint
        OUTPUT=$(mount $BRdevice /mnt/target$BRmpoint 2>&1) && ok_status || error_status
        if [ -n "$custom_ok" ]; then
          unset custom_ok
          BRumountparts+=($BRmpoint=$BRdevice)
          if [ "$(ls -A /mnt/target$BRmpoint | grep -vw "lost+found")" ]; then
            echo -e "[${BR_CYAN}INFO${BR_NORM}] $BRmpoint partition not empty"
          fi
        fi
      done
      if [ -n "$BRSTOP" ]; then
        echo -e "\n[${BR_RED}ERROR${BR_NORM}] Error while mounting partitions"
        unset BRSTOP
        clean_unmount_in
      fi
    fi
  }

  show_summary() {
    echo -e "${BR_YELLOW}PARTITIONS:"
    echo -e "root partition: $BRroot $BRfsystem $BRfsize $BR_MOUNT_OPTS"

    if [ "$BRcustom" = "y" ]; then
      for i in ${BRsorted[@]}; do
        BRdevice=$(echo $i | cut -f2 -d"=")
        BRmpoint=$(echo $i | cut -f1 -d"=")
        BRcustomfs=$(df -T | grep $BRdevice | awk '{print $2}')
        BRcustomsize=$(lsblk -d -n -o size 2> /dev/null $BRdevice)
        echo "${BRmpoint#*/} partition: $BRdevice $BRcustomfs $BRcustomsize"
      done
    fi

    if [ -n "$BRswap" ]; then
      echo "swap partition: $BRswap"
    fi

    if [ "$BRfsystem" = "btrfs" ] && [ "$BRrootsubvol" = "y" ]; then
      echo -e "\nSUBVOLUMES:"
      echo "root: $BRrootsubvolname"
      if [ "$BRsubvolother" = "y" ]; then
        while read ln; do
          echo  "${ln#*/}"
        done< <(for a in "${BRsubvols[@]}"; do echo "$a"; done | sort)
      fi
    fi

    echo -e "\nBOOTLOADER:"

    if [ -n "$BRgrub" ]; then
      echo "$BRbootloader"
      if [[ "$BRgrub" == *md* ]]; then
        echo "Locations: $(echo $(cat /proc/mdstat | grep $(echo "$BRgrub" | cut -c 6-) | grep -oP '[hs]d[a-z]'))"
      else
        echo "Location: $BRgrub"
      fi
    elif [ -n "$BRsyslinux" ]; then
      echo "$BRbootloader"
      if [[ "$BRsyslinux" == *md* ]]; then
        echo "Locations: $(echo $(cat /proc/mdstat | grep $(echo "$BRsyslinux" | cut -c 6-) | grep -oP '[hs]d[a-z]'))"
      else
        echo "Location: $BRsyslinux"
      fi
      if [ -n "$BR_KERNEL_OPTS" ]; then
        echo "Kernel Options: $BR_KERNEL_OPTS"
      fi
    else
      echo "None (WARNING)"
    fi

    echo -e "\nPROCESS:"

    if [ "$BRmode" = "Restore" ]; then
      echo "Mode: $BRmode"
      echo "Archiver: $BRarchiver"
      echo "Archive: $BRfiletype compressed"
    elif [ "$BRmode" = "Transfer" ] && [ "$BRhidden" = "n" ]; then
      echo "Mode: $BRmode"
      echo "Home: Include"
    elif [ "$BRmode" = "Transfer" ] && [ "$BRhidden" = "y" ]; then
      echo "Mode: $BRmode"
      echo "Home: Only hidden files and folders"
    fi
    if [ "$BRdistro" = "Unsupported" ]; then
      echo -e "System: $BRdistro (WARNING)${BR_NORM}"
    elif [ "$BRmode" = "Restore" ]; then
      echo -e "System: $BRdistro based ${target_arch#*.}${BR_NORM}"
    elif [ "$BRmode" = "Transfer" ]; then
       echo -e "System: $BRdistro based $(uname -m)${BR_NORM}"
    fi
  }

  prepare_chroot() {
    echo -e "\n${BR_SEP}PREPARING CHROOT ENVIROMENT"
    echo -e "Binding /run"
    mount --bind /run /mnt/target/run
    echo -e "Binding /dev"
    mount --bind /dev /mnt/target/dev
    echo -e "Binding /dev/pts"
    mount --bind /dev/pts /mnt/target/dev/pts
    echo -e "Mounting /proc"
    mount -t proc /proc /mnt/target/proc
    echo -e "Mounting /sys"
    mount -t sysfs /sys /mnt/target/sys
  }

  generate_fstab() {
    mv /mnt/target/etc/fstab /mnt/target/etc/fstab-old
    if [ "$BRfsystem" = "btrfs" ] && [ "$BRrootsubvol" = "y" ]; then
      echo "$(detect_fstab_root)  /  btrfs  $BR_MOUNT_OPTS,subvol=$BRrootsubvolname,noatime  0  0" >> /mnt/target/etc/fstab
    elif [ "$BRfsystem" = "btrfs" ] && [ "$BRrootsubvol" = "n" ]; then
      echo "$(detect_fstab_root)  /  btrfs  $BR_MOUNT_OPTS,noatime  0  0" >> /mnt/target/etc/fstab
    else
      echo "$(detect_fstab_root)  /  $BRfsystem  $BR_MOUNT_OPTS,noatime  0  1" >> /mnt/target/etc/fstab
    fi

    if [ "$BRcustom" = "y" ]; then
      for i in ${BRsorted[@]}; do
        BRdevice=$(echo $i | cut -f2 -d"=")
        BRmpoint=$(echo $i | cut -f1 -d"=")
        BRcustomfs=$(df -T | grep $BRdevice | awk '{print $2}')
        if [[ "$BRdevice" == *dev/md* ]]; then
          echo "$BRdevice  $BRmpoint  $BRcustomfs  defaults  0  2" >> /mnt/target/etc/fstab
        else
          echo "UUID=$(blkid -s UUID -o value $BRdevice)  $BRmpoint  $BRcustomfs  defaults  0  2" >> /mnt/target/etc/fstab
        fi
      done
    fi

    if [ -n "$BRswap" ]; then
      if [[ "$BRswap" == *dev/md* ]]; then
        echo "$BRswap  swap  swap  defaults  0  0" >> /mnt/target/etc/fstab
      else
        echo "UUID=$(blkid -s UUID -o value $BRswap)  swap  swap  defaults  0  0" >> /mnt/target/etc/fstab
      fi
    fi
    echo -e "\n${BR_SEP}GENERATED FSTAB" >> /tmp/restore.log
    cat /mnt/target/etc/fstab >> /tmp/restore.log
  }

  build_initramfs() {
    echo -e "\n${BR_SEP}REBUILDING INITRAMFS IMAGES"
    if grep -q dev/md /mnt/target/etc/fstab; then
      echo "Generating mdadm.conf..."
      if [ "$BRdistro" = "Debian" ]; then
        if [ -f /mnt/target/etc/mdadm/mdadm.conf ]; then
          mv /mnt/target/etc/mdadm/mdadm.conf /mnt/target/etc/mdadm/mdadm.conf-old
        fi
        mdadm --examine --scan > /mnt/target/etc/mdadm/mdadm.conf
        cat /mnt/target/etc/mdadm/mdadm.conf
      else
        if [ -f /mnt/target/etc/mdadm.conf ]; then
          mv /mnt/target/etc/mdadm.conf /mnt/target/etc/mdadm.conf-old
        fi
        mdadm --examine --scan > /mnt/target/etc/mdadm.conf
        cat /mnt/target/etc/mdadm.conf
      fi
      echo " "
    fi

    for BRinitrd in `find /mnt/target/boot -name vmlinuz* | sed 's_/mnt/target/boot/vmlinuz-*__'` ; do
      if [ "$BRdistro" = "Arch" ]; then
        chroot /mnt/target mkinitcpio -p $BRinitrd
      elif [ "$BRdistro" = "Debian" ]; then
        chroot /mnt/target update-initramfs -u -k $BRinitrd
      elif [ "$BRdistro" = "Fedora" ]; then
        echo "Building image for $BRinitrd..."
        chroot /mnt/target dracut --force /boot/initramfs-$BRinitrd.img $BRinitrd
      fi
    done
  }

  install_bootloader() {
    if [ -n "$BRgrub" ]; then
      echo -e "\n${BR_SEP}INSTALLING AND UPDATING GRUB2 IN $BRgrub"
      if [[ "$BRgrub" == *md* ]]; then
        for f in `cat /proc/mdstat | grep $(echo "$BRgrub" | cut -c 6-) | grep -oP '[hs]d[a-z]'` ; do
          if [ "$BRdistro" = "Arch" ]; then
            chroot /mnt/target grub-install --target=i386-pc --recheck /dev/$f || touch /tmp/bl_error
          elif [ "$BRdistro" = "Debian" ]; then
            chroot /mnt/target grub-install --recheck /dev/$f || touch /tmp/bl_error
          elif [ "$BRdistro" = "Fedora" ]; then
            chroot /mnt/target grub2-install --recheck /dev/$f || touch /tmp/bl_error
          fi
        done
      elif [ "$BRdistro" = "Arch" ]; then
        chroot /mnt/target grub-install --target=i386-pc --recheck $BRgrub || touch /tmp/bl_error
      elif [ "$BRdistro" = "Debian" ]; then
        chroot /mnt/target grub-install --recheck $BRgrub || touch /tmp/bl_error
      elif [ "$BRdistro" = "Fedora" ]; then
        chroot /mnt/target grub2-install --recheck $BRgrub || touch /tmp/bl_error
      fi

      if [ "$BRdistro" = "Fedora" ]; then
        if [ -f /mnt/target/etc/default/grub ]; then
          mv /mnt/target/etc/default/grub /mnt/target/etc/default/grub-old
        fi
        echo 'GRUB_TIMEOUT=5' > /mnt/target/etc/default/grub
        echo 'GRUB_DEFAULT=saved' >> /mnt/target/etc/default/grub
        echo 'GRUB_CMDLINE_LINUX="vconsole.keymap=us quiet"' >> /mnt/target/etc/default/grub
        echo 'GRUB_DISABLE_RECOVERY="true"' >> /mnt/target/etc/default/grub
        echo -e "\n${BR_SEP}Generated grub2 config" >> /tmp/restore.log
        cat /mnt/target/etc/default/grub >> /tmp/restore.log
        chroot /mnt/target grub2-mkconfig -o /boot/grub2/grub.cfg
      else
        chroot /mnt/target grub-mkconfig -o /boot/grub/grub.cfg
      fi

    elif [ -n "$BRsyslinux" ]; then
      echo -e "\n${BR_SEP}INSTALLING AND CONFIGURING Syslinux IN $BRsyslinux"
      if [ -d /mnt/target/boot/syslinux ]; then
        mv /mnt/target/boot/syslinux/syslinux.cfg /mnt/target/boot/syslinux.cfg-old
        chattr -i /mnt/target/boot/syslinux/* 2> /dev/null
        rm -r /mnt/target/boot/syslinux/* 2> /dev/null
      else
        mkdir -p /mnt/target/boot/syslinux
      fi
      touch /mnt/target/boot/syslinux/syslinux.cfg

      if [ "$BRdistro" = "Arch" ]; then
        chroot /mnt/target syslinux-install_update -i -a -m || touch /tmp/bl_error
      else
        if [[ "$BRsyslinux" == *md* ]]; then
          chroot /mnt/target extlinux --raid -i /boot/syslinux || touch /tmp/bl_error
          for f in `cat /proc/mdstat | grep $(echo "$BRsyslinux" | cut -c 6-) | grep -oP '[hs]d[a-z][0-9]'` ; do
            BRdev=`echo /dev/$f | cut -c -8`
            BRpart=`echo /dev/$f | cut -c 9-`
            detect_partition_table
            set_syslinux_flags_and_paths
            echo "Installing $BRsyslinuxmbr in $BRdev ($BRpartitiontable)"
            dd bs=440 count=1 conv=notrunc if=$BRsyslinuxpath/$BRsyslinuxmbr of=$BRdev &>> /tmp/restore.log || touch /tmp/bl_error
          done
        else
          chroot /mnt/target extlinux -i /boot/syslinux || touch /tmp/bl_error
          if [ -n "$BRboot" ]; then
            BRdev=`echo $BRboot | cut -c -8`
            BRpart=`echo $BRboot | cut -c 9-`
          else
            BRdev=`echo $BRroot | cut -c -8`
            BRpart=`echo $BRroot | cut -c 9-`
          fi
          detect_partition_table
          set_syslinux_flags_and_paths
          echo "Installing $BRsyslinuxmbr in $BRsyslinux ($BRpartitiontable)"
          dd bs=440 count=1 conv=notrunc if=$BRsyslinuxpath/$BRsyslinuxmbr of=$BRsyslinux &>> /tmp/restore.log || touch /tmp/bl_error
        fi
        cp $BRsyslinuxpath/menu.c32 /mnt/target/boot/syslinux/
      fi
      generate_syslinux_cfg
      echo -e "\n${BR_SEP}GENERATED SYSLINUX CONFIG" >> /tmp/restore.log
      cat /mnt/target/boot/syslinux/syslinux.cfg >> /tmp/restore.log
    fi
  }

  set_bootloader() {
    if [ -n "$BRgrub" ]; then
      BRbootloader="Grub"
    elif [ -n "$BRsyslinux" ]; then
      BRbootloader="Syslinux"
    fi

    if [ "$BRmode" = "Restore" ]; then
      if [ -n "$BRgrub" ] && ! grep -Fq "usr/lib/grub/i386-pc" /tmp/filelist 2>/dev/null; then
        if [ -z "$BRnocolor" ]; then
          color_variables
        fi
        echo -e "\n[${BR_RED}ERROR${BR_NORM}] Grub not found in the archived system\n"
        clean_unmount_in
      elif [ -n "$BRsyslinux" ] && ! grep -Fq "bin/extlinux" /tmp/filelist 2>/dev/null; then
        if [ -z "$BRnocolor" ]; then
          color_variables
        fi
        echo -e "\n[${BR_RED}ERROR${BR_NORM}] Syslinux not found in the archived system\n"
        clean_unmount_in
      fi
    fi
  }

  check_archive() {
    echo " "
    if [ -f /tmp/tar_error ]; then
      rm /tmp/tar_error
      rm /mnt/target/fullbackup 2>/dev/null
      if [ "$BRinterface" = "cli" ]; then
        echo -e "[${BR_RED}ERROR${BR_NORM}] Error reading archive"
      elif [ "$BRinterface" = "dialog" ]; then
        dialog --title "Error" --msgbox "Error reading archive." 5 26
      fi
    else
      target_arch=$(grep -F 'target_architecture.' /tmp/filelist)
      if [ -z "$target_arch" ]; then
        target_arch="unknown"
      fi
      if [ ! "$(uname -m)" == "$(echo ${target_arch#*.})" ]; then
        rm /mnt/target/fullbackup 2>/dev/null
        if [ "$BRinterface" = "cli" ]; then
          echo -e "[${BR_RED}ERROR${BR_NORM}] Running and target system architecture mismatch or invalid archive"
          echo -e "[${BR_CYAN}INFO${BR_NORM}] Target  system: ${target_arch#*.}"
          echo -e "[${BR_CYAN}INFO${BR_NORM}] Running system: $(uname -m)"
        elif [ "$BRinterface" = "dialog" ]; then
          dialog --title "Error" --msgbox "Running and target system architecture mismatch or invalid archive.\n\nTarget  system: ${target_arch#*.}\nRunning system: $(uname -m)" 8 71
        fi
      fi
    fi
  }

  generate_locales() {
    if [ "$BRdistro" = "Arch" ] || [ "$BRdistro" = "Debian" ]; then
      echo -e "\n${BR_SEP}GENERATING LOCALES"
      chroot /mnt/target locale-gen
    fi
  }

  rm_work_dir() {
    sleep 1
    rm -r /mnt/target
  }

  clean_files() {
    if [ -f /mnt/target/fullbackup ]; then rm /mnt/target/fullbackup; fi
    if [ -f /tmp/filelist ]; then rm /tmp/filelist; fi
    if [ -f /tmp/bl_error ]; then rm /tmp/bl_error; fi
    if [ -f /tmp/r_error ]; then rm /tmp/r_error; fi
    if [ -f /tmp/bsdtar_out ]; then rm /tmp/bsdtar_out; fi
    if [ -f /mnt/target/target_architecture.$(uname -m) ]; then rm /mnt/target/target_architecture.$(uname -m); fi
   }

  clean_unmount_in() {
    if [ -z "$BRnocolor" ]; then
      color_variables
    fi
    echo "${BR_SEP}CLEANING AND UNMOUNTING"
    cd ~
    if [ "$BRcustom" = "y" ]; then
      while read ln; do
        sleep 1
        echo -ne "${BR_WRK}Unmounting $ln"
        OUTPUT=$(umount $ln 2>&1) && ok_status || error_status
      done < <( for i in ${BRumountparts[@]}; do BRdevice=$(echo $i | cut -f2 -d"="); echo $BRdevice; done | tac )
    fi

    if [ "$BRfsystem" = "btrfs" ] && [ "$BRrootsubvol" = "y" ]; then
      echo -ne "${BR_WRK}Unmounting $BRrootsubvolname"
      OUTPUT=$(umount $BRroot 2>&1) && ok_status || error_status
      sleep 1
      echo -ne "${BR_WRK}Mounting $BRroot"
      OUTPUT=$(mount $BRroot /mnt/target 2>&1) && ok_status || error_status

      if [ "$BRsubvolother" = "y" ]; then
        while read ln; do
          sleep 1
          echo -ne "${BR_WRK}Deleting $BRrootsubvolname$ln"
          OUTPUT=$(btrfs subvolume delete /mnt/target/$BRrootsubvolname$ln 2>&1 1> /dev/null) && ok_status || error_status
        done < <( for i in ${BRsubvols[@]}; do echo $i; done | sort | tac )
      fi

      echo -ne "${BR_WRK}Deleting $BRrootsubvolname"
      OUTPUT=$(btrfs subvolume delete /mnt/target/$BRrootsubvolname 2>&1 1> /dev/null) && ok_status || error_status
    fi

    if [ -z "$BRSTOP" ]; then
      rm -r /mnt/target/* 2>/dev/null
    fi
    clean_files

    echo -ne "${BR_WRK}Unmounting $BRroot"
    sleep 1
    OUTPUT=$(umount $BRroot 2>&1) && (ok_status && rm_work_dir) || (error_status && echo -e "[${BR_YELLOW}WARNING${BR_NORM}] /mnt/target remained")
    exit
  }

  clean_unmount_out() {
    if [ -z "$BRnocolor" ]; then
      color_variables
    fi
    echo -e "\n${BR_SEP}CLEANING AND UNMOUNTING"
    cd ~
    umount /mnt/target/dev/pts
    umount /mnt/target/proc
    umount /mnt/target/dev
    umount /mnt/target/sys
    umount /mnt/target/run

    if [ "$BRcustom" = "y" ]; then
      while read ln; do
        sleep 1
        echo -ne "${BR_WRK}Unmounting $ln"
        OUTPUT=$(umount $ln 2>&1) && ok_status || error_status
      done < <( for i in ${BRsorted[@]}; do BRdevice=$(echo $i | cut -f2 -d"="); echo $BRdevice; done | tac )
    fi

    clean_files

    echo -ne "${BR_WRK}Unmounting $BRroot"
    sleep 1
    OUTPUT=$(umount $BRroot 2>&1) && (ok_status && rm_work_dir) || (error_status && echo -e "[${BR_YELLOW}WARNING${BR_NORM}] /mnt/target remained")
    exit
  }

  unset_vars() {
    if [ "$BRswap" = "-1" ]; then unset BRswap; fi
    if [ "$BRboot" = "-1" ]; then unset BRboot; fi
    if [ "$BRhome" = "-1" ]; then unset BRhome; fi
    if [ "$BRgrub" = "-1" ]; then unset BRgrub; fi
    if [ "$BRsyslinux" = "-1" ]; then unset BRsyslinux; fi
  }

  if [ -z "$BRnocolor" ]; then
    color_variables
  fi

  BR_WRK="[${BR_CYAN}WORKING${BR_NORM}] "
  DEFAULTIFS=$IFS
  IFS=$'\n'

  if [ -n "$BRhome" ]; then
    BRcustom="y"
    BRcustomparts+=(/home="$BRhome")
  fi

  if [ -n "$BRboot" ]; then
    BRcustom="y"
    BRcustomparts+=(/boot="$BRboot")
  fi

  check_input

  if [ -n "$BRroot" ]; then
    if [ -z "$BRrootsubvolname" ]; then
      BRrootsubvol="n"
    fi

    if [ -z "$BRother" ]; then
      BRother="n"
    fi

    if [ -z "$BRmountoptions" ]; then
      BRmountoptions="No"
      BR_MOUNT_OPTS="defaults"
    fi

    if [ -z "$BRswap" ]; then
      BRswap="-1"
    fi

    if [ -z "$BRboot" ]; then
      BRboot="-1"
    fi

    if [ -z "$BRhome" ]; then
      BRhome="-1"
    fi

    if [ -z "$BRgrub" ] && [ -z "$BRsyslinux" ]; then
      BRgrub="-1"
      BRsyslinux="-1"
    fi

    if [ -z "$BRfile" ] && [ -z "$BRurl" ] && [ -z "$BRrestore" ]; then
      echo -e "[${BR_YELLOW}WARNING${BR_NORM}] You must specify a backup file or enable transfer mode"
      exit
    fi
  fi

  if [ -n "$BRrootsubvol" ]; then
    if [ -z "$BRsubvolother" ]; then
      BRsubvolother="n"
    fi
  fi

  if [ "$BRgrub" = "-1" ] && [ "$BRsyslinux" = "-1" ] && [ -n "$BR_KERNEL_OPTS" ]; then
    echo -e "[${BR_YELLOW}WARNING${BR_NORM}] No bootloader selected, skipping kernel options"
  fi

  if [ -n "$BRgrub" ] && [ -z "$BRsyslinux" ] && [ -n "$BR_KERNEL_OPTS" ]; then
    echo -e "[${BR_YELLOW}WARNING${BR_NORM}] Grub selected, skipping kernel options"
  fi

  if [ -z "$(part_list_cli 2>/dev/null)" ]; then
    echo -e "[${BR_RED}ERROR${BR_NORM}] No partitions found"
    exit
  fi

  if [ -d /mnt/target ]; then
    echo -e "[${BR_RED}ERROR${BR_NORM}] /mnt/target exists, aborting"
    exit
  fi

  if [ -f /etc/pacman.conf ]; then
    PATH="$PATH:/usr/sbin:/bin"
  fi

  if [ "$BRinterface" = "cli" ]; then

    if [ -z "$BRrestore" ] && [ -z "$BRfile" ] && [ -z "$BRurl" ]; then
      info_screen
      read -s a
    fi

    disk_list=(`for f in /dev/[hs]d[a-z]; do echo -e "$f"; done; for f in $(find /dev -regex "^/dev/md[0-9]+$"); do echo -e "$f"; done`)
    editorlist=(nano vi)
    update_part_list

    if [ -z "$BRroot" ]; then
      echo -e "\n${BR_CYAN}Select target root partition:${BR_NORM}"
      select c in ${list[@]}; do
        if [ "$REPLY" = "q" ] || [ "$REPLY" = "Q" ]; then
          echo -e "${BR_YELLOW}Aborted by User${BR_NORM}"
          exit
        elif [[ "$REPLY" = [0-9]* ]] && [ "$REPLY" -gt 0 ] && [ "$REPLY" -le ${#list[@]} ]; then
          BRroot=(`echo $c | awk '{ print $1 }'`)
          echo -e "${BR_GREEN}You selected $BRroot as your root partition${BR_NORM}"
          break
        else
          echo -e "${BR_RED}Please select a valid option from the list${BR_NORM}"
        fi
      done
    fi

    while [ -z "$BRmountoptions" ]; do
      echo -e "\n${BR_CYAN}Enter additional mount options?${BR_NORM}"
      read -p "(y/N):" an

      if [ -n "$an" ]; then
        def=$an
      else
        def="n"
      fi

      if [ "$def" = "y" ] || [ "$def" = "Y" ]; then
        BRmountoptions="Yes"
        echo -e "\n${BR_CYAN}Enter options (comma-separated list of mount options)${BR_NORM}"
        read -p "Options: " BR_MOUNT_OPTS
      elif [ "$def" = "n" ] || [ "$def" = "N" ]; then
        BRmountoptions="No"
        BR_MOUNT_OPTS="defaults"
      else
        echo -e "${BR_RED}Please enter a valid option${BR_NORM}"
      fi
    done

    detect_root_fs_size

    if [ -z "$BRfsystem" ]; then
      echo -e "[${BR_RED}ERROR${BR_NORM}] Unknown root file system"
      exit
    fi

    if [ "$BRfsystem" = "btrfs" ]; then
      while [ -z "$BRrootsubvol" ]; do
        echo -e "\n${BR_CYAN}BTRFS root file system detected. Create subvolume for root?${BR_NORM}"
        read -p "(Y/n):" an

        if [ -n "$an" ]; then
          btrfsdef=$an
        else
          btrfsdef="y"
        fi

        if [ "$btrfsdef" = "y" ] || [ "$btrfsdef" = "Y" ]; then
          BRrootsubvol="y"
        elif [ "$btrfsdef" = "n" ] || [ "$btrfsdef" = "N" ]; then
          BRrootsubvol="n"
        else
          echo -e "${BR_RED}Please select a valid option${BR_NORM}"
        fi
      done

      if [ "$BRrootsubvol" = "y" ]; then
        while [ -z "$BRrootsubvolname" ]; do
          read -p "Enter subvolume name: " BRrootsubvolname
          echo "Subvolume name: $BRrootsubvolname"
          if [ -z "$BRrootsubvolname" ]; then
            echo -e "\n${BR_CYAN}Please enter a name for the subvolume.${BR_NORM}"
          fi
        done

        while [ -z "$BRsubvolother" ]; do
          echo -e "\n${BR_CYAN}Create other subvolumes?${BR_NORM}"
          read -p "(y/N):" an

         if [ -n "$an" ]; then
           def=$an
         else
           def="n"
         fi

         if [ "$def" = "y" ] || [ "$def" = "Y" ]; then
           BRsubvolother="y"
           IFS=$DEFAULTIFS
           echo -e "\n${BR_CYAN}Set subvolumes (subvolume path e.g /home /var /usr ...)${BR_NORM}"
           read -p "Subvolumes: " BRsubvolslist
           BRsubvols+=($BRsubvolslist)
           IFS=$'\n'

           for item in "${BRsubvols[@]}"; do
             if [[ "$item" == *"/home"* ]]; then
               BRhome="-1"
             fi
             if [[ "$item" == *"/boot"* ]]; then
               BRboot="-1"
             fi
           done
         elif [ "$def" = "n" ] || [ "$def" = "N" ]; then
           BRsubvolother="n"
         else
           echo -e "${BR_RED}Please enter a valid option${BR_NORM}"
         fi
       done
     fi
    elif [ "$BRrootsubvol" = "y" ] || [ "$BRsubvolother" = "y" ]; then
      echo -e "[${BR_YELLOW}WARNING${BR_NORM}] Not a btrfs root filesystem, proceeding without subvolumes..."
    fi

    update_part_list

    if [ -z "$BRhome" ] && [ -n "$(part_list_cli)" ]; then
      echo -e "\n${BR_CYAN}Select target home partition: \n${BR_MAGENTA}(Optional - Enter C to skip)${BR_NORM}"
      select c in ${list[@]}; do
        if [ "$REPLY" = "q" ] || [ "$REPLY" = "Q" ]; then
          echo -e "${BR_YELLOW}Aborted by User${BR_NORM}"
          exit
        elif [[ "$REPLY" = [0-9]* ]] && [ "$REPLY" -gt 0 ] && [ "$REPLY" -le ${#list[@]} ]; then
          BRhome=(`echo $c | awk '{ print $1 }'`)
          BRcustom="y"
          BRcustomparts+=(/home="$BRhome")
          echo -e "${BR_GREEN}You selected $BRhome as your home partition${BR_NORM}"
          break
        elif [ "$REPLY" = "c" ] || [ "$REPLY" = "C" ]; then
          echo -e "${BR_GREEN}No home partition${BR_NORM}"
          break
        else
          echo -e "${BR_RED}Please select a valid option from the list${BR_NORM}"
        fi
      done
    fi

    update_part_list

    if [ -z "$BRboot" ] && [ -n "$(part_list_cli)" ]; then
      echo -e "\n${BR_CYAN}Select target boot partition: \n${BR_MAGENTA}(Optional - Enter C to skip)${BR_NORM}"
      select c in ${list[@]}; do
        if [ "$REPLY" = "q" ] || [ "$REPLY" = "Q" ]; then
          echo -e "${BR_YELLOW}Aborted by User${BR_NORM}"
          exit
        elif [[ "$REPLY" = [0-9]* ]] && [ "$REPLY" -gt 0 ] && [ "$REPLY" -le ${#list[@]} ]; then
          BRboot=(`echo $c | awk '{ print $1 }'`)
          BRcustom="y"
          BRcustomparts+=(/boot="$BRboot")
          echo -e "${BR_GREEN}You selected $BRboot as your boot partition${BR_NORM}"
          break
        elif [ "$REPLY" = "c" ] || [ "$REPLY" = "C" ]; then
          echo -e "${BR_GREEN}No boot partition${BR_NORM}"
          break
        else
          echo -e "${BR_RED}Please select a valid option from the list${BR_NORM}"
        fi
      done
    fi

    update_part_list

    if [ -z "$BRswap" ] && [ -n "$(part_list_cli)" ]; then
      echo -e "\n${BR_CYAN}Select swap partition: \n${BR_MAGENTA}(Optional - Enter C to skip)${BR_NORM}"
      select c in ${list[@]}; do
        if [ "$REPLY" = "q" ] || [ "$REPLY" = "Q" ]; then
          echo -e "${BR_YELLOW}Aborted by User${BR_NORM}"
          exit
        elif [[ "$REPLY" = [0-9]* ]] && [ "$REPLY" -gt 0 ] && [ "$REPLY" -le ${#list[@]} ]; then
          BRswap=(`echo $c | awk '{ print $1 }'`)
          echo -e "${BR_GREEN}You selected $BRswap as your swap partition${BR_NORM}"
          break
        elif [ "$REPLY" = "c" ] || [ "$REPLY" = "C" ]; then
          echo -e "${BR_GREEN}No swap partition${BR_NORM}"
          break
        else
          echo -e "${BR_RED}Please select a valid option from the list${BR_NORM}"
        fi
      done
    fi

    if [ -n "$(part_list_cli)" ]; then
      while [ -z "$BRother" ]; do
        echo -e "\n${BR_CYAN}Specify custom partitions?${BR_NORM}"
        read -p "(y/N):" an

        if [ -n "$an" ]; then
          def=$an
        else
          def="n"
        fi

        if [ "$def" = "y" ] || [ "$def" = "Y" ]; then
          BRcustom="y"
          BRother="y"
          IFS=$DEFAULTIFS
          echo -e "\n${BR_CYAN}Set partitions (mountpoint=device e.g /usr=/dev/sda3 /var/cache=/dev/sda4)${BR_NORM}"
          read -p "Partitions: " BRcustompartslist
          BRcustomparts+=($BRcustompartslist)
          IFS=$'\n'
        elif [ "$def" = "n" ] || [ "$def" = "N" ]; then
          BRother="n"
        else
          echo -e "${BR_RED}Please enter a valid option${BR_NORM}"
        fi
      done
    fi

    if [ -z "$BRgrub" ] && [ -z "$BRsyslinux" ]; then
      echo -e "\n${BR_CYAN}Select bootloader: \n${BR_MAGENTA}(Optional - Enter C to skip)${BR_NORM}"
      select c in Grub Syslinux; do
        if [ "$REPLY" = "q" ] || [ "$REPLY" = "Q" ]; then
          echo -e "${BR_YELLOW}Aborted by User${BR_NORM}"
          exit
        elif [ "$REPLY" = "c" ] || [ "$REPLY" = "C" ]; then
          echo -e "\n[${BR_YELLOW}WARNING${BR_NORM}] NO BOOTLOADER SELECTED"
          break
        elif [[ "$REPLY" = [0-9]* ]] && [ "$REPLY" -eq 1 ]; then
          echo -e "\n${BR_CYAN}Select target disk for Grub:${BR_NORM}"
          select c in ${disk_list[@]}; do
	    if [ "$REPLY" = "q" ] || [ "$REPLY" = "Q" ]; then
              echo -e "${BR_YELLOW}Aborted by User${BR_NORM}"
	      exit
	    elif [[ "$REPLY" = [0-9]* ]] && [ "$REPLY" -gt 0 ] && [ "$REPLY" -le ${#disk_list[@]} ]; then
	      BRgrub=(`echo $c | awk '{ print $1 }'`)
              echo -e "${BR_GREEN}You selected $BRgrub to install Grub${BR_NORM}"
	      break
	    else
              echo -e "${BR_RED}Please select a valid option from the list${BR_NORM}"
	    fi
    	  done
          break
        elif [[ "$REPLY" = [0-9]* ]] && [ "$REPLY" -eq 2 ]; then
          echo -e "\n${BR_CYAN}Select target disk Syslinux:${BR_NORM}"
 	  select c in ${disk_list[@]}; do
	    if [ "$REPLY" = "q" ] || [ "$REPLY" = "Q" ]; then
              echo -e "${BR_YELLOW}Aborted by User${BR_NORM}"
	      exit
	    elif [[ "$REPLY" = [0-9]* ]] && [ "$REPLY" -gt 0 ] && [ "$REPLY" -le ${#disk_list[@]} ]; then
	      BRsyslinux=(`echo $c | awk '{ print $1 }'`)
              echo -e "${BR_GREEN}You selected $BRsyslinux to install Syslinux${BR_NORM}"
	      echo -e "\n${BR_CYAN}Enter additional kernel options?${BR_NORM}"
              read -p "(y/N):" an

              if [ -n "$an" ]; then
                def=$an
              else
                def="n"
              fi

              if [ "$def" = "y" ] || [ "$def" = "Y" ]; then
                read -p "Enter options:" BR_KERNEL_OPTS
                break
              elif [ "$def" = "n" ] || [ "$def" = "N" ]; then
                break
              else
                echo -e "${BR_RED}Please enter a valid option${BR_NORM}"
              fi
	    else
              echo -e "${BR_RED}Please select a valid option from${BR_NORM}"
	    fi
	  done
          break
        else
          echo -e "${BR_RED}Please select a valid option from the list${BR_NORM}"
        fi
      done
    fi

    unset_vars

    if [ "$BRmode" = "Restore" ]; then
      if [ -z "$BRarchiver" ]; then
        echo -e "\n${BR_CYAN}Select the archiver you used to create the backup archive:${BR_NORM}"
        select c in "tar (GNU Tar)" "bsdtar (Libarchive Tar)"; do
          if [ "$REPLY" = "q" ] || [ "$REPLY" = "Q" ]; then
            echo -e "${BR_YELLOW}Aborted by User${BR_NORM}"
            exit
          elif [[ "$REPLY" = [0-9]* ]] && [ "$REPLY" -eq 1 ]; then
            BRarchiver="tar"
            echo -e "${BR_GREEN}You selected $BRarchiver${BR_NORM}"
            break
          elif [[ "$REPLY" = [0-9]* ]] && [ "$REPLY" -eq 2 ]; then
            BRarchiver="bsdtar"
            echo -e "${BR_GREEN}You selected $BRarchiver${BR_NORM}"
            break
          else
            echo -e "${BR_RED}Please enter a valid option from the list${BR_NORM}"
          fi
        done
      fi
    fi

    if [ "$BRmode" = "Transfer" ]; then
      while [ -z "$BRhidden" ]; do
        echo -e "\n${BR_CYAN}Transfer entire /home directory?\n(If no, only hidden files and folders will be transferred)${BR_NORM}"
        read -p "(Y/n):" an

        if [ -n "$an" ]; then
          def=$an
        else
          def="y"
        fi

        if [ "$def" = "y" ] || [ "$def" = "Y" ]; then
          BRhidden="n"
        elif [ "$def" = "n" ] || [ "$def" = "N" ]; then
          BRhidden="y"
        else
          echo -e "${BR_RED}Please select a valid option${BR_NORM}"
        fi
      done
    fi

    check_input
    mount_all

    if [ "$BRmode" = "Restore" ]; then
      echo -e "\n${BR_SEP}GETTING TAR IMAGE"
      if [ -n "$BRfile" ]; then
        echo -ne "${BR_WRK}Symlinking file"
        OUTPUT=$(ln -s "$BRfile" "/mnt/target/fullbackup" 2>&1) && ok_status || error_status
      fi

      if [ -n "$BRurl" ]; then
        if [ -n "$BRusername" ]; then
          wget --user=$BRusername --password=$BRpassword -O /mnt/target/fullbackup $BRurl --tries=2
          if [ "$?" -ne "0" ]; then
            echo -e "\n[${BR_RED}ERROR${BR_NORM}] Error downloading file. Wrong URL or network is down"
            rm /mnt/target/fullbackup 2>/dev/null
          else
            detect_filetype_url
            if [ "$BRfiletype" = "wrong" ]; then
              echo -e "${BR_RED}Invalid file type${BR_NORM}"
              rm /mnt/target/fullbackup 2>/dev/null
            fi
          fi
        else
          wget -O /mnt/target/fullbackup $BRurl --tries=2
          if [ "$?" -ne "0" ]; then
            echo -e "\n[${BR_RED}ERROR${BR_NORM}] Error downloading file. Wrong URL or network is down"
            rm /mnt/target/fullbackup 2>/dev/null
          else
            detect_filetype_url
            if [ "$BRfiletype" = "wrong" ]; then
              echo -e "[${BR_RED}ERROR${BR_NORM}] Invalid file type"
              rm /mnt/target/fullbackup 2>/dev/null
            fi
          fi
        fi
      fi
      if [ -f /mnt/target/fullbackup ]; then
        ($BRarchiver tf /mnt/target/fullbackup || touch /tmp/tar_error) | tee /tmp/filelist |
        while read ln; do a=$(( a + 1 )) && echo -en "\rReading archive: $a Files "; done
        check_archive
      fi

      while [ ! -f /mnt/target/fullbackup ]; do
        echo -e "\n${BR_CYAN}Select backup file. Choose an option:${BR_NORM}"
        select c in "Local File" "URL" "Protected URL"; do
          if [ "$REPLY" = "q" ] || [ "$REPLY" = "Q" ]; then
            echo -e "${BR_YELLOW}Aborted by User${BR_NORM}"
            clean_unmount_in
          elif [ "$REPLY" = "1" ]; then
            unset BRurl
            echo -e "\n${BR_CYAN}Enter the path of the backup file${BR_NORM}"
            IFS=$DEFAULTIFS
            read -e -p "Path:" BRfile
            IFS=$'\n'
            if [ ! -f "$BRfile" ] || [ -z "$BRfile" ]; then
              echo -e "[${BR_RED}ERROR${BR_NORM}] File not found"
      	    else
              detect_filetype
              if [ "$BRfiletype" = "gz" ] || [ "$BRfiletype" = "xz" ]; then
                echo -ne "${BR_WRK}Symlinking file"
                OUTPUT=$(ln -s $BRfile "/mnt/target/fullbackup" 2>&1) && ok_status || error_status
              else
                echo -e "[${BR_RED}ERROR${BR_NORM}] Invalid file type"
              fi
	    fi
            break

          elif [ "$REPLY" = "2" ] || [ "$REPLY" = "3" ]; then
            unset BRfile
            echo -e "\n${BR_CYAN}Enter the URL for the backup file${BR_NORM}"
            read -p "URL:" BRurl
            echo " "
            if [ "$REPLY" = "3" ]; then
	      read -p "USERNAME: " BRusername
              read -p "PASSWORD: " BRpassword
	      wget --user=$BRusername --password=$BRpassword -O /mnt/target/fullbackup $BRurl --tries=2
              if [ "$?" -ne "0" ]; then
                echo -e "\n[${BR_RED}ERROR${BR_NORM}] Error downloading file. Wrong URL or network is down"
	        rm /mnt/target/fullbackup 2>/dev/null
              else
                detect_filetype_url
                if [ "$BRfiletype" = "wrong" ]; then
                  echo -e "${BR_RED}Invalid file type${BR_NORM}"
                  rm /mnt/target/fullbackup 2>/dev/null
                fi
              fi
	      break
            fi
            wget -O /mnt/target/fullbackup $BRurl --tries=2
            if [ "$?" -ne "0" ]; then
              echo -e "\n[${BR_RED}ERROR${BR_NORM}] Error downloading file. Wrong URL or network is down"
	      rm /mnt/target/fullbackup 2>/dev/null
            else
              detect_filetype_url
              if [ "$BRfiletype" = "wrong" ]; then
                echo -e "[${BR_RED}ERROR${BR_NORM}] Invalid file type"
                rm /mnt/target/fullbackup 2>/dev/null
              fi
            fi
            break
          else
            echo -e "${BR_RED}Please select a valid option from the list${BR_NORM}"
          fi
        done
        if [ -f /mnt/target/fullbackup ]; then
          ($BRarchiver tf /mnt/target/fullbackup || touch /tmp/tar_error) | tee /tmp/filelist |
          while read ln; do a=$(( a + 1 )) && echo -en "\rReading archive: $a Files "; done
          check_archive
        fi
      done
    fi

    detect_distro
    set_bootloader
    echo -e "\n${BR_SEP}SUMMARY"
    show_summary

    while [ -z "$BRcontinue" ]; do
      echo -e "\n${BR_CYAN}Continue?${BR_NORM}"
      read -p "(Y/n):" an

      if [ -n "$an" ]; then
        def=$an
      else
        def="y"
      fi

      if [ "$def" = "y" ] || [ "$def" = "Y" ]; then
        BRcontinue="y"
      elif [ "$def" = "n" ] || [ "$def" = "N" ]; then
        echo -e "${BR_YELLOW}Aborted by User${BR_NORM}"
        BRcontinue="n"
        clean_unmount_in
      else
        echo -e "${BR_RED}Please enter a valid option${BR_NORM}"
      fi
    done

    echo "--------------$(date +%d-%m-%Y-%T)--------------" >> /tmp/restore.log
    echo " " >> /tmp/restore.log
    if [ "$BRmode" = "Restore" ]; then
      echo -e "\n${BR_SEP}EXTRACTING"
      total=$(cat /tmp/filelist | wc -l)
      sleep 1

      if [ "$BRarchiver" = "tar" ]; then
        run_tar 2>>/tmp/restore.log
      elif [ "$BRarchiver" = "bsdtar" ]; then
        run_tar | tee /tmp/bsdtar_out
      fi | while read ln; do a=$(( a + 1 )) && echo -en "\rDecompressing: $(($a*100/$total))%"; done

      if [ "$BRarchiver" = "bsdtar" ] && [ -f /tmp/r_error ]; then
        cat /tmp/bsdtar_out >> /tmp/restore.log
      fi

      echo " "
    elif [ "$BRmode" = "Transfer" ]; then
      echo -e "\n${BR_SEP}TRANSFERING"
      run_calc | while read ln; do a=$(( a + 1 )) && echo -en "\rCalculating: $a Files"; done
      total=$(cat /tmp/filelist | wc -l)
      sleep 1
      echo " "
      run_rsync 2>>/tmp/restore.log | while read ln; do b=$(( b + 1 )) && echo -en "\rSyncing: $(($b*100/$total))%"; done
      echo " "
    fi

    echo -e "\n${BR_SEP}GENERATING FSTAB"
    generate_fstab
    cat /mnt/target/etc/fstab

    while [ -z "$BRedit" ] ; do
      echo -e "\n${BR_CYAN}Edit fstab?${BR_NORM}"
      read -p "(y/N):" an

      if [ -n "$an" ]; then
        def=$an
      else
        def="n"
      fi

      if [ "$def" = "y" ] || [ "$def" = "Y" ]; then
        BRedit="y"
      elif [ "$def" = "n" ] || [ "$def" = "N" ]; then
        BRedit="n"
      else
        echo -e "${BR_RED}Please select a valid option${BR_NORM}"
      fi
    done

    if [ "$BRedit" = "y" ]; then
      if [ -z "$BReditor" ]; then
        echo -e "\n${BR_CYAN}Select editor${BR_NORM}"
        select c in ${editorlist[@]}; do
          if [[ "$REPLY" = [0-9]* ]] && [ "$REPLY" -gt 0 ] && [ "$REPLY" -le ${#editorlist[@]} ]; then
            BReditor=$c
            $BReditor /mnt/target/etc/fstab
            break
          else
            echo -e "${BR_RED}Please select a valid option${BR_NORM}"
          fi
        done
      fi
    fi

    (prepare_chroot
     build_initramfs
     generate_locales
     install_bootloader
     sleep 1) 1> >(tee -a /tmp/restore.log) 2>&1

    if [ -z "$BRquiet" ]; then
      exit_screen; read -s a
    else
      exit_screen_quiet
    fi
    sleep 1
    clean_unmount_out

  elif [ "$BRinterface" = "dialog" ]; then
    IFS=$DEFAULTIFS
    unset BR_NORM BR_RED BR_GREEN BR_YELLOW BR_BLUE BR_MAGENTA BR_CYAN BR_BOLD

    if [ -z "$BRrestore" ] && [ -z "$BRfile" ] && [ -z "$BRurl" ]; then
      dialog --yes-label "Continue" --no-label "View Partition Table" --title "$BR_VERSION" --yesno "$(info_screen)" 0 0
      if [ "$?" = "1" ]; then
        dialog --title "Partition Table" --msgbox "$(disk_report)" 0 0
      fi
    fi

    exec 3>&1

    update_options() {
      options=("Root partition" "$BRroot" \
      "(Optional) Home partition" "$BRhome" \
      "(Optional) Boot partition" "$BRboot" \
      "(Optional) Swap partition" "$BRswap" \
      "(Optional) Custom partitions" "$BRempty" \
      "Done with partitions" "$BRempty")
    }

    update_options

    while [ -z "$BRroot" ]; do
      BRassign="y"
      while opt=$(dialog --ok-label Select --cancel-label Quit --menu "Set target partitions:" 0 0 0 "${options[@]}"  2>&1 1>&3); if [ $? = "1" ]; then exit; fi; do
        case "$opt" in
          "${options[0]}" )
              BRroot=$(dialog --column-separator "|" --cancel-label Unset --menu "Set target root partition:" 0 0 0 `part_list_dialog` 2>&1 1>&3)
              update_options;;
          "${options[2]}" )
              BRhome=$(dialog --column-separator "|" --cancel-label Unset --menu "Set target home partition:" 0 0 0 `part_list_dialog` 2>&1 1>&3)
              update_options;;
          "${options[4]}" )
              BRboot=$(dialog --column-separator "|" --cancel-label Unset --menu "Set target boot partition:" 0 0 0 `part_list_dialog` 2>&1 1>&3)
              update_options;; 
          "${options[6]}" )
              BRswap=$(dialog --column-separator "|" --cancel-label Unset --menu "Set swap partition:" 0 0 0 `part_list_dialog` 2>&1 1>&3)
              update_options;;   
          "${options[8]}" )
              BRcustompartslist=$(dialog --no-cancel --inputbox "Set partitions: (mountpoint=device e.g /usr=/dev/sda3 /var/cache=/dev/sda4)" 8 80 "$BRcustomold" 2>&1 1>&3)
              BRcustomold="$BRcustompartslist"
              update_options;;
          "${options[10]}" )
              break;;
        esac
      done

      if [ -z "$BRroot" ]; then
        dialog --title "Error" --msgbox "You must specify a target root partition." 5 45
      fi
    done

    if [ -n "$BRassign" ]; then
      if [ -n "$BRhome" ]; then
        BRcustom="y"
        BRcustomparts+=(/home="$BRhome")
      fi

      if [ -n "$BRboot" ]; then
        BRcustom="y"
        BRcustomparts+=(/boot="$BRboot")
      fi

      if [ -n "$BRcustompartslist" ]; then
        BRcustom="y"
        BRother="y"
        BRcustomparts+=($BRcustompartslist)
      fi
    fi

    if [ -z "$BRmountoptions" ]; then
       dialog --yesno "Specify additional mount options for root partition?" 5 56
       if [ "$?" = "0" ]; then
         BRmountoptions="Yes"
         BR_MOUNT_OPTS=$(dialog --no-cancel --inputbox "Enter options: (comma-separated list of mount options)" 8 70 2>&1 1>&3)
       else
         BRmountoptions="No"
         BR_MOUNT_OPTS="defaults"
       fi
     fi

    detect_root_fs_size

    if [ -z "$BRfsystem" ]; then
      if [ -z "$BRnocolor" ]; then
        color_variables
      fi
      echo -e "[${BR_RED}ERROR${BR_NORM}] Unknown root file system"
      exit
    fi

    if [ "$BRfsystem" = "btrfs" ]; then
      if [ -z "$BRrootsubvol" ]; then
        dialog --yesno "BTRFS root file system detected. Create subvolume for root?" 5 68
        if [ "$?" = "0" ]; then
          BRrootsubvol="y"
        else
          BRrootsubvol="n"
        fi
      fi

      if [ "$BRrootsubvol" = "y" ]; then
        while [ -z "$BRrootsubvolname" ]; do
          BRrootsubvolname=$(dialog --no-cancel --inputbox "Enter subvolume name:" 8 50 2>&1 1>&3)
          if [ -z "$BRrootsubvolname" ]; then
            dialog --title "Warning" --msgbox "Please enter a name for the subvolume." 5 42
          fi
        done

        if [ -z "$BRsubvolother" ]; then
          dialog --yesno "Create other subvolumes?" 5 30
          if [ "$?" = "0" ]; then
            BRsubvolother="y"
            BRsubvolslist=$(dialog --no-cancel --inputbox "Set subvolumes (subvolume path e.g /home /var /usr ...)" 8 80 2>&1 1>&3)
            BRsubvols+=($BRsubvolslist)
            for item in "${BRsubvols[@]}"; do
              if [[ "$item" == *"/home"* ]]; then
                BRhome="-1"
              fi
              if [[ "$item" == *"/boot"* ]]; then
                BRboot="-1"
              fi
            done
          fi
        fi
      fi
    elif [ "$BRrootsubvol" = "y" ] || [ "$BRsubvolother" = "y" ]; then
      dialog  --title "Warning" --msgbox "Not a btrfs root filesystem, press ok to proceed without subvolumes." 5 72
    fi

    if [ -z "$BRgrub" ] && [ -z "$BRsyslinux" ]; then
      REPLY=$(dialog --cancel-label Skip --extra-button --extra-label Quit --menu "Select bootloader:" 10 0 10 1 Grub 2 Syslinux 2>&1 1>&3)
      if [ "$?" = "3" ]; then exit; fi

      if [ "$REPLY" = "1" ]; then
        BRgrub=$(dialog --cancel-label Quit --menu "Set target disk for Grub:" 0 0 0 `disk_list_dialog` 2>&1 1>&3)
        if [ "$?" = "1" ]; then exit; fi
      elif [ "$REPLY" = "2" ]; then
        BRsyslinux=$(dialog --cancel-label Quit --menu "Set target disk for Syslinux:" 0 35 0 `disk_list_dialog` 2>&1 1>&3)
        if [ "$?" = "1" ]; then
          exit
        else
          dialog --yesno "Specify additional kernel options?" 6 40
          if [ "$?" = "0" ]; then
            BR_KERNEL_OPTS=$(dialog --no-cancel --inputbox "Enter additional kernel options:" 8 70 2>&1 1>&3)
          fi
        fi
      fi
    fi

    if [ -z "$BRgrub" ] && [ -z "$BRsyslinux" ]; then
      dialog  --title "Warning" --msgbox "No bootloader selected, press ok to continue." 5 49
    fi

    unset_vars

    if [ -z "$BRmode" ]; then
      BRmode=$(dialog --cancel-label Quit --menu "Select Mode:" 12 50 12 Restore "system from backup file" Transfer "this system with rsync" 2>&1 1>&3)
      if [ "$?" = "1" ]; then exit; fi
    fi

    if [ "$BRmode" = "Restore" ]; then
      if [ -z "$BRarchiver" ]; then
        BRarchiver=$(dialog --no-cancel --menu "Select the archiver you used to create the backup archive:" 12 45 12 tar "GNU Tar" bsdtar "Libarchive Tar" 2>&1 1>&3)
      fi
    fi

    if [ "$BRmode" = "Transfer" ]; then
      if [ -z "$BRhidden" ]; then
        dialog --yesno "Transfer entire /home directory?\n\nIf No, only hidden files and folders will be transferred" 9 50
        if [ "$?" = "0" ]; then
          BRhidden="n"
        else
          BRhidden="y"
        fi
      fi
    fi

    IFS=$'\n'
    if [ -z "$BRnocolor" ]; then
      color_variables
    fi

    check_input
    mount_all
    unset BR_NORM BR_RED BR_GREEN BR_YELLOW BR_BLUE BR_MAGENTA BR_CYAN BR_BOLD

    if [ "$BRmode" = "Restore" ]; then
      if [ -n "$BRfile" ]; then
        ln -s "${BRfile[@]}" "/mnt/target/fullbackup" 2> /dev/null || dialog --title "Error" --msgbox "Error symlinking file." 5 26
      fi

      if [ -n "$BRurl" ]; then
        BRurlold="$BRurl"
        if [ -n "$BRusername" ]; then
         (wget --user=$BRusername --password=$BRpassword -O /mnt/target/fullbackup $BRurl --tries=2 || touch /tmp/wget_error) 2>&1 |
          sed -nru '/[0-9]%/ s/.* ([0-9]+)%.*/\1/p' | count_gauge_wget | dialog --gauge "Downloading..." 0 50

          if [ -f /tmp/wget_error ]; then
            rm /tmp/wget_error
            dialog --title "Error" --msgbox "Error downloading file. Wrong URL or network is down." 5 57
            rm /mnt/target/fullbackup 2>/dev/null
          else
            detect_filetype_url
            if [ "$BRfiletype" = "wrong" ]; then
              dialog --title "Error" --msgbox "Invalid file type." 5 22
              rm /mnt/target/fullbackup 2>/dev/null
            fi
          fi
        else
         (wget -O /mnt/target/fullbackup $BRurl --tries=2 || touch /tmp/wget_error) 2>&1 |
          sed -nru '/[0-9]%/ s/.* ([0-9]+)%.*/\1/p' | count_gauge_wget | dialog --gauge "Downloading..." 0 50

          if [ -f /tmp/wget_error ]; then
            rm /tmp/wget_error
            dialog --title "Error" --msgbox "Error downloading file. Wrong URL or network is down." 5 57
            rm /mnt/target/fullbackup 2>/dev/null
          else
            detect_filetype_url
            if [ "$BRfiletype" = "wrong" ]; then
              dialog --title "Error" --msgbox "Invalid file type." 5 22
              rm /mnt/target/fullbackup 2>/dev/null
            fi
          fi
        fi
      fi
      if [ -f /mnt/target/fullbackup ]; then
        ($BRarchiver tf /mnt/target/fullbackup 2>&1 || touch /tmp/tar_error) | tee /tmp/filelist |
        while read ln; do a=$(( a + 1 )) && echo -en "\rReading archive: $a Files "; done | dialog --progressbox 3 40
        sleep 1
        check_archive
      fi

      while [ ! -f /mnt/target/fullbackup ]; do
        REPLY=$(dialog --cancel-label Quit --menu "Select backup file. Choose an option:" 13 50 13 File "local file" URL "remote file" "Protected URL" "protected remote file" 2>&1 1>&3)
        if [ "$?" = "1" ]; then
          clean_unmount_in

        elif [ "$REPLY" = "File" ]; then
          unset BRurl BRfile BRselect
          BRpath=/
          IFS=$DEFAULTIFS
          while [ -z "$BRfile" ]; do
            show_path
            BRselect=$(dialog --title "$BRcurrentpath" --menu "Select backup archive:" 30 90 30 "<--UP" .. $(file_list) 2>&1 1>&3)
            if [ "$?" = "1" ]; then
              break
            fi
            BRselect="/$BRselect"
            if [ -f "$BRpath${BRselect//\\/ }" ]; then
              BRfile="$BRpath${BRselect//\\/ }"
              BRfile="${BRfile#*/}"
              detect_filetype
              if [ "$BRfiletype" = "gz" ] || [ "$BRfiletype" = "xz" ]; then
                ln -s "$BRfile" "/mnt/target/fullbackup" 2> /dev/null || touch /tmp/ln_error
                if [ -f /tmp/ln_error ]; then
                  rm /tmp/ln_error
                  unset BRfile BRselect
                  dialog --title "Error" --msgbox "Error symlinking file." 5 26
                fi
              else
                dialog --title "Error" --msgbox "Invalid file type." 5 22
                unset BRfile BRselect
              fi
            fi
            if [ "$BRselect" = "/<--UP" ]; then
              BRpath=$(dirname "$BRpath")
            else
              BRpath="$BRpath$BRselect"
              BRpath="${BRpath//\\/ }"
            fi
          done

        elif [ "$REPLY" = "URL" ] || [ "$REPLY" = "Protected URL" ]; then
          unset BRfile
          BRurl=$(dialog --no-cancel --inputbox "Enter the URL for the backup file:" 8 50 "$BRurlold" 2>&1 1>&3)
          BRurlold="$BRurl"
          if [ "$REPLY" = "Protected URL" ]; then
            BRusername=$(dialog --no-cancel --inputbox "Username:" 8 50 2>&1 1>&3)
            BRpassword=$(dialog --no-cancel --insecure --passwordbox "Password:" 8 50 2>&1 1>&3)
           (wget --user=$BRusername --password=$BRpassword -O /mnt/target/fullbackup $BRurl --tries=2 || touch /tmp/wget_error) 2>&1 |
            sed -nru '/[0-9]%/ s/.* ([0-9]+)%.*/\1/p' | count_gauge_wget | dialog --gauge "Downloading..." 0 50

            if [ -f /tmp/wget_error ]; then
              rm /tmp/wget_error
              dialog --title "Error" --msgbox "Error downloading file. Wrong URL or network is down." 5 57
              rm /mnt/target/fullbackup 2>/dev/null
            else
              detect_filetype_url
              if [ "$BRfiletype" = "wrong" ]; then
                dialog --title "Error" --msgbox "Invalid file type." 5 22
                rm /mnt/target/fullbackup 2>/dev/null
              fi
            fi

          elif [ "$REPLY" = "URL" ]; then
           (wget -O /mnt/target/fullbackup $BRurl --tries=2 || touch /tmp/wget_error) 2>&1 |
            sed -nru '/[0-9]%/ s/.* ([0-9]+)%.*/\1/p' | count_gauge_wget | dialog --gauge "Downloading..." 0 50

            if [ -f /tmp/wget_error ]; then
              rm /tmp/wget_error
              dialog --title "Error" --msgbox "Error downloading file. Wrong URL or network is down." 5 57
              rm /mnt/target/fullbackup 2>/dev/null
            else
              detect_filetype_url
              if [ "$BRfiletype" = "wrong" ]; then
                dialog --title "Error" --msgbox "Invalid file type." 5 22
                rm /mnt/target/fullbackup 2>/dev/null
              fi
            fi
          fi
        fi
        if [ -f /mnt/target/fullbackup ]; then
          ($BRarchiver tf /mnt/target/fullbackup 2>&1 || touch /tmp/tar_error) | tee /tmp/filelist |
          while read ln; do a=$(( a + 1 )) && echo -en "\rReading archive: $a Files "; done | dialog --progressbox 3 40
          sleep 1
          check_archive
        fi
      done
    fi

    detect_distro
    set_bootloader

    if [ -z "$BRcontinue" ]; then
      dialog --title "Summary" --yes-label "OK" --no-label "Quit" --yesno "$(show_summary) $(echo -e "\n\nPress OK to continue, or Quit to abort.")" 0 0
      if [ "$?" = "1" ]; then
        clean_unmount_in
      fi
    fi

    echo "--------------$(date +%d-%m-%Y-%T)--------------" >> /tmp/restore.log
    echo " " >> /tmp/restore.log
    if [ "$BRmode" = "Restore" ]; then
      total=$(cat /tmp/filelist | wc -l)
      sleep 1

      if [ "$BRarchiver" = "tar" ]; then
        run_tar 2>>/tmp/restore.log
      elif [ "$BRarchiver" = "bsdtar" ]; then
        run_tar | tee /tmp/bsdtar_out
      fi | count_gauge | dialog --gauge "Decompressing..." 0 50

      if [ "$BRarchiver" = "bsdtar" ] && [ -f /tmp/r_error ]; then
        cat /tmp/bsdtar_out >> /tmp/restore.log
      fi

    elif [ "$BRmode" = "Transfer" ]; then
      run_calc | while read ln; do a=$(( a + 1 )) && echo -en "\rCalculating: $a Files"; done | dialog --progressbox 3 40
      total=$(cat /tmp/filelist | wc -l)
      sleep 1
      run_rsync 2>>/tmp/restore.log | count_gauge | dialog --gauge "Syncing..." 0 50
    fi

    generate_fstab

    if [ -n "$BRedit" ]; then
      cat /mnt/target/etc/fstab | dialog --title "GENERATING FSTAB" --progressbox 20 100
      sleep 2
    else
      dialog --title "GENERATING FSTAB" --yesno "$(echo -e "Edit fstab? Generated fstab:\n\n`cat /mnt/target/etc/fstab`")" 13 100
      if [ "$?" = "0" ]; then
        if [ -z "$BRdeditor" ]; then
          REPLY=$(dialog --no-cancel --menu "Select editor:" 10 25 10 1 nano 2 vi 2>&1 1>&3)
          if [ "$REPLY" = "1" ]; then
            BRdeditor="nano"
          elif [ "$REPLY" = "2" ]; then
            BRdeditor="vi"
          fi
          $BRdeditor /mnt/target/etc/fstab
        fi
      fi
    fi

   (prepare_chroot
    build_initramfs
    generate_locales
    install_bootloader
    sleep 2) 1> >(tee -a /tmp/restore.log) 2>&1 | dialog --title "PROCESSING" --progressbox 30 100

    if [ -f /tmp/bl_error ]; then diag_tl="Error"; else diag_tl="Info"; fi

    if [ -z "$BRquiet" ]; then
      dialog --yes-label "OK" --no-label "View Log" --title "$diag_tl" --yesno "$(exit_screen)" 0 0
      if [ "$?" = "1" ]; then dialog --textbox /tmp/restore.log 0 0; fi
    else
      dialog --title "$diag_tl" --infobox "$(exit_screen_quiet)" 0 0
    fi

    sleep 1
    clean_unmount_out
  fi
fi