<#
.DESCRIPTION
        #A) El objetivo del script es grabar en un archivo de texto (ingresado por parametro) todos los procesos que hay en ejecucion en ese momento, ademas, muestra por pantalla los primeros 3 procesos de la lista.
        #B) En mi opinion no agregaria otra validacion ya que si el usuario ingresa un archivo no existente se le muestra por pantalla que no existe, lo mismo sucederia si el archivo procesos.txt no existe (en caso de que no se ingresen parametros).
        #C) Si no se ingresan parametros los procesos se guardarian en el archivo "procesos.txt".
.NOTES
        TRABAJO PRÁCTICO 2 - EJERCICIO 2
        PRIMERA ENTREGA 
        INTEGRANTES:
        Parra, Martin                  DNI:40012233
        Di Vito, Tomas                 DNI:39340228
        Fernandez, Matias Gabriel      DNI:38613699
        Mirò, Agustin                  DNI:40923621
        Estevez, Adrian                DNI:39325872
#>

Param (
    [Parameter(Position = 1, Mandatory = $false)]
    [String] $pathsalida = ".\procesos.txt",
    [int] $cantidad = 3
)
$existe = Test-Path $pathsalida
if ( $existe -eq $true){
    $listaproceso = Get-Process
    foreach ($proceso in $listaproceso){
        $proceso | Format-List -Property Id,Name >> $pathsalida
    }
    for ($i = 0; $i -lt $cantidad ; $i++){
        Write-Host $listaproceso[$i].Name - $listaproceso[$i].Id
    }
} else{
    Write-Host "El path no existe"
}