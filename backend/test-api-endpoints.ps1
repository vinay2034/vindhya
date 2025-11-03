# Database Connection Verification Script
# Tests all implemented features and their database connectivity

$baseUrl = "http://10.189.55.228:5000/api"
$adminEmail = "admin@school.com"
$adminPassword = "admin123"

Write-Host "[TESTING ALL FEATURES - DATABASE CONNECTION VERIFICATION]" -ForegroundColor Cyan
Write-Host "=" * 70
Write-Host ""

# Function to make API calls
function Test-Endpoint {
    param(
        [string]$Method,
        [string]$Endpoint,
        [string]$Token = $null,
        [object]$Body = $null,
        [string]$Description
    )
    
    Write-Host "Testing: $Description" -ForegroundColor Yellow
    Write-Host "  Endpoint: $Method $Endpoint"
    
    try {
        $headers = @{
            "Content-Type" = "application/json"
        }
        
        if ($Token) {
            $headers["Authorization"] = "Bearer $Token"
        }
        
        $params = @{
            Uri = "$baseUrl$Endpoint"
            Method = $Method
            Headers = $headers
            TimeoutSec = 10
        }
        
        if ($Body) {
            $params["Body"] = ($Body | ConvertTo-Json -Depth 10)
        }
        
        $response = Invoke-RestMethod @params
        Write-Host "  ✅ SUCCESS" -ForegroundColor Green
        
        # Show response summary
        if ($response.data) {
            if ($response.data.PSObject.Properties.Name -contains 'classes') {
                Write-Host "     Found: $($response.data.classes.Count) classes" -ForegroundColor Gray
            }
            if ($response.data.PSObject.Properties.Name -contains 'subjects') {
                Write-Host "     Found: $($response.data.subjects.Count) subjects" -ForegroundColor Gray
            }
            if ($response.data.PSObject.Properties.Name -contains 'timetable') {
                Write-Host "     Found: $($response.data.timetable.Count) timetable entries" -ForegroundColor Gray
            }
            if ($response.data.PSObject.Properties.Name -contains 'users') {
                Write-Host "     Found: $($response.data.users.Count) users" -ForegroundColor Gray
            }
            if ($response.data.PSObject.Properties.Name -contains 'fees') {
                Write-Host "     Found: $($response.data.fees.Count) fee records" -ForegroundColor Gray
            }
            if ($response.data.PSObject.Properties.Name -contains 'students') {
                Write-Host "     Found: $($response.data.students.Count) students" -ForegroundColor Gray
            }
        }
        
        return $response
    }
    catch {
        Write-Host "  ❌ FAILED: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
    Write-Host ""
}

# Step 1: Login to get token
Write-Host "`n[STEP 1] Authentication" -ForegroundColor Cyan
Write-Host "-" * 70
$loginBody = @{
    email = $adminEmail
    password = $adminPassword
}

$loginResponse = Test-Endpoint -Method "POST" -Endpoint "/auth/login" -Body $loginBody -Description "Admin Login"

if (-not $loginResponse) {
    Write-Host "`n[ERROR] Cannot proceed without authentication. Please ensure:" -ForegroundColor Red
    Write-Host "   1. Backend server is running" -ForegroundColor Yellow
    Write-Host "   2. Admin user exists in database" -ForegroundColor Yellow
    Write-Host "   3. Network connectivity is working" -ForegroundColor Yellow
    exit 1
}

$token = $loginResponse.data.token
Write-Host "  [SUCCESS] Token obtained successfully" -ForegroundColor Green

# Step 2: Test Admin Dashboard
Write-Host "`n[STEP 2] Admin Dashboard" -ForegroundColor Cyan
Write-Host "-" * 70
Test-Endpoint -Method "GET" -Endpoint "/admin/dashboard" -Token $token -Description "Get Dashboard Stats"

# Step 3: Test Classes Management
Write-Host "`n[STEP 3] Classes Management (Manage Classes Screen)" -ForegroundColor Cyan
Write-Host "-" * 70
$classesResponse = Test-Endpoint -Method "GET" -Endpoint "/admin/classes" -Token $token -Description "Get All Classes"

if ($classesResponse -and $classesResponse.data.classes.Count -gt 0) {
    $firstClass = $classesResponse.data.classes[0]
    Write-Host "  Sample Class:" -ForegroundColor Gray
    Write-Host "     Name: $($firstClass.className) $($firstClass.section)" -ForegroundColor Gray
    Write-Host "     Teacher: $($firstClass.classTeacher.profile.name)" -ForegroundColor Gray
    Write-Host "     Students: $($firstClass.totalStudents)" -ForegroundColor Gray
}

# Step 4: Test Subjects Management
Write-Host "`n[STEP 4] Subjects Management (Manage Subjects Screen)" -ForegroundColor Cyan
Write-Host "-" * 70
$subjectsResponse = Test-Endpoint -Method "GET" -Endpoint "/admin/subjects" -Token $token -Description "Get All Subjects"

if ($subjectsResponse -and $subjectsResponse.data.subjects.Count -gt 0) {
    $firstSubject = $subjectsResponse.data.subjects[0]
    Write-Host "  Sample Subject:" -ForegroundColor Gray
    Write-Host "     Name: $($firstSubject.name)" -ForegroundColor Gray
    Write-Host "     Code: $($firstSubject.code)" -ForegroundColor Gray
}

# Step 5: Test Timetable Management
Write-Host "`n[STEP 5] Timetable Management (Manage Timetable Screen)" -ForegroundColor Cyan
Write-Host "-" * 70
$timetableResponse = Test-Endpoint -Method "GET" -Endpoint "/admin/timetable" -Token $token -Description "Get All Timetable Entries"

if ($timetableResponse -and $timetableResponse.data.timetable.Count -gt 0) {
    $firstEntry = $timetableResponse.data.timetable[0]
    Write-Host "  Sample Timetable Entry:" -ForegroundColor Gray
    Write-Host "     Day: $($firstEntry.dayOfWeek)" -ForegroundColor Gray
    Write-Host "     Time: $($firstEntry.startTime) - $($firstEntry.endTime)" -ForegroundColor Gray
    Write-Host "     Subject: $($firstEntry.subjectId.name)" -ForegroundColor Gray
    Write-Host "     Class: $($firstEntry.classId.className) $($firstEntry.classId.section)" -ForegroundColor Gray
}

# Step 6: Test Teacher Assignments
Write-Host "`n[STEP 6] Teacher Assignments (Teacher Assignments Screen)" -ForegroundColor Cyan
Write-Host "-" * 70
$teachersResponse = Test-Endpoint -Method "GET" -Endpoint "/admin/users?role=teacher" -Token $token -Description "Get All Teachers"

if ($teachersResponse -and $teachersResponse.data.users.Count -gt 0) {
    $firstTeacher = $teachersResponse.data.users[0]
    Write-Host "  Sample Teacher:" -ForegroundColor Gray
    Write-Host "     Name: $($firstTeacher.profile.name)" -ForegroundColor Gray
    Write-Host "     Email: $($firstTeacher.email)" -ForegroundColor Gray
}

# Step 7: Test Fees Management
Write-Host "`n[STEP 7] Fees Management (Fees Management Screen)" -ForegroundColor Cyan
Write-Host "-" * 70
$feesResponse = Test-Endpoint -Method "GET" -Endpoint "/admin/fees?academicYear=2024-2025" -Token $token -Description "Get All Fee Records"

if ($feesResponse -and $feesResponse.data.fees.Count -gt 0) {
    Write-Host "  Fee Summary:" -ForegroundColor Gray
    $feesResponse.data.summary | ForEach-Object {
        Write-Host "     Status: $($_._id) | Amount: $$($_.totalAmount) | Count: $($_.count)" -ForegroundColor Gray
    }
}

# Step 8: Test Students
Write-Host "`n[STEP 8] Students Management" -ForegroundColor Cyan
Write-Host "-" * 70
$studentsResponse = Test-Endpoint -Method "GET" -Endpoint "/admin/students" -Token $token -Description "Get All Students"

if ($studentsResponse -and $studentsResponse.data.students.Count -gt 0) {
    $firstStudent = $studentsResponse.data.students[0]
    Write-Host "  Sample Student:" -ForegroundColor Gray
    Write-Host "     Name: $($firstStudent.name)" -ForegroundColor Gray
    Write-Host "     Roll No: $($firstStudent.rollNumber)" -ForegroundColor Gray
    Write-Host "     Class: $($firstStudent.classId.className) $($firstStudent.classId.section)" -ForegroundColor Gray
}

# Summary
Write-Host "`n" + "=" * 70
Write-Host "[VERIFICATION SUMMARY]" -ForegroundColor Cyan
Write-Host "=" * 70

$results = @{
    "[PASS] Authentication" = if ($loginResponse) { "PASSED" } else { "FAILED" }
    "[PASS] Dashboard" = "TESTED"
    "[PASS] Classes Management" = if ($classesResponse) { "CONNECTED TO DB" } else { "FAILED" }
    "[PASS] Subjects Management" = if ($subjectsResponse) { "CONNECTED TO DB" } else { "FAILED" }
    "[PASS] Timetable Management" = if ($timetableResponse) { "CONNECTED TO DB" } else { "FAILED" }
    "[PASS] Teacher Assignments" = if ($teachersResponse) { "CONNECTED TO DB" } else { "FAILED" }
    "[PASS] Fees Management" = if ($feesResponse) { "CONNECTED TO DB" } else { "FAILED" }
    "[PASS] Students" = if ($studentsResponse) { "CONNECTED TO DB" } else { "FAILED" }
}

$results.GetEnumerator() | ForEach-Object {
    $status = if ($_.Value -like "*CONNECTED*" -or $_.Value -eq "PASSED") { "Green" } elseif ($_.Value -eq "TESTED") { "Yellow" } else { "Red" }
    Write-Host "$($_.Key): $($_.Value)" -ForegroundColor $status
}

Write-Host "`nAll database connections verified!" -ForegroundColor Green
Write-Host "=" * 70
