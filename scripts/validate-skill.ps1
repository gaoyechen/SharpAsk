[CmdletBinding()]
param(
    [string]$SkillRoot
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($SkillRoot)) {
    $SkillRoot = Split-Path -Parent $PSScriptRoot
}

function Assert-True {
    param(
        [bool]$Condition,
        [string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

$skillRootPath = (Resolve-Path -LiteralPath $SkillRoot).Path
$skillPath = Join-Path $skillRootPath 'SKILL.md'
Assert-True (Test-Path -LiteralPath $skillPath) 'SKILL.md is missing.'

$skill = Get-Content -Raw -Encoding UTF8 $skillPath
$frontmatterMatch = [regex]::Match($skill, '(?s)\A---\r?\n(?<yaml>.*?)\r?\n---\r?\n')
Assert-True $frontmatterMatch.Success 'SKILL.md frontmatter is malformed.'

$frontmatter = $frontmatterMatch.Groups['yaml'].Value
$keys = [regex]::Matches($frontmatter, '(?m)^(?<key>[A-Za-z][A-Za-z0-9_-]*):') |
    ForEach-Object { $_.Groups['key'].Value }
$unexpectedKeys = @($keys | Where-Object { $_ -notin @('name', 'description') })
Assert-True ($unexpectedKeys.Count -eq 0) ("Unexpected frontmatter keys: " + ($unexpectedKeys -join ', '))
Assert-True ($keys -contains 'name') 'Frontmatter is missing name.'
Assert-True ($keys -contains 'description') 'Frontmatter is missing description.'
Assert-True ($frontmatter -match '(?m)^name:\s*sharpinput\s*$') 'Skill name must be sharpinput.'

$openAiPath = Join-Path $skillRootPath 'agents\openai.yaml'
Assert-True (Test-Path -LiteralPath $openAiPath) 'agents/openai.yaml is missing.'
$openAi = Get-Content -Raw -Encoding UTF8 $openAiPath
foreach ($field in @('display_name:', 'short_description:', 'default_prompt:')) {
    Assert-True ($openAi.Contains($field)) "agents/openai.yaml is missing $field"
}
Assert-True ($openAi.Contains('$sharpinput')) 'agents/openai.yaml default_prompt must mention $sharpinput.'

$runtimeMarkdown = @(
    Get-Item -LiteralPath (Join-Path $skillRootPath 'SKILL.md')
    Get-Item -LiteralPath (Join-Path $skillRootPath 'AGENT.md')
    Get-ChildItem -LiteralPath (Join-Path $skillRootPath 'modules') -Filter '*.md' -File
    Get-ChildItem -LiteralPath (Join-Path $skillRootPath 'references') -Filter '*.md' -File
)

foreach ($module in (Get-ChildItem -LiteralPath (Join-Path $skillRootPath 'modules') -Filter '*.md' -File)) {
    $content = Get-Content -Raw -Encoding UTF8 $module.FullName
    Assert-True (-not $content.StartsWith('---')) "Internal module has unnecessary frontmatter: $($module.Name)"
}

$brokenLinks = [System.Collections.Generic.List[string]]::new()
foreach ($file in $runtimeMarkdown) {
    $content = Get-Content -Raw -Encoding UTF8 $file.FullName
    foreach ($match in [regex]::Matches($content, '\[[^\]]+\]\((?<target>[^)]+)\)')) {
        $target = $match.Groups['target'].Value
        if ($target -match '^(https?://|mailto:|#)') {
            continue
        }

        $relativePath = ($target -split '#', 2)[0]
        $resolved = Join-Path $file.DirectoryName $relativePath
        if (-not (Test-Path -LiteralPath $resolved)) {
            $brokenLinks.Add("$($file.FullName): $target")
        }
    }
}
Assert-True ($brokenLinks.Count -eq 0) ("Broken runtime links:`n" + ($brokenLinks -join "`n"))

$runtimeText = ($runtimeMarkdown | ForEach-Object { Get-Content -Raw -Encoding UTF8 $_.FullName }) -join "`n"
foreach ($obsolete in @(
    'prompt-compiler -> pressure-strategy',
    'show its reasoning process',
    'AskUserQuestion',
    'MUST ask',
    'at most 1-3',
    'confidence_score =',
    'target overall >= 7.5',
    'quality score below 6.5'
)) {
    Assert-True (-not $runtimeText.Contains($obsolete)) "Obsolete runtime rule remains: $obsolete"
}

$agent = Get-Content -Raw -Encoding UTF8 (Join-Path $skillRootPath 'AGENT.md')
Assert-True ($agent.Contains('pressure -> compiler')) 'Pressure routes must select pressure before compiler.'

$judgeFiles = @(
    'modules\judge-review.md',
    'references\judge-rubric.md',
    'references\judge-prompt.md'
)
foreach ($relativePath in $judgeFiles) {
    $content = Get-Content -Raw -Encoding UTF8 (Join-Path $skillRootPath $relativePath)
    foreach ($field in @('verdict', 'scores', 'main_problem', 'fix_instruction', 'flip_condition', 'risk_level', 'evidence_status')) {
        Assert-True ($content.Contains($field)) "$relativePath is missing Judge field: $field"
    }
}

$schema = Get-Content -Raw -Encoding UTF8 (Join-Path $skillRootPath 'references\user-preferences.schema.json') | ConvertFrom-Json
$example = Get-Content -Raw -Encoding UTF8 (Join-Path $skillRootPath 'references\user-preferences.example.json') | ConvertFrom-Json
Assert-True ($schema.required -contains 'consent') 'Preference schema must require consent.'
Assert-True ($null -ne $example.consent) 'Preference example must include consent.'
Assert-True ($example.consent.enabled -eq $false) 'Durable preferences must be disabled by default.'

$regressions = Get-Content -Raw -Encoding UTF8 (Join-Path $skillRootPath 'tests\regression-cases.md')
foreach ($id in 1..12) {
    Assert-True ($regressions.Contains("R$id")) "Regression case R$id is missing."
}

Write-Output '[OK] SharpInput static validation passed.'
