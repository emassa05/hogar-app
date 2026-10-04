[CmdletBinding()]
param(
    [string]$ApiBaseUrl = 'http://localhost:8100/api/v1',
    [string]$BackendPath = '',
    [string]$SmsLogPath = '',
    [switch]$UseRunningApi
)

$ErrorActionPreference = 'Stop'
$frontendPath = [IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot))
$projectsPath = Split-Path -Parent (Split-Path -Parent $frontendPath)
if (-not $BackendPath) {
    $BackendPath = Join-Path $projectsPath 'hogar-app\backend'
}
$BackendPath = [IO.Path]::GetFullPath($BackendPath)
$apiUri = [Uri]$ApiBaseUrl
if ($apiUri.Scheme -ne 'http' -or -not $apiUri.IsLoopback) {
    throw 'ApiBaseUrl must point to a local dedicated API over HTTP.'
}
$runtimePath = Join-Path $frontendPath 'build\e2e'
if (-not $SmsLogPath) {
    $SmsLogPath = Join-Path $runtimePath 'api.log'
}
$SmsLogPath = [IO.Path]::GetFullPath($SmsLogPath)
$errorLogPath = Join-Path (Split-Path -Parent $SmsLogPath) 'api-errors.log'
$variables = @(
    'DATABASE_URL', 'SMS_PROVIDER', 'RATE_LIMIT_ENABLED',
    'PYTHONDONTWRITEBYTECODE', 'PYTHONUNBUFFERED', 'PYTHONUTF8',
    'PYTHONIOENCODING', 'E2E_API_BASE_URL', 'E2E_SMS_LOG_PATH'
)
$savedEnvironment = @{}
foreach ($variable in $variables) {
    $savedEnvironment[$variable] = [Environment]::GetEnvironmentVariable($variable, 'Process')
}
$apiProcess = $null
$testExitCode = 1

try {
    if (-not $UseRunningApi) {
        if (-not (Test-Path -LiteralPath (Join-Path $BackendPath 'pyproject.toml'))) {
            throw 'BackendPath must contain the existing FastAPI project.'
        }
        if (-not $SmsLogPath.StartsWith($frontendPath + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
            throw 'Generated API logs must stay inside frontend.'
        }
        if (Get-NetTCPConnection -LocalPort $apiUri.Port -State Listen -ErrorAction SilentlyContinue) {
            throw 'The API port is already in use. Use -UseRunningApi only for your dedicated E2E server.'
        }
        New-Item -ItemType Directory -Path (Split-Path -Parent $SmsLogPath) -Force | Out-Null
        Push-Location $BackendPath
        try {
            docker compose up -d postgres redis
            if ($LASTEXITCODE -ne 0) { throw 'Unable to start PostgreSQL and Redis.' }
            $databaseExists = docker compose exec -T postgres psql -U hogar -d hogar -tAc "SELECT 1 FROM pg_database WHERE datname = 'hogar_e2e';"
            if ($LASTEXITCODE -ne 0) { throw 'Unable to inspect the dedicated E2E database.' }
            if (($databaseExists -join '').Trim() -ne '1') {
                docker compose exec -T postgres psql -U hogar -d hogar -c 'CREATE DATABASE hogar_e2e OWNER hogar;'
                if ($LASTEXITCODE -ne 0) { throw 'Unable to create hogar_e2e.' }
            }
            $env:DATABASE_URL = 'postgresql+asyncpg://hogar:hogar@localhost:5432/hogar_e2e'
            $env:SMS_PROVIDER = 'console'
            $env:RATE_LIMIT_ENABLED = 'false'
            $env:PYTHONDONTWRITEBYTECODE = '1'
            $env:PYTHONUNBUFFERED = '1'
            $env:PYTHONUTF8 = '1'
            $env:PYTHONIOENCODING = 'utf-8'
            uv run --no-sync alembic upgrade head
            if ($LASTEXITCODE -ne 0) { throw 'E2E database migrations failed.' }
            $uvPath = (Get-Command uv).Source
            $apiProcess = Start-Process -FilePath $uvPath -ArgumentList @(
                'run', '--no-sync', 'uvicorn', 'app.main:create_app', '--factory',
                '--host', '127.0.0.1', '--port', $apiUri.Port.ToString()
            ) -WorkingDirectory $BackendPath -WindowStyle Hidden -PassThru -RedirectStandardOutput $SmsLogPath -RedirectStandardError $errorLogPath
        } finally {
            Pop-Location
        }
    } elseif (-not (Test-Path -LiteralPath $SmsLogPath)) {
        throw 'SmsLogPath must point to the console SMS log of the running E2E API.'
    }
    $healthUri = [UriBuilder]::new($apiUri)
    $healthUri.Host = '127.0.0.1'
    $healthUri.Path = $apiUri.AbsolutePath.TrimEnd('/') + '/health/ready'
    $healthFailure = ''
    $deadline = [DateTime]::UtcNow.AddSeconds(60)
    $ready = $false
    while ([DateTime]::UtcNow -lt $deadline) {
        if ($apiProcess -and $apiProcess.HasExited) {
            throw "The E2E API stopped. Inspect $errorLogPath."
        }
        try {
            $health = Invoke-RestMethod -Uri $healthUri.Uri -TimeoutSec 2
            if ($health.status -eq 'ok') { $ready = $true; break }
        } catch {
            Start-Sleep -Milliseconds 250
        }
    }
    if (-not $ready) { throw "The dedicated E2E API did not become ready: $healthFailure" }
    $env:E2E_API_BASE_URL = $ApiBaseUrl
    $env:E2E_SMS_LOG_PATH = $SmsLogPath
    Push-Location $frontendPath
    try {
        flutter test --tags e2e --run-skipped test/e2e --reporter expanded
        $testExitCode = $LASTEXITCODE
        $findingsPath = Join-Path $runtimePath 'contract-findings.json'
        if (Test-Path -LiteralPath $findingsPath) {
            $findings = Get-Content -Raw -Encoding UTF8 -LiteralPath $findingsPath | ConvertFrom-Json
            Write-Host "Backend contract observations: $($findings.Count). Evidence: $findingsPath"
        }
    } finally {
        Pop-Location
    }
} finally {
    if ($apiProcess -and -not $apiProcess.HasExited) {
        taskkill /PID $apiProcess.Id /T /F | Out-Null
    }
    foreach ($variable in $variables) {
        [Environment]::SetEnvironmentVariable($variable, $savedEnvironment[$variable], 'Process')
    }
}

exit $testExitCode
