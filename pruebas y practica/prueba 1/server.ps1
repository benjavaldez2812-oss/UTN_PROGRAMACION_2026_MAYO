# Servidor HTTP simple en PowerShell
$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://localhost:8080/")
$listener.Start()
Write-Host "Servidor iniciado en http://localhost:8080"
Write-Host "Presiona Ctrl+C para detener"

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response
    
    $path = $request.Url.LocalPath
    if ($path -eq "/") { $path = "/index.html" }
    
    $filePath = Join-Path "C:\Users\benja\Desktop\pruebas y practica\prueba 1" $path.Replace("/", "\")
    
    if (Test-Path $filePath) {
        $content = Get-Content $filePath -Raw -Encoding UTF8
        $buffer = [System.Text.Encoding]::UTF8.GetBytes($content)
        $response.ContentType = if ($filePath -match "\.html$") { "text/html" } elseif ($filePath -match "\.js$") { "application/javascript" } elseif ($filePath -match "\.obj$") { "model/obj" } elseif ($filePath -match "\.mtl$") { "model/mtl" } else { "text/plain" }
        $response.ContentLength64 = $buffer.Length
        $response.OutputStream.Write($buffer, 0, $buffer.Length)
    } else {
        $response.StatusCode = 404
        $buffer = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found")
        $response.OutputStream.Write($buffer, 0, $buffer.Length)
    }
    
    $response.Close()
}