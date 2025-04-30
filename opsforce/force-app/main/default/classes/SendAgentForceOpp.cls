public class SendAgentForceOpp {
 @InvocableMethod(label='Send Email to Opportunities' description='Send email using existing template to opportunities and access the contact')
    public static List<String> sendEmails(List<Opportunity> opportunities) {
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
		List<String> result = new List<String>();
         // Query the Accounts and their primary Contacts linked to Opportunities
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity opp : opportunities) {
            if (opp.AccountId != null) {
                accountIds.add(opp.AccountId);
            }
        }
          
        // Replace with your actual template developer name or Id
        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Opportunity_Interest' LIMIT 1];
		Map<Id, Contact> accountContacts = new Map<Id, Contact>(
            [SELECT Id, Email, FirstName, LastName, AccountId 
             FROM Contact 
             WHERE AccountId IN :accountIds]
        );
        for (Opportunity opp : opportunities) {
           Contact oppContact = accountContacts.get(opp.AccountId);
            if (oppContact == null || String.isBlank(oppContact.Email)) continue;

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTargetObjectId(oppContact.Id);           // Link to the Contact (related to Opportunity)
            email.setTemplateId(template.Id);                 // Use your email template
            email.setSaveAsActivity(true);                     // Log email as activity
            email.setTreatTargetObjectAsRecipient(true);      // Set Contact as the recipient


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