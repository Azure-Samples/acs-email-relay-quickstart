---
page_type: sample
languages:
- azdeveloper
- bicep
- powershell
products:
- azure-communication-services
urlFragment: acs-email-relay
name: Azure Communication Services as a central email relay
description: Send all your emails through usage of Azure Communication Services
---
<!-- YAML front-matter schema: https://review.learn.microsoft.com/en-us/help/contribute/samples/process/onboarding?branch=main#supported-metadata-fields-for-readmemd -->

# Azure Communication Services (ACS) Email Sample

This project demonstrates how to set up and use Azure Communication Services (ACS) for sending emails from your applications. ACS Email provides a reliable, scalable email delivery service that integrates with your Azure ecosystem, allowing you to send transactional emails without managing your own email infrastructure.

## Overview

Azure Communication Services Email capabilities allow you to:
- Send transactional emails through a trusted Microsoft email infrastructure
- Track email delivery statistics
- Use custom domains for sending emails
- Integrate email communications into your applications

## Architecture
![acs-email-relay-architecture](/docs/images/acs-relay-sample-architecture.png)

## Prerequisites

Before you begin, ensure you have the following:

1. **Azure Developer CLI (azd)**: This tool helps you manage your Azure resources and deployments. Install it by following the instructions [here](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd).

2. **Azure App Registration**: You need to register an application in Azure Active Directory to authenticate and authorize your application. Follow the steps [here](https://learn.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app) to create an app registration. Make sure to:
   - Set the appropriate permissions for sending emails
   - Create a client secret and save it securely
   - Note your Application (client) ID and Directory (tenant) ID

3. **PowerShell 7+**: For running the email sending scripts. You can download it from [here](https://github.com/PowerShell/PowerShell).

## Getting Started

1. Clone this repository to your local machine:
   ```bash
   git clone https://github.com/your-username/acs-email-sample.git
   cd acs-email-sample
   ```

2. Sign in to your Azure account using the Azure Developer CLI:
   ```bash
   azd auth login
   ```

3. Deploy the required Azure resources:
   ```bash
   azd up
   ```
   This command will:
   - Create an Azure Communication Services resource
   - Configure the email service
   - Set up necessary connections and permissions

4. After deployment completes, note the following from the output:
   - Communication Services resource name
   - Connection string or access keys (store these securely)

## Usage

### Important Note About Sender Email Address

When sending emails through ACS, you must use the Azure-managed domain that was assigned to your service. The sender email address will be in the format:
`DoNotReply@{your-domain}.azurecomm.net`

You can find your assigned domain in the Azure Portal under your Email Communication Service resource in the "Domains" section, or by checking the output after running `azd up`.

### Sending Emails with PowerShell

After deployment, you can use PowerShell to send emails through ACS:

```powershell
# Set up credentials for SMTP authentication
$Password = ConvertTo-SecureString -AsPlainText -Force -String 'YOUR_ENTRA_APPLICATION_CLIENT_SECRET'
$Cred = New-Object -TypeName PSCredential -ArgumentList 'YOUR_ACS_RESOURCE_NAME|YOUR_ENTRA_APP_ID|YOUR_ENTRA_TENANT_ID', $Password

# Send a simple email
Send-MailMessage -From 'DoNotReply@{your-domain}.azurecomm.net' -To 'recipient@example.com' -Subject 'Test mail' -Body 'This is a test email from Azure Communication Services' -SmtpServer 'smtp.azurecomm.net' -Port 587 -Credential $Cred -UseSsl

# Send an email with HTML content
Send-MailMessage -From 'DoNotReply@{your-domain}.azurecomm.net' -To 'recipient@example.com' -Subject 'HTML Test mail' -BodyAsHtml -Body '<h1>Hello</h1><p>This is an <strong>HTML</strong> email.</p>' -SmtpServer 'smtp.azurecomm.net' -Port 587 -Credential $Cred -UseSsl

# Send an email with attachments
Send-MailMessage -From 'DoNotReply@{your-domain}.azurecomm.net' -To 'recipient@example.com' -Subject 'Email with attachment' -Body 'Please see the attached document.' -Attachments 'path/to/your/file.pdf' -SmtpServer 'smtp.azurecomm.net' -Port 587 -Credential $Cred -UseSsl
```

Replace `{your-domain}` with your assigned Azure-managed domain (e.g., `5fe59b40-6423-402a-b23b-8179dc262ea4`).

### Using in Applications

To integrate email sending into your applications, you can use:

- **REST API**: Directly call the ACS Email API
- **SDKs**: Use the Azure Communication Services SDKs available for multiple languages
- **SMTP**: Connect using standard SMTP protocols as shown above

For more information about implementation options, see the [official documentation](https://learn.microsoft.com/en-us/azure/communication-services/concepts/email/email-overview).

## Troubleshooting

### Common Issues

1. **Authentication Errors**:
   - Verify your Entra Application credentials
   - Ensure your app registration has the correct permissions
   - Check that your client secret hasn't expired

2. **Email Delivery Issues**:
   - Verify recipient email addresses are correctly formatted
   - Check spam folders if emails aren't arriving
   - Review ACS metrics in the Azure portal for delivery statistics

3. **Deployment Failures**:
   - Ensure you have sufficient permissions in your Azure subscription
   - Check the Azure CLI is properly authenticated
   - Review error messages in the deployment logs

For additional help, refer to the [Azure Communication Services troubleshooting guide](https://learn.microsoft.com/en-us/azure/communication-services/concepts/troubleshooting-info).

## Contributing

We welcome contributions to improve this sample project:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please ensure your code follows the project's style guidelines and includes appropriate documentation.

## Resources

- [Azure Communication Services Documentation](https://learn.microsoft.com/en-us/azure/communication-services/)
- [ACS Email Documentation](https://learn.microsoft.com/en-us/azure/communication-services/concepts/email/email-overview)
- [Azure Developer CLI Documentation](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/)

## License

This project is licensed under the MIT License. See the LICENSE file for more details.