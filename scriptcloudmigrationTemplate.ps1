#configs
$tenantId = "your_tenant_id"
$clientId = "your_client_id"
$clientSecret = "your_secret" # this info can be found in your azure app. this requires Mail.Send permission to work
$scope = "https://graph.microsoft.com/(your_scope)"
$graphUrl = "https://graph.microsoft.com/v1.0/users/(email_to_send_from)/sendMail" #change it to the email you want to send from
$recipientEmail = "(email_to_send_to)" #test with your own email
#get token
$body = @{
    client_id     = $clientId
    scope         = $scope
    client_secret = $clientSecret
    grant_type    = "client_credentials"
}
# try catch to make sure im actually getting the token 
    try {
        $tokenResponse = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -Body $body
        $accessToken = $tokenResponse.access_token
        Write-Host "access token acquired."
    } catch {
        Write-Host "failed to get the access token." # error handling to tell you if the token has been successfully recieved or not
        return
    }
#create the email message
$emailBody = @{
    message = @{
        subject = "Test: Cloud Migration Email"
        body = @{
            contentType = "Text"
            content     = "Your mailbox has been successfully migrated." #add your own text and subject if you wish
        }
        toRecipients = @(
            @{
                emailAddress = @{
                    address = $recipientEmail 
                }
            }
        )
    }
    saveToSentItems = "false"
} | ConvertTo-Json -Depth 10
#send the email
Invoke-RestMethod -Method Post -Uri $graphUrl -Headers @{
    Authorization = "Bearer $accessToken"
    "Content-Type" = "application/json"
} -Body $emailBody

Write-Host "Script ran successfully. Email sent to $recipientEmail"