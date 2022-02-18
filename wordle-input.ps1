cls
$global:excludedLetters = @()
$global:includedLetters = @()
$global:correctLetters = @()
$global:words = Get-Content "$PSScriptRoot\wordle.txt"

$rnd = Get-Random -Minimum 0 -Maximum $($global:words.Count - 1)
$answer = $global:words[$rnd]

Function Get-Guess {
    param (
        $excludeRegex,
        $includeRegex,
        $answerRegex
    )
    #Write-Host $global:words.Length
    
    $exclusiveWords = @()
    foreach ($word in $global:words) {
        If ($word -match $excludeRegex) {
            $exclusiveWords += $word
        }
    }

    #Write-Host $exclusiveWords.Length
    $inclusiveWords = @()
    foreach ($word in $exclusiveWords) {
        If ($word -match $includeRegex) {
            $inclusiveWords += $word
        }
    }

    #Write-Host $inclusiveWords.Length
    $answerWords = @()
    foreach ($word in $inclusiveWords) {
        If ($word -match $answerRegex) {
            $answerWords += $word
        }
    }
    #Write-Host $answerWords.Length
    if ($answerWords.Length -gt 1) {
        $rnd = Get-Random -Minimum 0 -Maximum $($answerWords.Length - 1)
    }
    else{
        $rnd = 0
    }
    
    $global:words = $answerWords | Where {$_ -notcontains $answerWords[$rnd]}

    return $answerWords[$rnd]
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
    for ($j = 0; $j -lt $answer.Length; $j++) {
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
        $excludeRegex = "[^$($e -join '')]{5}"
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
    
    $global:includedLetters += $guessResult | Where Hint -eq 1 | Select Letter
    
    #Write-Host "`n"

    $i = $($global:includedLetters.Letter | Sort-Object | Get-Unique)

    #Write-Host "Included: $($i -join '')"
    $includeRegex = "\b"
    if ($i.Length -gt 0) {
        for ($j = 0; $j -lt $i.Length; $j++) {
            $includeRegex += "(?=\w*$($i[$j]))"
        }
        $includeRegex += "\w+"
    }
    else {
        $includeRegex = '.'
    }

    #Write-Host $includeRegex

    return $includeRegex
}

$excludeRegex = '.'
$includeRegex = '.'
$answerRegex = '.'

#Write-Host $guess
while ($guess -ne $answer) {
    #$regex
    $guess = Read-Host "Enter guess" 
    $guessResult = @()

    If (!$guess) {
        If ($guesses -eq 1) {
            $rnd = Get-Random -Minimum 0 -Maximum $($global:words.Length - 1)
            $guess = $global:words[$rnd]
        }
        Else {
            $guess = Get-Guess -ExcludeRegex $excludeRegex -IncludeRegex $includeRegex -AnswerRegex $answerRegex
        }

    }

    Write-Host "Guess: $guess"

    $manualResult = Read-Host "Enter result"
    for ($i = 0; $i -lt $manualResult.Length; $i++) {
        $guessResult += [PSCustomObject]@{
            Letter = $guess[$i]
            Hint = [System.Int32]::Parse($manualResult[$i])
            Placement = $i
        }
    }

    #Write-Host $guessResult

    $excludeRegex = Create-ExcludeRegex -GuessResult $guessResult
    $includeRegex = Create-IncludeRegex -GuessResult $guessResult
    $answerRegex = Create-AnswerRegex -GuessResult $guessResult

    
    "`n"
}