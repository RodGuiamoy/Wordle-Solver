cls
. "$PSSCriptRoot\wordle.ps1"

$rnd = Get-Random -Minimum 0 -Maximum $($global:words.Count - 1)
$answer = $global:words[$rnd]
Write-Host "Answer: $answer"

$guesses = 1
while ($guess -ne $answer) {
    #$regex
    If ($guesses -eq 1) {
        $rnd = Get-Random -Minimum 0 -Maximum $($global:words.Count - 1)
        $guess = $global:words[$rnd]
    }
    Else {
        $guess = Get-Guess -ExcludeRegex $excludeRegex -IncludeRegex $includeRegex -IncludeRegex2 $includeRegex2 -AnswerRegex $answerRegex
    }

    #Write-Host "Guesses: $guesses"
    #Write-Host "Answer: $answer"
    #Write-Host "Guess: $guess"
    
    $guesses++

    $guessResult = Check-Guess -Guess $guess

    #Write-Host $guessResult

    $excludeRegex = Create-ExcludeRegex -GuessResult $guessResult
    $includeRegex = Create-IncludeRegex -GuessResult $guessResult
    $includeRegex2 = Create-IncludeRegex2 -GuessResult $guessResult
    $answerRegex = Create-AnswerRegex -GuessResult $guessResult

    
    "`n"
    # Read-Host
}