Add-Type -AssemblyName System.Drawing

# Rebuild every report image from its original screenshot. Only identifiers are
# black-redacted: authentication/account/user, KMS-key, and S3 object-version IDs.
# No screenshot contains a private numeric IP address.
$blurRegions = @{
  '1.png'  = @('270,92,560,28', '0,215,850,25', '100,787,260,17', '100,805,260,17', '100,823,400,17')
  '7.png'  = @('125,322,250,58')
  '11.png' = @('100,68,350,25')
  '13.png' = @('445,235,175,25')
  '19.png' = @('0,180,370,38')
  '20.png' = @('25,170,280,55', '120,260,330,22')
  '21.png' = @('25,155,300,25')
  '22.png' = @('0,280,310,38')
  '26.png' = @('80,87,370,24')
  '27.png' = @('50,225,400,20')
}

function Redact-Region {
  param(
    [System.Drawing.Bitmap]$Image,
    [System.Drawing.Rectangle]$Region
  )

  $imageGraphics = [System.Drawing.Graphics]::FromImage($Image)
  $imageGraphics.FillRectangle([System.Drawing.Brushes]::Black, $Region)
  $imageGraphics.Dispose()
}

New-Item -ItemType Directory -Force -Path 'evidence-redacted' | Out-Null
Get-ChildItem -Path 'evidence-redacted' -Filter '*.png' -ErrorAction SilentlyContinue | Remove-Item -Force

1..27 | ForEach-Object {
  $name = "$_.png"
  $source = Join-Path $PSScriptRoot $name
  $target = Join-Path $PSScriptRoot ('evidence-redacted\' + $name)
  $img = [System.Drawing.Bitmap]::FromFile($source)
  if ($blurRegions.ContainsKey($name)) {
    foreach ($spec in $blurRegions[$name]) {
      $n = $spec.Split(',')
      $region = New-Object System.Drawing.Rectangle([int]$n[0], [int]$n[1], [int]$n[2], [int]$n[3])
      Redact-Region -Image $img -Region $region
    }
  }
  $img.Save($target, [System.Drawing.Imaging.ImageFormat]::Png)
  $img.Dispose()
}
