$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$artifactRoot = Join-Path $repoRoot 'rest api\setMode'
$bundlePath = Join-Path $repoRoot 'docs\rest_artifacts.json'
$commandSchemaPath = Join-Path $repoRoot 'schemas\commands\gen2x\set_mode.json'
$operationDescriptionPath = Join-Path $repoRoot 'schemas\operation_descriptions\set_mode.md'
$openApiPath = Join-Path $repoRoot 'docs\openapi_md.json'
$utf8WithoutBom = New-Object System.Text.UTF8Encoding($false)

function Read-JsonText([string]$path) {
    $text = [IO.File]::ReadAllText($path)
    $null = $text | ConvertFrom-Json
    return $text.Trim()
}

function Format-Property([string]$name, [string]$json, [bool]$appendComma) {
    $lines = $json -split '\r?\n'
    $formatted = New-Object System.Collections.Generic.List[string]
    $formatted.Add(('    "{0}": {1}' -f $name, $lines[0]))
    for ($index = 1; $index -lt $lines.Count; $index++) {
        $formatted.Add('    ' + $lines[$index])
    }
    if ($appendComma) {
        $formatted[$formatted.Count - 1] += ','
    }
    return $formatted
}

function Format-PropertyAt([string]$name, [string]$json, [int]$indent, [bool]$appendComma) {
    $padding = ' ' * $indent
    $lines = $json -split '\r?\n'
    $formatted = New-Object System.Collections.Generic.List[string]
    $formatted.Add(('{0}"{1}": {2}' -f $padding, $name, $lines[0]))
    for ($index = 1; $index -lt $lines.Count; $index++) {
        $formatted.Add($padding + $lines[$index])
    }
    if ($appendComma) {
        $formatted[$formatted.Count - 1] += ','
    }
    return $formatted
}

function Expand-JsonIndent([string]$json) {
    $expanded = foreach ($line in ($json -split '\r?\n')) {
        $match = [regex]::Match($line, '^( *)')
        (' ' * ($match.Groups[1].Value.Length * 2)) + $line.TrimStart(' ')
    }
    return $expanded -join "`r`n"
}

function Add-BaseIndent([string]$json, [string]$baseIndent) {
    $lines = $json -split '\r?\n'
    $result = New-Object System.Collections.Generic.List[string]
    $result.Add($lines[0])
    for ($index = 1; $index -lt $lines.Count; $index++) {
        $result.Add($baseIndent + $lines[$index])
    }
    return $result -join "`r`n"
}

function Find-MatchingBrace([string]$text, [int]$startIndex) {
    $depth = 0
    $insideString = $false
    $escaped = $false
    for ($index = $startIndex; $index -lt $text.Length; $index++) {
        $character = $text[$index]
        if ($insideString) {
            if ($escaped) {
                $escaped = $false
            } elseif ($character -eq '\') {
                $escaped = $true
            } elseif ($character -eq '"') {
                $insideString = $false
            }
            continue
        }
        if ($character -eq '"') {
            $insideString = $true
        } elseif ($character -eq '{') {
            $depth++
        } elseif ($character -eq '}') {
            $depth--
            if ($depth -eq 0) {
                return $index
            }
        }
    }
    throw 'Could not find the matching JSON object brace.'
}

$requestExample = Read-JsonText (Join-Path $artifactRoot 'setMode_request_example.json')
$requestSchema = Read-JsonText (Join-Path $artifactRoot 'setMode_request_schema.json')
$responseExample = Read-JsonText (Join-Path $artifactRoot 'setMode_response_example.json')
$responseSchema = Read-JsonText (Join-Path $artifactRoot 'setMode_response_schema.json')

$entry = New-Object System.Collections.Generic.List[string]
$entry.Add('  "setMode": {')
$entry.AddRange([string[]](Format-Property 'request_example' $requestExample $true))
$entry.Add('    "request_examples": null,')
$entry.AddRange([string[]](Format-Property 'request_schema' $requestSchema $true))
$entry.AddRange([string[]](Format-Property 'response_example' $responseExample $true))
$entry.AddRange([string[]](Format-Property 'response_schema' $responseSchema $false))
$entry.Add('  },')
$entry.Add('  "start": {')
$replacement = $entry -join "`r`n"

$bundle = [IO.File]::ReadAllText($bundlePath)
$pattern = '(?ms)^  "setMode": \{.*?^  "start": \{'
$matches = [regex]::Matches($bundle, $pattern)
if ($matches.Count -ne 1) {
    throw "Expected one setMode bundle entry, found $($matches.Count)."
}

$updated = [regex]::Replace($bundle, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($match) $replacement }, 1)
[IO.File]::WriteAllText($bundlePath, $updated, $utf8WithoutBom)

$requestSchemaFourSpace = Expand-JsonIndent $requestSchema

$command = New-Object System.Collections.Generic.List[string]
$command.Add('{')
$command.Add('    "title": "set_mode",')
$command.Add('    "x-summary": "Set Radio Performance",')
$command.Add('    "description": "Sets the inventory protocol used during tag inventory.",')
$command.Add('    "x-tag": "Radio Performance",')
$command.Add('    "type": "object",')
$command.Add('    "required": [')
$command.Add('        "command",')
$command.Add('        "command_id",')
$command.Add('        "payload"')
$command.Add('    ],')
$command.Add('    "properties": {')
$command.Add('        "command": {')
$command.Add('            "type": "string",')
$command.Add('            "const": "set_mode",')
$command.Add('            "description": "MQTT command name"')
$command.Add('        },')
$command.Add('        "command_id": {')
$command.Add('            "type": "string",')
$command.Add('            "description": "Unique identifier to correlate request with response"')
$command.Add('        },')
$command.AddRange([string[]](Format-PropertyAt 'payload' $requestSchemaFourSpace 8 $false))
$command.Add('    },')
$command.Add('    "examples": [')
$command.Add('        {')
$command.Add('            "command": "set_mode",')
$command.Add('            "command_id": "7d4f76a1-12c8-4f0a-965e-b3c5b268cf21",')
$command.Add('            "payload": {')
$command.Add('                "type": "CUSTOM",')
$command.Add('                "antennas": [1],')
$command.Add('                "transmitPower": 30,')
$command.Add('                "inventoryProtocol": {')
$command.Add('                    "mode": "GEN2X"')
$command.Add('                }')
$command.Add('            }')
$command.Add('        }')
$command.Add('    ]')
$command.Add('}')
[IO.File]::WriteAllText($commandSchemaPath, ($command -join "`r`n") + "`r`n", $utf8WithoutBom)

$publishedSchema = New-Object System.Collections.Generic.List[string]
$publishedSchema.Add('{')
$publishedSchema.Add('    "x-summary": "Set Radio Performance",')
$publishedSchema.Add('    "type": "object",')
$publishedSchema.Add('    "required": [')
$publishedSchema.Add('        "command",')
$publishedSchema.Add('        "command_id",')
$publishedSchema.Add('        "payload"')
$publishedSchema.Add('    ],')
$publishedSchema.Add('    "properties": {')
$publishedSchema.Add('        "command": {')
$publishedSchema.Add('            "type": "string",')
$publishedSchema.Add('            "description": "MQTT command name",')
$publishedSchema.Add('            "enum": [')
$publishedSchema.Add('                "set_mode"')
$publishedSchema.Add('            ]')
$publishedSchema.Add('        },')
$publishedSchema.Add('        "command_id": {')
$publishedSchema.Add('            "type": "string",')
$publishedSchema.Add('            "description": "Unique identifier to correlate request with response"')
$publishedSchema.Add('        },')
$publishedSchema.AddRange([string[]](Format-PropertyAt 'payload' $requestSchemaFourSpace 8 $false))
$publishedSchema.Add('    }')
$publishedSchema.Add('}')
$publishedSchemaText = $publishedSchema -join "`r`n"

$openApi = [IO.File]::ReadAllText($openApiPath)
$operationIndex = $openApi.IndexOf('"/set_mode"')
if ($operationIndex -lt 0) {
    throw 'Could not find /set_mode in docs/openapi_md.json.'
}
$requestBodyIndex = $openApi.IndexOf('"requestBody"', $operationIndex)
$schemaKeyIndex = $openApi.IndexOf('"schema"', $requestBodyIndex)
$schemaBraceIndex = $openApi.IndexOf('{', $schemaKeyIndex)
$schemaEndIndex = Find-MatchingBrace $openApi $schemaBraceIndex
$lineStartIndex = $openApi.LastIndexOf("`n", $schemaBraceIndex) + 1
$schemaLinePrefix = $openApi.Substring($lineStartIndex, $schemaBraceIndex - $lineStartIndex)
$baseIndent = [regex]::Match($schemaLinePrefix, '^\s*').Value
$publishedReplacement = Add-BaseIndent $publishedSchemaText $baseIndent
$openApiUpdated = $openApi.Substring(0, $schemaBraceIndex) + $publishedReplacement + $openApi.Substring($schemaEndIndex + 1)

$operationIndex = $openApiUpdated.IndexOf('"/set_mode"')
$nextOperationIndex = $openApiUpdated.IndexOf('        "/', $operationIndex + 1)
if ($nextOperationIndex -lt 0) {
    $nextOperationIndex = $openApiUpdated.Length
}
$operationText = $openApiUpdated.Substring($operationIndex, $nextOperationIndex - $operationIndex)
$descriptionPattern = '(?m)^                "description": ".*",$'
$descriptionMatches = [regex]::Matches($operationText, $descriptionPattern)
if ($descriptionMatches.Count -ne 1) {
    throw "Expected one set_mode operation description, found $($descriptionMatches.Count)."
}
$description = [IO.File]::ReadAllText($operationDescriptionPath).Trim()
$encodedDescription = $description | ConvertTo-Json -Compress
$descriptionReplacement = '                "description": ' + $encodedDescription + ','
$operationUpdated = [regex]::Replace($operationText, $descriptionPattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($match) $descriptionReplacement }, 1)
$openApiUpdated = $openApiUpdated.Substring(0, $operationIndex) + $operationUpdated + $openApiUpdated.Substring($nextOperationIndex)
[IO.File]::WriteAllText($openApiPath, $openApiUpdated, $utf8WithoutBom)

Write-Output 'Updated set_mode MQTT schema, REST artifact bundle, and published OpenAPI.'
