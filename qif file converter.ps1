# Define the input and output file paths
$inputFilePath = "C:\temp\original file.txt"
$outputFilePath = "C:\temp\output file.txt"

# Create an array to hold the converted data
$csvData = @()

# Read the input file line by line
Get-Content -Path $inputFilePath | ForEach-Object {
    $line = $_.Trim()

    if ($line.StartsWith("D")) {
        $date = $line.Substring(1).Trim()

        # Split the date string into components (month, day, year)
        $components = $date -split "[/'\s]" | Where-Object { $_ -ne '' }
        $month = [int]$components[0]
        $day = [int]$components[1]
        $year = [int]$components[2]

        # Construct the date in yyyy-MM-dd format
        $date = "{0:yyyy-MM-dd}" -f (Get-Date -Year $year -Month $month -Day $day)
    }
    elseif ($line.StartsWith("M")) {
        $memo = $line.Substring(1).Trim()
    }
    elseif ($line.StartsWith("T")) {
        $transaction = $line.Substring(1).Trim()
    }
    elseif ($line.StartsWith("P")) {
        $payee = $line.Substring(1).Trim()
    }
    elseif ($line.StartsWith("L")) {
        $LineItem = $line.Substring(1).Trim()
    }
    elseif ($line.StartsWith("N")) {
        $invoiceNumber = $line.Substring(1).Trim()
    }
    elseif ($line -eq "^") {
        # Create a new CSV entry when encountering "^"
        $csvEntry = [PSCustomObject]@{
            Date = $date
            Payee = $payee
            Transaction = $transaction
            Line = $lineitem
            Memo = $memo
            Number = $invoiceNumber
        }
        # Add the entry to the array
        $csvData += $csvEntry

        # Reset fields for the next entry
        $date = $null
        $payee = $null
        $transaction = $null
        $lineitem = $null
        $memo = $null
        $invoiceNumber = $null
    }
}

# Export the CSV data to the output file
$csvData | Export-Csv -Path $outputFilePath -NoTypeInformation

Write-Host "Conversion complete. CSV file created: $outputFilePath"