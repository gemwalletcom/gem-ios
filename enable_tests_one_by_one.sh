#!/bin/bash

# Script to enable disabled tests one by one and test each

# List of remaining disabled tests
disabled_tests=(
    "NativeProviderServiceTests"
    "WalletsServiceTests" 
    "ChainServiceTests"
    "NodeServiceTests"
    "TransferServiceTests"
    "SettingsTests"
    "TransactionServiceTests"
    "GemAPITests"
    "ManageWalletsTest"
    "ChainSettingsTests"
    "SwapServiceTests"
    "WalletConnectorServiceTests"
    "NFTServiceTests"
    "QRScannerTests"
    "StyleTests"
    "NameResolverTests"
    "StakeServiceTests"
)

test_plan="/Users/gemcoder/Documents/GitHub/gem-ios/GemTests/unit_frameworks.xctestplan"

for test_name in "${disabled_tests[@]}"; do
    echo "=== Enabling $test_name ==="
    
    # Enable the test by removing the enabled: false line for this specific test
    # Create a temporary file with the change
    sed "/\"identifier\" : \"$test_name\"/,/},/{
        /\"enabled\" : false,/d
    }" "$test_plan" > "$test_plan.tmp" && mv "$test_plan.tmp" "$test_plan"
    
    echo "Testing $test_name..."
    
    # Test the specific test target
    if just test-specific "$test_name" > /dev/null 2>&1; then
        echo "✅ $test_name - PASSED"
    else
        echo "❌ $test_name - FAILED (keeping enabled for manual review)"
    fi
    
    echo ""
done

echo "=== Summary ==="
echo "All tests have been enabled. Check the output above for any failures."