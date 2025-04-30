public class SendAgentForceLead {
     @InvocableMethod(label='Send Email to Leads (Template)' description='Send email using existing template to leads from AgentForce')
    public static List<String> sendEmails(List<Lead> leads) {
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
		List<String> result = new List<String>();
        // Replace with your actual template developer name or Id
        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Lead_Interest' LIMIT 1];

        for (Lead lead : leads) {
            if (String.isBlank(lead.Email)) continue;

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTargetObjectId(lead.Id);           // So merge fields resolve
            email.setTemplateId(template.Id);           // Use your email template
            email.setSaveAsActivity(true);
            email.setTreatTargetObjectAsRecipient(true);
            email.setWhatId(null);                      // Not linking to an Opportunity or other record
            emailsToSend.add(email);
        }

        if (!emailsToSend.isEmpty()) {
            Messaging.sendEmail(emailsToSend);
            result.add('Success'); // Return success status
        } else {
            result.add('No valid emails to send'); // If no emails were sent, return a failure message
        }

        return result;
    }

}