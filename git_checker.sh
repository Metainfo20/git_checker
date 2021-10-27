#!/bin/bash

RUNDIR=$(pwd)
CONFIG="git_checker_config"

# MAIN FUNCS:

f_welcome () {
    echo "Welcome to Git checker version 1.0" > welcome
    whiptail --textbox welcome 12 80
    rm welcome
}

f_menu_setup () {
    local TITLE="Git checker setup"
    local MESSAGE="Enter branch prefix. \
    For example, PREFIX:\\nREG-\\nIt will be used for branches REG-100, REG-101 etc"
    local YES="Ok"
    local NO="Exit"
    PREFIX=$(whiptail --title "$TITLE" --inputbox "$MESSAGE" 10 60 "REG-" \
    --ok-button "$YES" --cancel-button "$NO" \
    3>&1 1>&2 2>&3)
    
    local MESSAGE="Enter name of main branch. For example, MAIN branch can be:\\norigin"
    local YES="Ok"
    local NO="Exit"
    MAIN=$(whiptail --title "$TITLE" --inputbox "$MESSAGE" 10 60 "origin" \
    --ok-button "$YES" --cancel-button "$NO" \
    3>&1 1>&2 2>&3)
    
    local MESSAGE="Enter name of submain branch. For example, SUBMAIN branch can be:\\nmain or master"
    local YES="Ok"
    local NO="Exit"
    SUBMAIN=$(whiptail --title "$TITLE" --inputbox "$MESSAGE" 10 60 "main" \
    --ok-button "$YES" --cancel-button "$NO" \
    3>&1 1>&2 2>&3)
    printf "MAIN=$MAIN\\nSUBMAIN=$SUBMAIN\\nPREFIX=$PREFIX\\n" > git_checker_config
    whiptail --textbox git_checker_config  12 80
}

f_menu_main () {
    CURRENT_BRANCH=$(git status | grep "На ветке")
    CURRENT_BRANCH2=$(git branch | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
    local TITLE="Git checker: $CURRENT_BRANCH2"
    local MESSAGE="Current branch: $CURRENT_BRANCH\\n================================ \
    \\nCurrent Scheme:$MAIN $SUBMAIN\\nCurrent PREFIX:$PREFIX"
    local OK="Next"
    local NO="Exit"
    SELECTED_MODE=$(whiptail --title "$TITLE" --menu "$MESSAGE" --ok-button "$OK" \
    --cancel-button "$NO" 24 80 12 \
    "1)" "Git pull current branch" \
    "2)" "Git status (Quick)" \
    "3)" "Git status (Full)" \
    "4)" "Git checkout $MAIN $SUBMAIN" \
    "5)" "Git fetch" \
    "6)" "Git checkout" \
    "7)" "Git command ..." \
    "8)" "Previous branch" \
    "9)" "Change prefix for branches" \
    3>&1 1>&2 2>&3)
    f_menu_main_next
}

f_menu_main_next () {
    YES="Next"
    NO="Cancel"
    exitstatus=$?
    if [ $exitstatus = 0 ]
    then	
        echo "Yes.Exit status was $?"
        if [[ "$SELECTED_MODE" = "1)" ]]
        then
            git pull $MAIN $CURRENT_BRANCH2 > git_pull
            whiptail --textbox git_pull \
            --title "Git pull output. Use arrow, page, home & end keys. Tab toggle option" \
            --scrolltext  24 80
            rm git_pull
            f_menu_main
        fi
        if [[ "$SELECTED_MODE" = "2)" ]]
        then
            echo $CURRENT_BRANCH
            f_menu_main
        fi
        if [[ "$SELECTED_MODE" = "3)" ]]
        then
            git status > git_status
            whiptail --textbox git_status \
            --title "Git status output. Use arrow, page, home & end keys. Tab toggle option" \
            --scrolltext  24 80
            rm git_status
            f_menu_main
        fi
        if [[ "$SELECTED_MODE" = "4)" ]]
        then
            git checkout $SUBMAIN
            f_menu_main
        fi
        if [[ "$SELECTED_MODE" = "5)" ]]
        then
            git fetch > git_fetch
            whiptail --textbox git_fetch --title "Git Fetch output"  --scrolltext  24 80
            rm git_fetch
            f_menu_main
        fi
        if [[ "$SELECTED_MODE" = "6)" ]]
        then
            BRANCH_CHECKOUT=$(whiptail --title "Git Checkout $PREFIX" \
            --inputbox "Input branch digit" 10 60 "$PREFIX" \
            --ok-button "$YES" --cancel-button "$NO" \
            3>&1 1>&2 2>&3)
            git checkout $BRANCH_CHECKOUT
            f_menu_main
        fi
        if [[ "$SELECTED_MODE" = "7)" ]]
        then
            GIT_CMD=$(whiptail --title "Run Git Command" --inputbox "Input git command" 10 60 "git log" \
            --ok-button "$YES" --cancel-button "$NO" \
            3>&1 1>&2 2>&3)
            $GIT_CMD > git_cmd_output
            whiptail --textbox git_cmd_output --title "$GIT_CMD output"  --scrolltext  24 80
            rm git_cmd_output
            f_menu_main
        fi
        if [[ "$SELECTED_MODE" = "8)" ]]
        then
            git checkout -
            f_menu_main
        fi
        if [[ "$SELECTED_MODE" = "9)" ]]
        then
            PREFIX=$(whiptail --title "Set prefix" --inputbox "Input new prefix" 10 60 "$PREFIX" \
            --ok-button "$YES" --cancel-button "$NO" \
            3>&1 1>&2 2>&3)
            f_menu_main
        fi
    else
        exit
    fi
}

f_welcome

if [ ! -f $CONFIG ]; then
    echo "Config file $CONFIG not found! Setup is loading.."
    f_menu_setup
    echo "Setup completed. Please re-run git_checker"	
else
    source git_checker_config
    f_menu_main
fi

