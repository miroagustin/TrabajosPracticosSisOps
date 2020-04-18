if [[ $1 == "-h" || $1 == "-?" || $1 == "--help" ]]
then
  echo "
  Ejercicio 5 Trabajo Practico 1
  Autor: Grupo 4

  Se procesa un archivo pasado por parametro como:
  -f nombre_del_archivo

  y se generara un archivo resultado con la siguiente informacion:

  - Cantidad de alumnos aptos para rendir final (sin final dado y notas en
  parciales/recuperatorio entre 4 y 6 inclusive).
  
  - Cantidad de alumnos que recursarán (notas menor a 4 en final o en parciales y/o
  recuperatorio).
  
  - Cantidad de alumnos con posibilidad de rendir recuperatorio (sin recuperatorio rendido y
  al menos una nota de parcial menor a 7).
  
  - Cantidad de alumnos que abandonaron la materia (sin nota en al menos un parcial y sin
  recuperatorio rendido para dicho parcial). 
  "
  exit 0
fi
if [[ $# != 2 ]]
then
  echo "Estan mal los parametros. Revise la ayuda con -h, --help o -?"
  exit 1;
fi
if [[ $1 != "-f" ]]
then
  echo "El primer parametro debe ser -f para indicar que lo que sigue es el arhivo"
  exit 2;
fi
if ! test -e $2 && ! test -d $2;
then
  echo "El path no existe o no es un directorio"
  exit 3
fi

archivo_entrada=$2
 
awk '
  BEGIN { FS = "||"; NR>1; printf("HEADER\n") }
  {
    
    materias[$2]=[]
  }
  END {
    printf("Materia %s\n", id_materia)
  }
' $archivo_entrada > salida.out


