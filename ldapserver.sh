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
    echo "8. Salir"
    echo "============================"
}

# Función para crear un usuario en LDAP
crear_usuario() {
    read -p "Nombre de usuario: " username
    read -s -p "Contraseña: " password
    echo
    read -p "Email: " email
    read -p "Directorio: " directory
    # Otros parámetros que desees configurar

    # Generar hash de la contraseña
    password_hash=$(slappasswd -s "$password")

    # Crear archivo LDIF para el usuario
    cat <<EOF > /tmp/usuario.ldif
dn: uid=$username,ou=unidad,dc=vegasoft,dc=local
objectClass: inetOrgPerson
objectClass: posixAccount
uid: $username
cn: $username
sn: $username
userPassword: $password_hash
mail: $email
homeDirectory: $directory
# Otros atributos LDAP que desees configurar
EOF

    # Agregar usuario al LDAP
    ldapadd -x -D "cn=admin,dc=vegasoft,dc=local" -w "P@ssw0rd" -f /tmp/usuario.ldif

    echo "Usuario creado exitosamente."
}

# Función para borrar un usuario en LDAP
borrar_usuario() {
    read -p "Nombre de usuario a borrar: " username

    # Eliminar usuario del LDAP
    ldapdelete -x -D "cn=admin,dc=vegasoft,dc=local" -w "P@ssw0rd" "uid=$username,ou=unidad,dc=vegasoft,dc=local"

    echo "Usuario borrado exitosamente."
}

# Función para modificar un usuario en LDAP
modificar_usuario() {
    read -p "Nombre de usuario a modificar: " username

    # Pedir los nuevos valores
    read -p "Nuevo email: " new_email
    read -p "Nuevo directorio: " new_directory
    # Otros parámetros que desees modificar

    # Modificar usuario en LDAP
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

# Función para crear un grupo en LDAP
crear_grupo() {
    read -p "Nombre del grupo: " groupname

    # Crear archivo LDIF para el grupo
    cat <<EOF > /tmp/grupo.ldif
dn: cn=$groupname,ou=grupos,dc=vegasoft,dc=local
objectClass: posixGroup
cn: $groupname
gidNumber: $(shuf -i 2000-9999 -n 1)
EOF

    # Agregar grupo al LDAP
    ldapadd -x -D "cn=admin,dc=vegasoft,dc=local" -w "P@ssw0rd" -f /tmp/grupo.ldif

    echo "Grupo creado exitosamente."
}

# Función para borrar un grupo en LDAP
borrar_grupo() {
    read -p "Nombre del grupo a borrar: " groupname

    # Eliminar grupo del LDAP
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

# Bucle principal del script
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
        8) exit ;;
        *) echo "Opción inválida. Intente de nuevo." ;;
    esac

    read -p "Presione Enter para continuar..."
done
