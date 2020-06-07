<#
  .SYNOPSIS
    Script hecho por el grupo 4 en Powershell
  .INPUTS
    -Nomina el path de la nomina.
  .DESCRIPTION
    Ejercicio 5 Trabajo Practico 1
    Autor: Grupo 4
  .EXAMPLE
  pwsh ejercicio5pwsh.ps1 -Nomina ./entradas/entrada_1
  .FUNCTIONALITY
  En base al archivo de entrada se generara un archivo resultado con la siguiente informacion:

  - Cantidad de alumnos aptos para rendir final (sin final dado y notas en
  parciales/recuperatorio entre 4 y 6 inclusive).
  
  - Cantidad de alumnos que recursarán (notas menor a 4 en final o en parciales y/o
  recuperatorio).
  
  - Cantidad de alumnos con posibilidad de rendir recuperatorio (sin recuperatorio rendido y
  al menos una nota de parcial menor a 7).
  
  - Cantidad de alumnos que abandonaron la materia (sin nota en al menos un parcial y sin
  recuperatorio rendido para dicho parcial). 
#>


Param(
  [Parameter(Mandatory=$True, Position=1)] [string]$Nomina
)

Begin {
  $csv = Import-Csv -Path $Nomina -Delimiter '|'
  $materias = @{}
}
Process {
  foreach ($nom in $csv)
  {
    if (!$materias.ContainsKey($nom.IdMateria)) {
      $materias[$nom.IdMateria] = [PSCustomObject]@{
        Materia = $nom.IdMateria
        Final = 0
        Recursan = 0
        Recuperan = 0
        Abandonaron = 0
      }
    }

    $Final = [int]$nom.Final
    $Recuperatorio = [int]$nom.RecuParcial
    $PrimerParcial = [int]$nom.PrimerParcial
    $SegundoParcial = [int]$nom.SegundoParcial

    if ($Final -gt 0) {
      if ($Final -lt 4) {
        $materias[$nom.IdMateria].Recursan++
      }
    } else {
      if ($Recuperatorio -gt 0) {
        if ($Recuperatorio -lt 4) {
          $materias[$nom.IdMateria].Recursan++
        } elseif ($Recuperatorio -ge 4 -or $Recuperatorio -le 6) {
          $materias[$nom.IdMateria].Final++
        } else {
          if ($PrimerParcial -lt 7 -and $SegundoParcial -lt 7) {
            $materias[$nom.IdMateria].Final++
          }
        }
      } else {
        if ($PrimerParcial -eq 0 -or $SegundoParcial -eq 0) {
          $materias[$nom.IdMateria].Abandonaron++
        } elseif ($PrimerParcial -lt 4 -and $SegundoParcial -lt 4) {
          $materias[$nom.IdMateria].Recursan++
        } elseif ($PrimerParcial -lt 4 -and $SegundoParcial -ge 4) {
          $materias[$nom.IdMateria].Recuperan++
        } elseif ($SegundoParcial -lt 4 -and $PrimerParcial -ge 4) {
          $materias[$nom.IdMateria].Recuperan++
        } elseif ($PrimerParcial -le 6 -and $SegundoParcial -ge 7) {
          $materias[$nom.IdMateria].Recuperan++
        } elseif ($SegundoParcial -le 6 -and $PrimerParcial -ge 7) {
          $materias[$nom.IdMateria].Recuperan++
        } elseif ($PrimerParcial -le 6 -and $SegundoParcial -ge 4) {
          $materias[$nom.IdMateria].Final++
        } elseif ($SegundoParcial -le 6 -and $PrimerParcial -ge 4) {
          $materias[$nom.IdMateria].Final++
        }
      }
    }
  }
}
End {
  $materias.Values.GetEnumerator() | Export-Csv -Path "salida.out" 
}