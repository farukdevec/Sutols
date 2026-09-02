[CmdletBinding()]
param(
  [Parameter(Position = 0)]
  [ValidateSet('Save', 'Compile', 'Status')]
  [string]$Action = 'Status',
  [string]$Title = 'Atlas session',
  [string]$Summary = ''
)

$ErrorActionPreference = 'Stop'
$Vault = Split-Path -Parent $PSScriptRoot
$Today = Get-Date -Format 'yyyy-MM-dd'
$DailyPath = Join-Path $Vault ('daily\' + $Today + '.md')
$IndexPath = Join-Path $Vault 'knowledge\index.md'

function Add-SessionLog {
  param([string]$LogTitle, [string]$LogSummary)

  if (-not (Test-Path -LiteralPath $DailyPath)) {
    Set-Content -LiteralPath $DailyPath -Encoding utf8 -Value (@(
      ('# Günlük Log: ' + $Today),
      '',
      '## Oturumlar'
    ) -join [Environment]::NewLine)
  } elseif (-not ((Get-Content -LiteralPath $DailyPath -Raw -Encoding utf8) -match '^# Günlük Log:[^\r\n]+\r?\n\r?\n## Oturumlar')) {
    $legacy = Get-Content -LiteralPath $DailyPath -Raw -Encoding utf8
    Set-Content -LiteralPath $DailyPath -Encoding utf8 -Value (@(
      ('# Günlük Log: ' + $Today),
      '',
      '## Oturumlar',
      '',
      '### Oturum (Geçmiş)',
      '',
      $legacy.Trim()
    ) -join [Environment]::NewLine)
  }
  $time = Get-Date -Format 'HH:mm'
  $safeSummary = if ([string]::IsNullOrWhiteSpace($LogSummary)) {
    'Summary pending: update the related node and Last Session.'
  } else { $LogSummary.Trim() }
  $block = [Environment]::NewLine + '### Oturum (' + $time + ') — ' + $LogTitle +
    [Environment]::NewLine + [Environment]::NewLine + $safeSummary + [Environment]::NewLine
  Add-Content -LiteralPath $DailyPath -Encoding utf8 -Value $block
  Write-Output ('Daily log saved: ' + $DailyPath)
}

function Update-KnowledgeIndex {
  $nodes = Get-ChildItem -LiteralPath (Join-Path $Vault 'nodes') -Filter '*.md' -File |
    Sort-Object Name
  $rows = foreach ($node in $nodes) {
    $firstHeading = Get-Content -LiteralPath $node.FullName -Encoding utf8 |
      Where-Object { $_ -match '^# ' } | Select-Object -First 1
    $title = if ($firstHeading) { $firstHeading.Substring(2).Trim() } else { $node.BaseName }
    ('| ' + $title + ' | [[nodes/' + $node.BaseName + ']] | ' + $Today + ' |')
  }
  $content = @(
    '# Knowledge Index',
    '',
    '| Title | Source node | Updated |',
    '| --- | --- | --- |'
  ) + $rows
  Set-Content -LiteralPath $IndexPath -Encoding utf8 -Value $content
  Write-Output ('Index compiled: ' + $IndexPath)
}

switch ($Action) {
  'Save' { Add-SessionLog -LogTitle $Title -LogSummary $Summary }
  'Compile' { Update-KnowledgeIndex }
  'Status' {
    $required = @('AGENTS.md', 'Atlas.md', 'memory\Last-Session.md', 'knowledge\index.md', 'Atlas.html')
    $required | ForEach-Object {
      $exists = Test-Path -LiteralPath (Join-Path $Vault $_)
      Write-Output (('{0} {1}' -f $(if ($exists) { 'OK' } else { 'MISSING' }), $_))
    }
  }
}
