#!/bin/bash
#TP1 - Ejercicio 1 - Primera Entrega
#Integrantes:
#Parra, Martin                  DNI:40012233
#Di Vito, Tomas                 DNI:39340228
#Fernandez, Matias Gabriel      DNI:38613699
#Mirò, Agustin                  DNI:40923621
#Estevez, Adrian                DNI:39325872
ErrorS()
{
    echo "Error La Sintaxis del script es la siguiente: "
    echo "Cantidad de lineas: $0 nombre_archivo L"
    echo "Cantidad de caracteres: $0 nombre_archivo C"
    echo "Longitud de la linea mas larga: $0 nombre_archivo M"
}

ErrorP()
{
    echo "Error. nombre_archivo , faltan permisos" 
}
if test $# -lt 2; then # Si la cantidad de parametros es menor a 2 envia error 
    ErrorS
    exit
fi
if ! test -r $1; then #Comprueba que el archivo exista y se tengan permisos de lectura y si no se informa por pantalla.
    ErrorP
exit
elif test -f $1 && (test $2 = "L" || test $2 = "C" || test $2 = "M"); then
    if test $2 = "L"; then #Si el parametro fue "L", contara la cantidad de lineas del archivo (-l)
        res=`wc -l $1`
        echo "Cantidad de lineas: $res"
    elif test $2 = "C"; then #Si el parametro fue "C", cuenta la cantidad de caracteres (incluidos \n) (-m)
        res=`wc -m $1`
        echo "Cantidad de caracteres: $res" 
    elif test $2 = "M"; then # Si el parametro fue "M", muestra la longitud de la linea mas larga del archivo (-L)
        res=`wc -L $1`
        echo "Longitud de la linea mas larga: $res" 
    fi
else
    ErrorS
fi

# a) ¿Cuál es el objetivo de este script?
# El objetivo es tomar un archivo y dependiendo el parametro que reciba hacer un calculo diferente

# b) ¿Qué parámetros recibe?
# Como parametro recibe el archivo y el parametro para hacer los calculos (M-C-L)

# c) Comentar el código según la funcionalidad (no describa los comandos, indique la lógica)

# d) Completar los echos con los mensajes correspondientes

# e) ¿Que informacion brinda la variable "$#"?¿Que otras variables similares conocen? Expliquenlas
# "$#" brinda el número total de argumentos pasados al script actual.
# Otras variables similares son: 
# "$-": la lista de opciones de la shell actual.
# "$1", "$2", "$3", ...: parámetros de posición que hacen referencia al primer, segundo, tercer, etc. parámetro pasado al script.
# "$@":  la lista completa de argumentos pasados al script.

# f) Explique las diferencias entre los distintos tipos de comillas que se pueden utilizar en Shell scripts.
# Comillas Dobles ("): Se utilizan para definir textos y "se expanden". Es decir, las variables dentro de las comillas dobles son interpretadas (y no se muestran como el nombre de la variable).
# Comillas Simples ('): Se utilizan para definir textos y "no se expanden". Es decir, las variables dentro de las comillas simples se muestran como el nombre de la variable (y no se muestran como su valor).
# Acento Grave (`): Se utilizan para indicar a bash que interprete el comando que hay entre los acentos
