#TP1 - Ejercicio 4 - Primera Entrega
#Integrantes:
#Parra, Martin                  DNI:40012233
#Di Vito, Tomas                 DNI:39340228
#Fernandez, Matias Gabriel      DNI:38613699
#Mirò, Agustin                  DNI:40923621
#Estevez, Adrian                DNI:39325872
if [[ $1 == "-h" || $1 == "-?" || $1 == "--help" ]]
then
  echo "
  Ejercicio 5 Trabajo Practico 1
  Autor: Grupo 4

  Se procesa un archivo pasado por parametro como:
  -f nombre_del_archivo (ejemplo ' ./tp1_ej5.sh -f entradas/entrada_1.txt ')
  
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
  BEGIN {
    FS = "|";
    printf("\"Materia\",\"Final\",\"Recursan\",\"Recuperan\",\"Abandonaron\"\n");
  }
  NR>1 {
    materia = $2

    nota_primer_parcial = $3+0;
    nota_segundo_parcial = $4+0;
    nota_recuperatorio = $5+0;
    nota_final = $6+0;

    if (nota_final > 0) {
      if (nota_final < 4) {
        materias[materia][1]++
      }
    } else {
      if (nota_recuperatorio > 0) {
        if (nota_recuperatorio < 4) {
          materias[materia][1]++
        } else if (nota_recuperatorio >= 4 || nota_recuperatorio <= 6) {
          materias[materia][0]++
        } else {
          if (nota_primer_parcial < 7 && nota_segundo_parcial < 7) {
            materias[materia][0]++
          }
        }
      } else {
        if (nota_primer_parcial == 0 || nota_segundo_parcial == 0) {
          materias[materia][3]++
        } else if (nota_primer_parcial < 4 && nota_segundo_parcial < 4) {
          materias[materia][1]++
        } else if (nota_primer_parcial < 4 && nota_segundo_parcial >= 4) {
          materias[materia][2]++
        } else if (nota_segundo_parcial < 4 && nota_primer_parcial >= 4) {
          materias[materia][2]++
        } else if (nota_primer_parcial <= 6 && nota_segundo_parcial > 7) {
          materias[materia][2]++
        } else if (nota_segundo_parcial <= 6 && nota_primer_parcial > 7) {
          materias[materia][2]++
        } else if (nota_primer_parcial <= 6 && nota_segundo_parcial >= 4) {
          materias[materia][0]++
        } else if (nota_segundo_parcial <= 6 && nota_primer_parcial >= 4) {
          materias[materia][0]++
        }
      }
    }
  }
  END {
    for (materia in materias) {
      printf("\"%d\",\"%d\",\"%d\",\"%d\",\"%d\"\n", materia, materias[materia][0], materias[materia][1], materias[materia][2], materias[materia][3]);
    }
  }
' $archivo_entrada > salida.out


