Write-Host "pwd: $pwd"
$command = $args -join ' '
$DIRECTORIES = gci -force $pwd\*\* -filter .git | % { $_.Parent.FullName }
$TOTAL_COUNT=$DIRECTORIES.Length

get-date | Write-Host -fore green

foreach ($dir in $DIRECTORIES)
{
  $index = [array]::IndexOf($DIRECTORIES, $dir) + 1
  Write-Host -fore blue ">>>>>>>>>>>>>>>>>>>>> [$index of $TOTAL_COUNT] '$command' (in $dir) <<<<<<<<<<<<<<<<<<<<"
  cd $dir
  iex $command
  cd ..
}

get-date | Write-Host -fore green
