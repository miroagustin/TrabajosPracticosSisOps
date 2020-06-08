<#
.SYNOPSIS
        El script realiza la suma de todos los numeros fraccionarios pasados dentro de un archivo.
.DESCRIPTION
        El script recibe por parametro el archivo y recorre todos los numeros contenidos en el, realizando la suma de los mismos.
		Finalmente, imprime la suma por pantalla y, ademas, la escribe en un archivo de salida llamado salida.out.
.EXAMPLE
        .\ej6_tp2.ps1 Path\archivo
.NOTES
        ej6_tp2.ps1 - TRABAJO PRACTICO 2 - EJERCICIO 6
        TRABAJO PRACTICO 2
        PRIMERA ENTREGA 
        INTEGRANTES:
        Parra, Martin                  DNI:40012233
        Di Vito, Tomas                 DNI:39340228
        Fernandez, Matias Gabriel      DNI:38613699
        Miro, Agustin                  DNI:40923621
        Estevez, Adrian                DNI:39325872
.INPUTS
.OUTPUTS
#>

Param (
    [Parameter(Position = 1, Mandatory = $true)]
    [string]
    $Archivo
)

if(!(Test-Path -Path $Archivo))
{
    echo "No existe el archivo"
    return 
}

Write-Host "Procesando..."

$fracciones = Get-Content -Path $Archivo
#$fracciones = $fracciones -replace ":"," + "
$fracciones = $fracciones -replace ":"," : "
$fracciones = $fracciones -replace ","," + "
$fracciones = $fracciones -replace "-","- "
if($fracciones.Length -eq 0) { Write-Host "El archivo se encuentra vacío."; return }
$arr = $fracciones.Split(' ')

$num1 = 0
$den1 = 1
$signo = "+"
foreach($i in $arr)
{
        $elemento = $i
        if($elemento -ne '+' -And $elemento -ne '-' -And $elemento -ne ':')
        {
                if(!($elemento -match "/")) { $elemento = "$elemento/1" }
                $num2 = $elemento.Substring(0,$elemento.IndexOf("/"))
				$den2 = $elemento.Substring($elemento.IndexOf("/")+1)
                $mcm = ($den1 * $den2)
                $res1 = (($mcm / $den1) * $num1)
                $res2 = (($mcm / $den2) * $num2)
                if($signo -eq '+') { $res3 = $res1 + $res2 } Else { $res3 = $res1 - $res2 }
                $num1 = $res3
                $den1 = $mcm
        }
        if($elemento -eq '+' -Or $elemento -eq '-') { $signo = $elemento }
        if($elemento -eq ':' -And $signo -eq '-') { $signo = '-' }
        if($elemento -eq ':' -And $signo -eq '+') { $signo = '+' }
}

$numerador = $num1
$denominador = $den1
if($num1 -lt 0) { $signo = "-" } Else { $signo = "+" }
if($num1 -gt $den1) { $dividendo = $num1 -replace '-',''; $divisor = $den1; } Else { $dividendo = $den1; $divisor = $num1 -replace '-',''; }

$resto = ($dividendo % $divisor)
while($resto -gt 0) { $resto = ($dividendo % $divisor); if($resto -eq 0) { break }; $dividendo = $divisor; $divisor = $resto; }
$MCD = $divisor

$numerador = ($numerador / $MCD)
$denominador = ($denominador / $MCD)

Set-Content -Path .\salida.out -Value ("Resultado de la suma recibida del archivo $Archivo" + $2 + ": " + ${numerador} + "/" + ${denominador})
Write-Host $numerador"/"$denominador
