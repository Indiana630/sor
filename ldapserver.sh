#!/bin/bash

# Verificar que se esté ejecutando localo super usuario
if [ "$(id -u)" -ne 0 ]; then
  echo "Este script debe ser ejecutado localo super usuario."
  exit 1
fi

# Función para agregar una unidad organizativa (OU)
agregar_ou() {
  read -p "Nombre de la nueva OU: " ou_name
  ldapadd -x -D "cn=admin,dc=vegasoft,dc=local" -W <<EOF
dn: ou=$ou_name,dc=vegasoft,dc=local
objectClass: organizationalUnit
ou: $ou_name
EOF
}

# Función para eliminar una unidad organizativa (OU)
eliminar_ou() {
  read -p "Nombre de la OU a eliminar: " ou_name
  ldapdelete -x -D "cn=admin,dc=vegasoft,dc=local" -W "ou=$ou_name,dc=vegasoft,dc=local"
}

# Función para agregar un grupo
agregar_grupo() {
  read -p "Nombre del nuevo grupo: " group_name
  ldapadd -x -D "cn=admin,dc=vegasoft,dc=local" -W <<EOF
dn: cn=$group_name,ou=Groups,dc=vegasoft,dc=local
objectClass: posixGroup
cn: $group_name
gidNumber: 10000
EOF
}

# Función para eliminar un grupo
eliminar_grupo() {
  read -p "Nombre del grupo a eliminar: " group_name
  ldapdelete -x -D "cn=admin,dc=vegasoft,dc=local" -W "cn=$group_name,ou=Groups,dc=vegasoft,dc=local"
}

# Función para agregar un usuario
agregar_usuario() {
  read -p "Nombre del nuevo usuario: " username
  read -p "UID del nuevo usuario: " uid
  read -p "Contraseña del nuevo usuario: " password

  read -p "¿Desea que el usuario sea móvil? (s/n): " mobile_option
  if [ "$mobile_option" == "s" ]; then
    mobile_flag="mobile"
  else
    mobile_flag=""
  fi

  ldapadd -x -D "cn=admin,dc=vegasoft,dc=local" -W <<EOF
dn: uid=$username,ou=Users,dc=vegasoft,dc=local
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
cn: $username
sn: $username
uid: $username
uidNumber: $uid
gidNumber: <PRIMARY_GROUP_ID>
userPassword: $password
homeDirectory: /home/$username
loginShell: /bin/bash
$mobile_flag: true
EOF
}

# Función para eliminar un usuario
eliminar_usuario() {
  read -p "Nombre del usuario a eliminar: " username
  ldapdelete -x -D "cn=admin,dc=vegasoft,dc=local" -W "uid=$username,ou=Users,dc=vegasoft,dc=local"
}

# Función para editar un usuario
editar_usuario() {
  read -p "Nombre de usuario a editar: " username
  read -p "Nuevo UID (dejar en blanco para no cambiar): " new_uid
  read -p "Nueva contraseña (dejar en blanco para no cambiar): " new_password

  ldapmodify -x -D "cn=admin,dc=vegasoft,dc=local" -W <<EOF
dn: uid=$username,ou=Users,dc=vegasoft,dc=local
replace: uidNumber
uidNumber: $new_uid

replace: userPassword
userPassword: $new_password
EOF
}

# Menú principal
while true; do
  echo "-----------------------------------"
  echo "           MENÚ PRINCIPAL           "
  echo "-----------------------------------"
  echo "1. Agregar Unidad Organizativa (OU)"
  echo "2. Eliminar Unidad Organizativa (OU)"
  echo "3. Agregar Grupo"
  echo "4. Eliminar Grupo"
  echo "5. Agregar Usuario"
  echo "6. Eliminar Usuario"
  echo "7. Editar Usuario"
  echo "8. Salir"
  echo "-----------------------------------"
  read -p "Ingrese el número de la opción deseada: " opcion

  case $opcion in
    1) agregar_ou ;;
    2) eliminar_ou ;;
    3) agregar_grupo ;;
    4) eliminar_grupo ;;
    5) agregar_usuario ;;
    6) eliminar_usuario ;;
    7) editar_usuario ;;
    8) echo "Saliendo del script."; exit 0 ;;
    *) echo "Opción inválida. Por favor, ingrese un número del 1 al 8." ;;
  esac
done
