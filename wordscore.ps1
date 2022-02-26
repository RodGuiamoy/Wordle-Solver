cls
. "$PSSCriptRoot\wordle.ps1"

$wordscore = @()
for ($i = 0; $i -lt $global:words.Length; $i++) {
    $guess = $global:words[$i]
    Write-Host $guess -NoNewline
    $score = 0
    for ($j = 0; $j -lt $global:words.Length; $j++) {
        $answer = $global:words[$j]
        #Write-Host " $answer" -NoNewline
        $guessResult = Check-Guess $guess

        #Write-Host $guessResult
        $score += $($guessResult | Measure-Object -Property Hint -Sum).Sum
    }

    $wordScore += [PSCustomObject]@{
        Word  = $guess
        Score = $score
    }
    # += $obj
    #Write-Host $obj
    #Read-Host
}

$wordScore | Export-CSV "$PSScriptRoot\wordScore.csv"