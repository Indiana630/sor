#!/bin/bash

# Función para mostrar el menú principal
mostrar_menu() {
    clear
    echo "===== MENU LDAP Y NFS ====="
    echo "1. Crear Usuario"
    echo "2. Borrar Usuario"
    echo "3. Modificar Usuario"
    echo "4. Crear Grupo"
    echo "5. Borrar Grupo"
    echo "6. Modificar Grupo"
    echo "7. Crear Unidad NFS para Usuario Móvil"
    echo "8. Instalar y Configurar LDAP Account Manager (LAM)"
    echo "9. Salir"
    echo "============================"
}

crear_usuario() {
    read -p "Nombre de usuario: " username
    read -s -p "Contraseña: " password
    echo
    read -p "Correo electrónico: " email
    read -p "Nombre completo: " full_name
    read -p "UID Number: " uid_number
    read -p "GID Number: " gid_number
    read -p "Directorio de inicio: " home_directory
    read -p "Shell de inicio de sesión: " login_shell

    # Generar hash de la contraseña
    password_hash=$(slappasswd -s "$password")

    # Crear archivo LDIF para el usuario
    cat <<EOF > /tmp/usuario.ldif
dn: uid=$username,ou=unidad,dc=somebooks,dc=local
objectClass: top
objectClass: posixAccount
objectClass: inetOrgPerson
objectClass: person
cn: $username
uid: $username
ou: grupo
uidNumber: $uid_number
gidNumber: $gid_number
homeDirectory: $home_directory
loginShell: $login_shell
userPassword: $password_hash
sn: $(echo $full_name | awk '{print $NF}')
mail: $email
givenName: $(echo $full_name | awk '{print $1}')
EOF


    ldapadd -x -D "cn=admin,dc=somebooks,dc=local" -w "P@ssw0rd" -f /tmp/usuario.ldif

    echo "Usuario creado exitosamente."
}

modificar_usuario() {
    read -p "Nombre de usuario a modificar: " username

    # Pedir los nuevos valores
    read -p "Nuevo email: " new_email
    read -p "Nuevo directorio: " new_directory

    ldapmodify -x -D "cn=admin,dc=vegasoft,dc=local" -w "P@ssw0rd" <<EOF
dn: uid=$username,ou=unidad,dc=vegasoft,dc=local
changetype: modify
replace: mail
mail: $new_email
replace: homeDirectory
homeDirectory: $new_directory
# Otros atributos que desees modificar
EOF

    echo "Usuario modificado exitosamente."
}
crear_grupo() {
    read -p "Nombre del grupo: " groupname
    read -p "GID Number: " gid_number

    # Crear archivo LDIF para el grupo
    cat <<EOF > /tmp/grupo.ldif
dn: cn=$groupname,ou=unidad,dc=somebooks,dc=local
objectClass: top
objectClass: posixGroup
gidNumber: $gid_number
cn: $groupname
# Otros atributos LDAP que desees configurar
EOF

    # Agregar grupo al LDAP
    ldapadd -x -D "cn=admin,dc=somebooks,dc=local" -w "P@ssw0rd" -f /tmp/grupo.ldif

    echo "Grupo creado exitosamente."
}

borrar_grupo() {
    read -p "Nombre del grupo a borrar: " groupname
    ldapdelete -x -D "cn=admin,dc=vegasoft,dc=local" -w "P@ssw0rd" "cn=$groupname,ou=grupos,dc=vegasoft,dc=local"

    echo "Grupo borrado exitosamente."
}

# Función para modificar un grupo en LDAP
modificar_grupo() {
    read -p "Nombre del grupo a modificar: " groupname

    # Pedir los nuevos valores
    read -p "Nuevo GID: " new_gid
    # Otros parámetros que desees modificar

    # Modificar grupo en LDAP
    ldapmodify -x -D "cn=admin,dc=vegasoft,dc=local" -w "P@ssw0rd" <<EOF
dn: cn=$groupname,ou=grupos,dc=vegasoft,dc=local
changetype: modify
replace: gidNumber
gidNumber: $new_gid
# Otros atributos que desees modificar
EOF

    echo "Grupo modificado exitosamente."
}

# Función para crear una unidad NFS para usuario móvil
crear_unidad_nfs() {
    read -p "Nombre de usuario móvil: " username

    # Crear directorio para el usuario móvil
    mkdir -p "/root/perfilesmoviles/$username"
    chown -R nobody:nogroup "/root/perfilesmoviles/$username"
    chmod -R 777 "/root/perfilesmoviles/$username"

    echo "Unidad NFS para usuario móvil creada exitosamente."
}

# Función para instalar y configurar LDAP Account Manager (LAM)
instalar_configurar_lam() {
    # Instalar LDAP Account Manager
    apt-get update
    apt-get install -y ldap-account-manager

    # Configurar LAM
    sed -i 's|ldap://localhost|ldaps://localhost|g' /etc/ldap-account-manager/config.cfg
    sed -i 's|sizelimit \= 200|sizelimit \= 1000|g' /etc/ldap-account-manager/config.cfg

    # Reiniciar servicio Apache
    systemctl restart apache2

    echo "LDAP Account Manager (LAM) instalado y configurado."
}

while true; do
    mostrar_menu
    read -p "Seleccione una opción: " opcion

    case $opcion in
        1) crear_usuario ;;
        2) borrar_usuario ;;
        3) modificar_usuario ;;
        4) crear_grupo ;;
        5) borrar_grupo ;;
        6) modificar_grupo ;;
        7) crear_unidad_nfs ;;
        8) instalar_configurar_lam ;;
        9) exit ;;
        *) echo "Opción inválida. Intente de nuevo." ;;
    esac

    read -p "Presione Enter para continuar..."
done
