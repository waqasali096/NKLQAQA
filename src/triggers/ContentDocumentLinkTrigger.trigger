/**
* @author : Muhammad Moneeb
* @createdDate : 29 Dec 2021
* @lastModifiedDate : 29 Dec 2021
* @purpose - Initial Development
* @usage -Trigger for ContentDocumentLink.
*/
trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert, after delete) {
    if (trigger.isAfter) {
        if (trigger.isInsert) {
            ContentDocumentLinkHandler.afterEvent(trigger.new, 'Insert');
        }else if (trigger.isDelete) {
            ContentDocumentLinkHandler.afterEvent(trigger.old , 'Delete');
        }
    }
}