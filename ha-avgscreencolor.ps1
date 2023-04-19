$STEPSIZE=25 # take every 25th pixel into account

Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

# Get the dimensions of the primary screen
$screenWidth = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width
$screenHeight = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height

# Calculate the coordinates of the center of the screen
$centerX = $screenWidth / 2
$centerY = $screenHeight / 2

# Define the weight function
function GetPixelWeight($x, $y) {
    # Calculate the distance from the pixel to the center of the screen
    $distance = [Math]::Sqrt(($x - $centerX) * ($x - $centerX) + ($y - $centerY) * ($y - $centerY))
    
    # Map the distance to a weight between 0 and 1 using a Gaussian distribution
    $weight = [Math]::Exp(-($distance * $distance) / ($centerX * $centerY) / 10)
    
    return $weight
}


# Capture a screenshot of the entire screen
$bmp = New-Object System.Drawing.Bitmap($screenWidth, $screenHeight)
$graphics = [System.Drawing.Graphics]::FromImage($bmp)
$graphics.CopyFromScreen(0, 0, 0, 0, $bmp.Size)

# Define brightness thresholds for black, white, and grey pixels
$blackThreshold = 0.1
$whiteThreshold = 0.8

# Loop through each pixel in the screenshot and calculate the average color
$totalRed = 0
$totalGreen = 0
$totalBlue = 0
$totalPixels = 0
$totalWeight = 0

for ($x = 50; $x -lt $bmp.Width - 100; $x+=$STEPSIZE) { # take every 25th pixel into account
    for ($y = 20; $y -lt $bmp.Height - 350; $y+=$STEPSIZE) { # take every 25th pixel into account
        $pixelColor = $bmp.GetPixel($x, $y)
        
        # Skip pixels that are black, white, or grey
        if ($brightness -le $blackThreshold -or $brightness -ge $whiteThreshold) {
			$skippedPixels++
            continue
        }
		
        $weight = GetPixelWeight $x $y
        $totalRed += $weight * $pixelColor.R
        $totalGreen += $weight * $pixelColor.G
        $totalBlue += $weight * $pixelColor.B
        $totalWeight += $weight
    }
}

$averageRed = [Math]::Round($totalRed / $totalWeight)
$averageGreen = [Math]::Round($totalGreen / $totalWeight)
$averageBlue = [Math]::Round($totalBlue / $totalWeight)

# Output the average color as an RGB value, comma separated.
Write-Output "$averageRed,$averageGreen,$averageBlue"
