#!/bin/bash
# ============================================================
#   EOSSL - Get an SSL certificate very easily
#   DEV BY EOAMIR
#   T.ME/EOAMIRM
# ============================================================

print() {
    echo -e "\e[94m""$1""\e[0m"
}

error() {
    echo -e "\e[1;91m[error] ""$1""\e[0m"
}

success() {
    echo -e "\e[1;94m[success] ""$1""\e[0m"
}

input() {
    read -r -p "$(echo -e '\e[33m'"$1"'\e[0m')" "$2"
}

require_root() {
    if [ "$(id -u)" -ne 0 ]; then
        error "This script must be run as root. Try: sudo bash eossl.sh"
        exit 1
    fi
}

update_packages() {
    if command -v apt &>/dev/null; then
        apt update && apt install -y socat
    elif command -v yum &>/dev/null; then
        yum -y update && yum -y install socat
    elif command -v dnf &>/dev/null; then
        dnf -y update && dnf -y install socat
    elif command -v pacman &>/dev/null; then
        pacman -Sy --noconfirm socat
    else
        error "Unsupported operating system."
        exit 1
    fi
}

install_certbot() {
    if ! command -v certbot &>/dev/null; then
        if command -v apt &>/dev/null; then
            apt install -y certbot
        elif command -v yum &>/dev/null; then
            yum -y install certbot
        elif command -v dnf &>/dev/null; then
            dnf -y install certbot
        elif command -v pacman &>/dev/null; then
            pacman -Sy --noconfirm certbot
        else
            error "Certbot installation failed. Unsupported operating system."
            exit 1
        fi
    fi
}

install_acme() {
    if [ ! -f "$HOME/.acme.sh/acme.sh" ]; then
        curl https://get.acme.sh | sh || { error "Error installing acme.sh, check logs..."; exit 1; }
        "$HOME/.acme.sh/acme.sh" --set-default-ca --server letsencrypt
    fi
}

validate_domain() {
    while true; do
        input "Please enter your domain: " domain
        if [[ "$domain" =~ ^[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ && ${#domain} -ge 3 ]]; then
            return 0
        else
            error "Invalid domain format. Please enter a valid domain name."
        fi
    done
}

validate_email() {
    while true; do
        input "Please enter your email: " email
        if [[ "$email" =~ ^[^@]+@[^@]+\.[^@]+$ && ${#email} -gt 5 ]]; then
            return 0
        else
            error "Invalid email format. Please enter a valid email address."
        fi
    done
}

validate_apikey() {
    while true; do
        input "Please enter your Global API key: " api_key
        if [[ -n "$api_key" ]]; then
            break
        else
            error "API key cannot be empty. Please enter a valid API key."
        fi
    done
}

set_directory() {
    address="$1"
    if [ -d "$address" ]; then
        rm -rf "$address" || { error "Error removing existing directory"; exit 1; }
    fi
    mkdir -p "$address" || { error "Error creating directory"; exit 1; }
}

move_ssl_files_combined() {
    local domain="$1"
    local type="$2"
    local dest_dir=""

    while true; do
        print "\n\n\nMoved to?\n"
        print "1. Custom directory"
        print "2. Marzban panel directory"
        print "3. 3x-ui/x-ui/s-ui/hiddify panel directory"
        input "\nEnter your choice (1, 2, 3): " "choice"

        case $choice in
            1)
                while true; do
                    input "\nEnter the destination directory path: " "dest_dir"
                    if [ -z "$dest_dir" ]; then
                        error "Destination directory cannot be empty."
                    elif [[ ! "$dest_dir" == /* ]]; then
                        error "Destination directory must start with '/'."
                    elif [[ "$dest_dir" == */ || "$dest_dir" == *//* ]]; then
                        error "Invalid destination directory format. Please avoid trailing '/' and consecutive '/'."
                    else
                        dest_dir="$dest_dir/$domain"
                        set_directory "$dest_dir"
                        break
                    fi
                done
                ;;
            2)
                dest_dir="/var/lib/marzban/certs/$domain"
                set_directory "$dest_dir"
                ;;
            3)
                dest_dir="/certs/$domain"
                set_directory "$dest_dir"
                ;;
            *)
                error "Invalid choice. Please enter 1, 2, or 3."
                continue
                ;;
        esac

        if [ ! -d "$dest_dir" ] || [ ! -w "$dest_dir" ]; then
            error "Directory '$dest_dir' either does not exist or is not writable."
            continue
        fi

        if [ "$type" == "acme" ]; then
            if [ ! -f "$HOME/.acme.sh/${domain}_ecc/fullchain.cer" ] || [ ! -f "$HOME/.acme.sh/${domain}_ecc/${domain}.key" ]; then
                error "Certificate files not found in '$HOME/.acme.sh/${domain}_ecc/'."
                break
            fi
            cp "$HOME/.acme.sh/${domain}_ecc/fullchain.cer" "$dest_dir/fullchain.cer" || { error "Error copying certificate files"; return 1; }
            cp "$HOME/.acme.sh/${domain}_ecc/${domain}.key" "$dest_dir/privkey.key" || { error "Error copying certificate files"; return 1; }
            success "SSL certificate files for domain '$domain' successfully moved.\n\n\t⭐ SSL location: $dest_dir\n\n\tfullchain: $dest_dir/fullchain.cer\n\tkey file : $dest_dir/privkey.key\n\n"
        elif [ "$type" == "certbot" ]; then
            if [ ! -f /etc/letsencrypt/live/"$domain"/fullchain.pem ] || [ ! -f /etc/letsencrypt/live/"$domain"/privkey.pem ]; then
                error "Certificate files not found in '/etc/letsencrypt/live/$domain/'."
                break
            fi
            cp /etc/letsencrypt/live/"$domain"/fullchain.pem "$dest_dir/fullchain.pem" || { error "Error copying certificate files"; return 1; }
            cp /etc/letsencrypt/live/"$domain"/privkey.pem "$dest_dir/privkey.pem" || { error "Error copying certificate files"; return 1; }
            success "SSL certificate files for domain '$domain' successfully moved.\n\n\t⭐ SSL location: $dest_dir\n\n\tfullchain: $dest_dir/fullchain.pem\n\tkey file : $dest_dir/privkey.pem\n\n"
        fi
        break
    done
}

get_single_ssl() {
    local domain="$1"
    local email="$2"

    if "$HOME/.acme.sh/acme.sh" --issue --force --standalone -d "$domain"; then
        success "\n\n\t⭐ SSL certificate for domain '$domain' successfully obtained."
        move_ssl_files_combined "$domain" "acme"
    elif certbot certonly --standalone -d "$domain" --email "$email" --agree-tos --non-interactive; then
        success "\n\n\t⭐ SSL certificate for domain '$domain' successfully obtained."
        move_ssl_files_combined "$domain" "certbot"
    else
        error "Failed to obtain SSL certificate for domain '$domain'. Please check your DNS configuration and try again.\n"
    fi
}

get_multi_domain_ssl() {
    local domains="$1"
    local email="$2"
    local domain_args=""

    for d in $domains; do
        domain_args+=" -d $d"
    done

    if certbot certonly --standalone $domain_args --email "$email" --agree-tos --non-interactive; then
        success "\n\n\t⭐ SSL certificate for domains '$domains' successfully obtained."
        for d in $domains; do
            move_ssl_files_combined "$d" "certbot"
        done
    elif "$HOME/.acme.sh/acme.sh" --issue --force --standalone $domain_args; then
        success "\n\n\t⭐ SSL certificate for domains '$domains' successfully obtained."
        for d in $domains; do
            move_ssl_files_combined "$d" "acme"
        done
    else
        error "\n\tFailed to obtain SSL certificate for domains '$domains'.\n"
    fi
}

get_wildcard_ssl() {
    local domain="$1"
    local email="$2"

    if certbot certonly --manual --preferred-challenges=dns -d "*.$domain" --agree-tos --email "$email"; then
        success "\n\n\t⭐ SSL certificate for domain '*.$domain' successfully obtained."
        move_ssl_files_combined "$domain" "certbot"
    else
        error "Failed to obtain SSL certificate for domain '$domain'. Please check your DNS configuration and try again.\n"
    fi
}

revoke_ssl() {
    local domain="$1"
    local ssl_path="/etc/letsencrypt/live/$domain/fullchain.pem"

    if [ -f "$ssl_path" ]; then
        if certbot revoke --cert-path "$ssl_path" --non-interactive; then
            success "SSL certificate for domain '$domain' revoked successfully."
        else
            error "Failed to revoke SSL certificate for domain '$domain'."
        fi
    elif [ -f "$HOME/.acme.sh/${domain}_ecc/${domain}.cer" ]; then
        if "$HOME/.acme.sh/acme.sh" --revoke -d "$domain"; then
            success "SSL certificate for domain '$domain' revoked successfully."
        else
            error "Failed to revoke SSL certificate for domain '$domain'."
        fi
    else
        error "No SSL certificate found for domain '$domain'."
    fi
}

renew_ssl() {
    local domain="$1"
    local ssl_type=""

    if certbot certificates --cert-name "$domain" 2>/dev/null | grep -q "Certificate Name: $domain"; then
        ssl_type="certbot"
    elif [ -f "$HOME/.acme.sh/${domain}_ecc/${domain}.cer" ]; then
        ssl_type="acme"
    else
        error "No SSL certificate found for domain '$domain'."
        return 1
    fi

    if [ "$ssl_type" == "certbot" ]; then
        if certbot renew --cert-name "$domain"; then
            success "SSL certificate for domain '$domain' renewed successfully."
        else
            error "Failed to renew SSL certificate for domain '$domain' using Certbot. check logs..."
        fi
    elif [ "$ssl_type" == "acme" ]; then
        if "$HOME/.acme.sh/acme.sh" --renew -d "$domain"; then
            success "SSL certificate for domain '$domain' renewed successfully."
        else
            error "Failed to renew SSL certificate for domain '$domain' using ACME.sh. check logs..."
        fi
    fi
}

get_cloudflare_ssl() {
    local domain="$1"
    local api_key="$2"
    local email="$3"

    export CF_Key="$api_key"
    export CF_Email="$email"

    if "$HOME/.acme.sh/acme.sh" --issue -d "${domain}" -d "*.${domain}" --dns dns_cf --log; then
        success "\n\n\t⭐ SSL certificate for domain '$domain' successfully obtained from Cloudflare."
        move_ssl_files_combined "$domain" "acme"
    else
        error "\n\tFailed to obtain SSL certificate for domain '$domain' from Cloudflare."
    fi

    unset CF_Key CF_Email
}

remove_packages() {
    if command -v apt &>/dev/null; then
        apt remove --purge -y socat certbot
    elif command -v yum &>/dev/null; then
        yum -y remove socat certbot
    elif command -v dnf &>/dev/null; then
        dnf -y remove socat certbot
    elif command -v pacman &>/dev/null; then
        pacman -Rns --noconfirm socat certbot
    else
        error "Unsupported operating system."
        exit 1
    fi
}

remove_acme() {
    if [ -d "$HOME/.acme.sh" ]; then
        "$HOME/.acme.sh/acme.sh" --uninstall
        rm -rf "$HOME/.acme.sh"
    fi
}

remove_certificates() {
    rm -rf /etc/letsencrypt
    rm -rf /var/lib/marzban/certs
    rm -rf /certs
}

remove_files() {
    rm -f /usr/local/bin/eossl.sh
    rm -f /usr/local/bin/eossl
}

clean_system() {
    if command -v apt &>/dev/null; then
        apt autoremove -y
        apt clean
    elif command -v yum &>/dev/null; then
        yum -y autoremove
    elif command -v dnf &>/dev/null; then
        dnf -y autoremove
    elif command -v pacman &>/dev/null; then
        local orphans
        orphans="$(pacman -Qdtq)"
        [ -n "$orphans" ] && pacman -Rns --noconfirm $orphans
    else
        error "Unsupported operating system."
        exit 1
    fi
}

uninstall_eossl() {
    clear
    print "\n\n\tStarting EOSSL uninstallation...\n"

    remove_packages
    remove_acme

    print "\nDo you want to delete all certificates?"
    input "\nEnter your choice (Y/N): " "D_C_choice"
    if [[ "$D_C_choice" =~ ^[Yy]$ ]]; then
        print "\nAre you sure?"
        input "\nEnter your choice (Y/N): " "D_C2_choice"
        if [[ "$D_C2_choice" =~ ^[Yy]$ ]]; then
            remove_certificates
        fi
    else
        print "\nOk, we keep the certificates, they are in these folders"
        print "\n/etc/letsencrypt"
        print "\n/var/lib/marzban/certs"
        print "\n/certs"
    fi

    remove_files
    clean_system

    success "\n\n\tEOSSL and all related components have been successfully removed.\n"
}

# ============================================================
#   MAIN
# ============================================================

require_root

clear
update_packages
install_certbot
install_acme
clear

print "\n\n\t\tWelcome to EOSSL (V1.0)\n"
print "\t DEV BY EOAMIR"
print "\t T.ME/EOAMIRM\n\n"

while true; do
    print "-------------------------------------------------------"
    print "1) New Single Domain ssl (sub.domain.com)"
    print "2) New Wildcard ssl (*.domain.com)"
    print "3) New Multi-Domain ssl (sub.domain1.com sub2.domain2.com ...)"
    print "4) Renewal ssl (update)"
    print "5) Revoke ssl (delete)"
    print "6) Uninstall and delete cert files"
    print "0) Exit"
    input '\nPlease Select your option: ' 'option'
    clear

    case "$option" in
        1)
            print "1) with acme & certbot (recommend)"
            print "2) with cloudflare api"
            input "\nplease enter your option number: " "select_option"
            clear
            case "$select_option" in
                1)
                    validate_domain
                    validate_email
                    clear
                    get_single_ssl "$domain" "$email"
                    ;;
                2)
                    validate_domain
                    validate_email
                    validate_apikey
                    get_cloudflare_ssl "$domain" "$api_key" "$email"
                    ;;
                *)
                    error "Invalid option."
                    ;;
            esac
            ;;
        2)
            print "1) with acme & certbot"
            print "2) with cloudflare api (recommend)"
            input "\nplease enter your option number: " "select_option"
            clear
            case "$select_option" in
                1)
                    validate_domain
                    validate_email
                    clear
                    get_wildcard_ssl "$domain" "$email"
                    ;;
                2)
                    validate_domain
                    validate_email
                    validate_apikey
                    get_cloudflare_ssl "$domain" "$api_key" "$email"
                    ;;
                *)
                    error "Invalid option. Please enter 1 or 2."
                    ;;
            esac
            ;;
        3)
            input "\nEnter domains separated by space: " "domain"
            validate_email
            clear
            get_multi_domain_ssl "$domain" "$email"
            ;;
        4)
            validate_domain
            renew_ssl "$domain"
            ;;
        5)
            validate_domain
            revoke_ssl "$domain"
            ;;
        6)
            print "Are you sure?"
            input "\nEnter your choice (Y/N): " "u_choice"
            if [[ "$u_choice" =~ ^[Yy]$ ]]; then
                uninstall_eossl
            else
                print "Ok, we keep it!"
            fi
            ;;
        0)
            clear
            exit 0
            ;;
        *)
            error "Invalid input. Please select a valid option.\n\n"
            ;;
    esac
done
