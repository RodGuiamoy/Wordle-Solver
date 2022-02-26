cls
$global:excludedLetters = @()
$global:includedLetters = @()
$global:correctLetters = @()
$global:words = Import-CSV "$PSScriptRoot\wordScore.csv"
$global:wordLength = 5

Function Get-Guess {
    param (
        $excludeRegex,
        $includeRegex,
        $includeRegex2,
        $answerRegex
    )
    
    #Write-Host $global:words.Length

    $exclusiveWords = @()
    foreach ($word in $global:words) {
        If ($word.Word -match $excludeRegex) {
            $exclusiveWords += $word
        }
    }
    #Write-Host $excludeRegex
    #Write-Host $exclusiveWords.Length

    $inclusiveWords = @()
    foreach ($word in $exclusiveWords) {
        If ($word.Word -match $includeRegex) {
            $inclusiveWords += $word
        }
    }
    #Write-Host $includeRegex
    #Write-Host $inclusiveWords.Length
    
    $inclusiveWords2 = @()
    foreach ($word in $inclusiveWords) {
        If ($word.Word -match $includeRegex2) {
            $inclusiveWords2 += $word
        }
    }
    #Write-Host $includeRegex2
    #Write-Host $inclusiveWords2.Length


    $answerWords = @()
    foreach ($word in $inclusiveWords2) {
        If ($word.Word -match $answerRegex) {
            $answerWords += $word
        }
    }
    #Write-Host $answerRegex
    #Write-Host $answerWords.Length


    # if ($answerWords.Length -gt 1) {
    #     $rnd = Get-Random -Minimum 0 -Maximum $($answerWords.Length - 1)
    # }
    # else {
    #     $rnd = 0
    # }
    
    $global:words = $answerWords

    #$guess = $($answerWords | Sort-Object -Property Score -Descending)[0]
    $guess = $answerWords[0]
    Write-Host $guess
    return $guess.Word
}

Function Check-Guess {
    param (
        $guess
    )

    $guessResult = @()

    # guess
    :outer for ($i = 0; $i -lt $guess.Length; $i++) {
        # answer
        $hint = 0
        $color = 'Red'
        for ($j = 0; $j -lt $global:wordLength; $j++) {
            if ($guess[$i] -eq $answer[$j]) {
                if ($i -eq $j) {
                    Write-Host "$($guess[$i])" -ForegroundColor Green -NoNewline
                    $hint = 2

                    $guessResult += [PSCustomObject]@{
                        Letter    = $guess[$i]
                        Placement = $i
                        Hint      = $hint
                    }
                    continue outer
                }
                else {
                    #Write-Host "$($guess[$i])" -ForegroundColor Yellow -NoNewline
                    $hint = 1
                    $color = 'Yellow'
                }
            }
        }
        Write-Host $guess[$i] -ForegroundColor $color -NoNewline
        $guessResult += [PSCustomObject]@{
            Letter    = $guess[$i]
            Placement = $i
            Hint      = $hint
        }
    }
    "`n"

    #Write-Host $guessResult
    return $guessResult

}

Function Create-AnswerRegex {
    param (
        $guessResult
    )

    $global:correctLetters += $guessResult | Where Hint -eq 2 | Select Letter, Placement
    
    #Write-Host "`n"

    $c = $global:correctLetters
    #Write-Host "Correct: $($($($($c | Sort-Object Placement).Letter) | Get-Unique) -join '')"

    $answerRegex = ""
    for ($j = 0; $j -lt $global:wordLength; $j++) {
        $correct = $c | Where-Object Placement -eq $j | Select * -First 1
        if ( $correct ) {
            $answerRegex += "$($correct.Letter)"
            continue
        }

        $answerRegex += "."
    }

    #Write-Host $answerRegex
    return $answerRegex
}

Function Create-ExcludeRegex {
    param (
        $guessResult
    )

    $global:excludedLetters += $guessResult | Where Hint -eq 0 | Select Letter
    
    #Write-Host "`n"

    $e = $($global:excludedLetters.Letter | Sort-Object | Get-Unique)

    #Write-Host "Excluded: $($e -join '')"

    if ($e) {
        $excludeRegex = "[^$($e -join '')]{$global:wordLength}"
    }
    else {
        $excludeRegex = '.'
    }

    #Write-Host $excludeRegex
    return $excludeRegex
}

Function Create-IncludeRegex {
    param (
        $guessResult
    )
    
    $global:includedLetters += $guessResult | Where Hint -eq 1 | Select Letter, Placement
    
    #Write-Host "`n"

    $i = $global:includedLetters
    #Write-Host $i 

    #Write-Host "Included: $($i -join '')"
    $includeRegex = ""
    for ($j = 0; $j -lt $answer.Length; $j++) {
        $included = $i | Where-Object Placement -eq $j | Select *
        if ($included) {
            $includeRegex += "[^"
            foreach ($k in $included) {
                $includeRegex += "$($k.Letter)"
            }
            $includeRegex += "]"
            continue
        }

        $includeRegex += "."
    }

    #Write-Host $includeRegex   
    return $includeRegex
}

Function Create-IncludeRegex2 {
    param (
        $guessResult
    )
    
    $global:includedLetters += $guessResult | Where Hint -eq 1 | Select Letter
    
    #Write-Host "`n"

    $i2 = $($global:includedLetters.Letter | Sort-Object | Get-Unique)

    #Write-Host "Included: $($i2 -join '')"
    $includeRegex2 = "\b"
    if ($i2.Length -gt 0) {
        for ($j = 0; $j -lt $i2.Length; $j++) {
            $includeRegex2 += "(?=\w*$($i2[$j]))"
        }
        $includeRegex2 += "\w+"
    }
    else {
        $includeRegex2 = '.....'
    }

    #Write-Host $includeRegex2
    return $includeRegex2
}