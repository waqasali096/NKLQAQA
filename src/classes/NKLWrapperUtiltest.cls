/****************************************************************************************************************************
* @Name         NKLWrapperUtiltest
* @Author       Sanket Chaudhari
* @Date         04-May-2022
* @Description  Test Class for NKLWrapperUtil
****************************************************************************************************************************/


@istest
public class NKLWrapperUtiltest {
    @isTest
    public static void SendEmailWrapperTest() {
        NKLWrapperUtil.SendEmailWrapper sWrap = new NKLWrapperUtil.SendEmailWrapper();
        sWrap.emailTemplateName = null;
        sWrap.emailTemplateId = null;
        sWrap.whatId = null;
        sWrap.whoId = null;
        sWrap.additionalEmailAddresses = null;
        sWrap.replyTo = null;
        sWrap.senderDisplayName = null;
        sWrap.orgWideAddress = null;
        sWrap.setTargetAsRecipient = null;
    }
    @isTest
    public static void TaskWrapperTest() {
        NKLWrapperUtil.TaskWrapper tWrap = new NKLWrapperUtil.TaskWrapper();
        tWrap.relatedTo = null;
        tWrap.currencyIsoCode = null;
        tWrap.priority = null;
        tWrap.status = null;
        tWrap.subject = null;
        tWrap.description = null;
        tWrap.fieldUpdate = null;
        tWrap.assignedTo = null;
        tWrap.dueDate = null;
    }
}