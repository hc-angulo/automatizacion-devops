#!/bin/bash  
                                                                                                                                                                                                                                                                                              
# --- Colores ANSI --- #                                                                                                                                        
                                                                                                                                                      
COLOR_ROJO="\e[31m"                                                                                                                                   
COLOR_VERDE="\e[32m"                                                                                                                                  
COLOR_AMARILLO="\e[33m"                                                                                                                             
COLOR_RESET="\e[0m"                                                                                                                                                                                                                                                             

                                                                                                                                                  
# --- Validando usuario root --- #                                                                                                                    
                                                                                                                                                      
if [ "$(id -u)" -ne 0 ]; then                                                                                                                      
    echo -e "${COLOR_ROJO}El Script debe ser ejecutado por un usuario Root${COLOR_RESET}" 
    exit 1                                                            
fi                                                                                                                                                    

REPOSITORIO="bootcamp-devops-2023"                                                                                                                                                    
URL="https://github.com/roxsross/$REPOSITORIO.git"                                                                                            
                                                                                                                    
                                                                                                                                                      
# --- Actualizando sistema operativo --- #                                                                                                            
                                                                                                                                                      
apt-get update                                                                                                                                        
echo -e "${COLOR_VERDE}SO actualizado${COLOR_RESET}"                                                                                                  
                                                                                                                                                      
# --- Instalación de paquetes --- #                                                                                                                   
                                                                                                                                                      
packages=("apache2" "git" "curl" "php" "libapache2-mod-php" "php-mysql" "php-mbstring" "php-zip" "php-gd" "php-json" "php-curl" "mariadb-server")  


for package in "${packages[@]}"; do                                                                                                                   
    if ! dpkg -l $package > /dev/null 2>&1; then                                                                                                      
        echo -e "${COLOR_AMARILLO}Instalando $package${COLOR_RESET}"                                                                                  
        apt-get update                                                                                                                                
        apt install $package -y                                                                                                                       
        if [ $? -eq 0 ]; then                                                                                                                         
            echo -e "${COLOR_VERDE}$package ha sido instalado exitosamente${COLOR_RESET}"                                                             
            if [ "$package" == "apache2" -o "$package" == "mariadb-server" ];then  
                if [ "$package" == "mariadb-server"];then
                      systemctl start mariadb                                                                                                              
                      systemctl enable mariadb 
                      echo -e "${COLOR_VERDE}$package ha sido habilitado${COLOR_RESET}"
                      continue
                fi                                                                                                
                systemctl start $package                                                                                                              
                systemctl enable $package                                                                                                             
                echo -e "${COLOR_VERDE}$package ha sido habilitado${COLOR_RESET}"                                                                     
            fi                                                                                                                                       
        else                                                                                                                                          
            echo -e "${COLOR_ROJO}Error al instalar $package${COLOR_RESET}"                                                                           
            exit 1                                                                                                                                    
        fi                                                                                                                                            
    else                                                                                                                                              
        echo -e "${COLOR_VERDE}$package ya fue instalado${COLOR_RESET}"                                                                                                                                                                                                                    
    fi                                                                                                                                                
                                                                                                                                                      
done     

# --- Configuración de Base de Datos --- #
$mysql
MariaDB > CREATE DATABASE devopstravel;
MariaDB > CREATE USER 'codeuser'@'localhost' IDENTIFIED BY 'codepass';
MariaDB > GRANT ALL PRIVILEGES ON *.* TO 'codeuser'@'localhost';
MariaDB > FLUSH PRIVILEGES;

mysql < bootcamp-devops-2023/app-295devops-travel/database/devopstravel.sql

# --- Configuración de Servidor Web - Apache2 --- #

sed -i '/DirectoryIndex/c\DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm' /etc/apache2/mods-enabled/dir.conf
###systemctl reload apache2


# --- Verficación de existencia del repositorio --- #                                                                                                     
                                                                                                                                                      
if [ -d "$REPOSITORIO" ]; then                                                                                                                        
    echo -e "${COLOR_VERDE}El repositorio $REPOSITORIO existe${COLOR_RESET}" 
    echo -e "${COLOR_AMARILLO}Actualizando repositorio $REPOSITORIO${COLOR_RESET}"                                                                        
    cd $REPOSITORIO && git pull     
    echo -e "${COLOR_VERDE}El repositorio $REPOSITORIO ha sido actualizado${COLOR_RESET}"                                                                                                                  
else                                                                                                                                                  
    echo -e "${COLOR_ROJO}El respositorio $REPOSITORIO no existe${COLOR_RESET}" 
    echo -e "${COLOR_AMARILLO}Clonando repositorio $REPOSITORIO${COLOR_RESET}"                                                                      
    git clone -b clase2-linux-bash $URL  
    echo -e "${COLOR_VERDE}El repositorio $REPOSITORIO ha sido clonado exitosamente${COLOR_RESET}"
    sed -i '/$dbPassword/c\$dbPassword = "codepass";' $REPOSITORIO/app-295devops-travel/config.php
    mv /var/www/html/index.html /var/www/html/index.html.php                                                                                                             
    cp -r $REPOSITORIO/app-295devops-travel/* /var/www/html 
    systemctl reload apache2                                                                                                               
    echo -e "${COLOR_VERDE}Instalando WEB...${COLOR_RESET}"                                                                                           
fi    

# ------- #
systemctl reload apache2                                                                                                                                                     
echo -e "${COLOR_VERDE}Instalación WEB finalizada.${COLOR_RESET}"  