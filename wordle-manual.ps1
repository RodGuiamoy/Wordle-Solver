cls

. "$PSSCriptRoot\wordle.ps1"
$rnd = Get-Random -Minimum 0 -Maximum $($global:words.Count - 1)
#$answer = $global:words[$rnd]

$excludeRegex = "."
$includeRegex = "."
$includeRegex2 = "."
$answerRegex = "."
#Write-Host $guess
while (1) {
    #$regex
    $guess = Read-Host "Enter guess" 
    $guessResult = @()

    If (!$guess) {
        If ($guesses -eq 1) {
            $rnd = Get-Random -Minimum 0 -Maximum $($global:words.Length - 1)
            $guess = $($global:words[0]).Word
        }
        Else {
            $guess = Get-Guess -ExcludeRegex $excludeRegex -IncludeRegex $includeRegex -IncludeRegex2 $includeRegex2 -AnswerRegex $answerRegex
        }

    }

    Write-Host "Guess: $guess"

    $manualResult = Read-Host "Enter result"
    for ($i = 0; $i -lt $manualResult.Length; $i++) {
        $guessResult += [PSCustomObject]@{
            Letter    = $guess[$i]
            Placement = [System.Int32]::Parse($i)
            #Placement = $i
            Hint      = [System.Int32]::Parse($manualResult[$i])
            #Hint      = $manualResult[$i]
        }
    }

    Write-Host $guessResult

    $excludeRegex = Create-ExcludeRegex -GuessResult $guessResult
    $includeRegex = Create-IncludeRegex -GuessResult $guessResult
    $includeRegex2 = Create-IncludeRegex2 -GuessResult $guessResult
    $answerRegex = Create-AnswerRegex -GuessResult $guessResult

    
    "`n"
}