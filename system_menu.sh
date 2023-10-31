
read -r name < <(whoami)
log_action() {
    local log_file="useradmin.log"
    local action="$1"
    local username="$2"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    echo "$timestamp - $action - $username" >> "$log_file"
}

choice='START'
while  [[ ${choice::1} != 'Q' ]]
    do
        clear

        dates=$(date)
        echo "Today is: $dates"

        ./banner.sh -w50 'Welcome to the system   '
        ## ./banner.sh -c '#' "Welcome to the system"

        echo
        echo -n "Hello "
        grep -w $name /etc/passwd | cut -d':' -f 5 | cut -d',' -f 1

        echo
        echo "Welcome to the System"

        echo 
        echo "Note that these are administrative functions so you"
        echo "will require the administrative password."
        
        ./banner.sh -w40 'System Menu   '

        echo
        echo "Enter your choice:"
        echo "(P)rint out a list of regular users"
        echo "(L)ist out all of the user groups"
        echo "(A)dd a new user to the system"
        echo "(C)reate a welcome file to a user's home directory"
        echo "(S)et an account expiration date for user account"
        echo "(D)elete a user from the system"
        

        echo
        echo "(Q)uit the menu"

        
        read choice
        choice=${choice^}

        case ${choice::1} in

            Q)  echo "have a great day!"
                ;;

            P)   ./banner.sh -w40 'Actual Users of the System    '
                ##awk -F: '$3 >= 1000 && $1 != "nobody" { if ($5 != "") {gsub(/,,+/, ",", $5); print $1 ": " $5} else print $1 ": Current user"; }' /etc/passwd 
                ##read -p 'press enter to continue' temp
        awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd | while IFS= read -r username; do
            full_name=$(getent passwd "$username" | cut -d: -f5)
            if [[ -n "$full_name" ]]; then
                echo "Username: $username, Full Name: $full_name"
            else
                echo "Username: $username"
            fi
        done
        read -rp 'Press Enter to continue' temp
        ;;
            
            L)  ./banner.sh -w40 'User groups of the System  '
            echo "A * indicates that the group is not a personal group"
            echo
                awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd | while IFS= read -r user; do
                groups=$(id -Gn "$user" | tr ' ' '\n' | sort -u | grep -v -E '^(nogroup|nobody)$')
                for group in $groups; do
                    if [[ $(grep -c "^$group:" /etc/group) -eq 1 ]]; then
                        echo "$group group"
                    else
                        echo "* $group group"
                    fi
                    done
                done
                read -p 'press enter to continue' temp
                ;;

            A)   
            read -p "Enter the username for the new user: " new_username
            if ! id "$new_username" &>/dev/null; then
                sudo adduser "$new_username"
                log_action "Added user" "$new_username"
                echo "User $new_username added successfully."
            else
                echo "User $new_username already exists."
            fi
            read -p 'Press enter to continue' temp
            ;;

            C)  
            read -p "Enter the username for the user: " target_username
                if id "$target_username" &>/dev/null; then
                    if cp welcome.txt "/home/$target_username"; then
                        log_action "Welcome message sent" "$target_username"
                        echo "Welcome message copied to home directory of $target_username."
                    else
                        echo "Failed to copy the welcome message."
                    fi
                else
                    echo "User $target_username not found."
                fi
                read -p 'Press enter to continue' temp
                ;;

            S)
            read -p "Enter the username: " user
            read -p "Enter the expiry date (YYYY-MM-DD): " expiry_date
            sudo usermod -e "$expiry_date" "$user"
            log_action "Set expiry date for user $user: $expiry_date"
            ;;

            D)
            
            read -p "Enter the username to delete: " target_username
            if id "$target_username" &>/dev/null; then
            read -p "Are you sure you want to delete user $target_username? (yes/no): " confirmation
            if [[ $confirmation == "yes" ]]; then
                sudo userdel "$target_username"
                log_action "User deleted" "$target_username"
                echo "User $target_username deleted."
                home_dir=$(eval echo ~"$target_username")
                log_action "Orphaned" "$home_dir"
                echo "Orphaned $home_dir"
            else
                echo "User deletion canceled."
            fi
            else
            echo "User $target_username not found."
            fi
            read -p 'Press enter to continue' temp
            ;;

        esac
    done