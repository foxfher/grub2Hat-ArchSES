#!/bin/bash
# Archivo: install.sh

#┌───────────────────────────────────────────────────────────────────────────┐
#│            Instalación de Tema de Grub personalizado                      │
#│ Verifica si es para una Instalación nueva o si es sobre el Sistema Actual │
#│         @author Fernando Bello Mota <fbello04@hotmail.com>                │
#└───────────────────────────────────────────────────────────────────────────┘
# @param $1 : -i        type: String (espefica si ejecuta la comando(s) adicionales)

# Función que instala el tema
install() {
    # copía el tema del grub
    sudo mkdir -p ${theme_path}/${theme_name}
    sudo cp -rf ${theme_name}/* ${theme_path}/${theme_name}/

    # cambiar el nombre del thema
    sudo sed -i "s/#GRUB_THEME/GRUB_THEME/g" /etc/default/grub #habilita el tema
    sudo sed -i "s/${theme_pre}/${theme_new}/g" /etc/default/grub

    # copia el achivo de configuración para añadir al menu de grub Apagar y Reiniciar
    [[ ! -d /etc/grub.d/ ]] && sudo mkdir -p /etc/grub.d
    sudo cp -rf ._config/40_custom /etc/grub.d/40_custom

    # ejecuta la configiración del grub
    [[ $1 == "-i" ]] && sudo grub-mkconfig -o ${grub_cfg_path}
}

# Identifica la carpeta del grup indepemdiente de la Distrubución
_dirGrub() {
    local _grub=""
    if [ -e /etc/os-release ]; then
        source /etc/os-release
        [[ -f /boot/efi/EFI/${ID}/grub.cfg ]] && grub_cfg_path="/boot/efi/EFI/${ID}/grub.cfg"
        [[ "$ID" =~ (centos|fedora|opensuse) || "$ID_LIKE" =~ (fedora|rhel|suse) ]] && _grub="grub2" || _grub="grub"
    fi
    echo $_grub
}

# Mensaje de Bienvenida
welcome() {
    local lcn=$([[ $(locale | grep LC_NAME | cut -d'=' -f2 | cut -d'_' -f1 | cut -d'"' -f2) == "es" ]] && echo "es" || echo "ua")
    MESSAGES[es_install]="Instalación del tema grub ${theme_name}\n para el cargador de arranque "
    MESSAGES[us_install]="Installing the ${theme_name} grub theme\n for the boot loader"

    echo ""
    echo -e "\033[0;32m────────────────────────────────────────────────────────────────────────────────\033[0m"
    echo -e "\033[0;32m ${MESSAGES[${lcn}_install]}\033[0m"
    echo -e "\033[0;32m @author Fernando Bello Mota <fbello04@hotmail.com>\033[0m"
    echo -e "\033[0;32m https://github.com/foxfher/${theme_name}.git"
    echo -e "\033[0;32m────────────────────────────────────────────────────────────────────────────────\033[0m"
    echo ""
}

# Declaración de Variables
declare -A MESSAGES
theme_name=$(echo ${PWD##*/})
grub_dir=$(_dirGrub)
grub_cfg_path="/boot/${grub_dir}/grub.cfg"
theme_path="/usr/share/grub/themes" #"/boot/${grub_dir}/themes"
theme_pre="$(cat /etc/default/grub | grep 'GRUB_THEME=' | sed 's/GRUB_THEME="//g' | sed 's/"//g' | sed 's/#//g' | sed 's/\//\\\//g')"
theme_new=$(echo -e "${theme_path}/${theme_name}/theme.txt" | sed 's/\//\\\//g')

welcome
install "$@"
