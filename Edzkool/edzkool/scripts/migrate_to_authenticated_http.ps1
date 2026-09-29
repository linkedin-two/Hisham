# Migrate raw http.get/post/delete/put calls to AuthenticatedHttp across lib/
$libPath = Join-Path $PSScriptRoot "..\lib"
$excludeFiles = @(
    "authenticated_http.dart",
    "secure_http_client.dart",
    "app_log.dart"
)

$dartFiles = Get-ChildItem -Path $libPath -Recurse -Filter "*.dart" |
    Where-Object { $excludeFiles -notcontains $_.Name }

$importLine = "import 'package:edzkool/utils/authenticated_http.dart';"

foreach ($file in $dartFiles) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    if ($content -notmatch 'http\.(get|post|delete|put|patch)\(') { continue }

    $original = $content

    $content = $content -replace 'http\.get\(', 'AuthenticatedHttp.get('
    $content = $content -replace 'http\.post\(', 'AuthenticatedHttp.post('
    $content = $content -replace 'http\.delete\(', 'AuthenticatedHttp.delete('
    $content = $content -replace 'http\.put\(', 'AuthenticatedHttp.put('
    $content = $content -replace 'http\.patch\(', 'AuthenticatedHttp.patch('

    if ($content -ne $original) {
        if ($content -notmatch [regex]::Escape($importLine)) {
            $content = $content -replace "^(import 'dart:[^']+';`r?`n)", "`$1$importLine`r`n", 1
            if ($content -notmatch [regex]::Escape($importLine)) {
                $content = $importLine + "`r`n" + $content
            }
        }
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
        Write-Host "Updated: $($file.FullName)"
    }
}

Write-Host "Migration complete."
