/*
 * Purpose: Get the Email Ids of Recipients
 * ClassName: CustomEmailSendHelper
*/

public class CustomEmailSendHelper {
    /*
Method: FetchUserEmails
Purpose: Get the Email Ids of Recipients
*/
  public static Set<String> FetchUserEmails(List<SK_EmailAlertJSONParser.Recipients> RecipientsData,Id objectId){
      Set<String> UserEmails = New Set<String>();
      Set<String>userNameIds = new Set<String>();
      Set<String> groupName = New Set<String>();
      Set<String> roleName = New Set<String> ();
      Set<String> roleandsubordinatesName = New Set<String>();
      Set<String> userRolewithSubordinat = New Set<String>();
      String userType = Schema.SObjectType.User.getKeyPrefix();
      String groupType = Schema.SObjectType.Group.getKeyPrefix();
      String roleType = Schema.SObjectType.UserRole.getKeyPrefix();
      Set<Id> groupIds = New Set<Id>();
      Set<Id> subGroupIds = New Set<Id>();
      Set<Id> roleIds = New Set<id>();
      Set<Id> userIds = New Set<id>();
      Set<String> queryFields = New Set<String>();
        String qry = 'Select Id,';
        system.debug('RecipientsData=' + RecipientsData);
        for(SK_EmailAlertJSONParser.Recipients  rec: RecipientsData){
            if(rec.type_Z == 'role'){
                roleName.add(rec.recipient);
                userRolewithSubordinat.add(rec.recipient);
            }
            if(rec.type_Z == 'group'){
                groupName.add(rec.recipient);
            }
      		if(rec.type_Z == 'roleSubordinates'){
                roleandsubordinatesName.add(rec.recipient);
                userRolewithSubordinat.add(rec.recipient);
            }
            if(rec.type_Z == 'email')
            {
                queryFields.add(rec.field);
            }
            if(rec.type_Z == 'owner')
            {
                queryFields.add('OwnerId');
            }
            if(rec.type_Z == 'user')
            {
                UserEmails.add(rec.recipient);
                userNameIds.add(rec.recipient);
            }
            if(rec.type_Z == 'userLookup')
            {
                queryFields.add(rec.field);
            }
        }
        if(queryFields.size() > 0 && queryFields != null){
            for(String str : queryFields){
                 qry = qry + str + ',';
            }
           qry = qry.removeEnd(',');
            if(objectId != Null) {
          String sObjName = objectId.getSObjectType().getDescribe().getName();
          qry = qry + ' From ' +sObjName + ' Where Id=' + '\''+objectId+'\'';
           system.debug('qry=== ' + qry );
            SObject sobj = Database.query(qry);
            system.debug('qry=== ' + qry + ' rec==' + sobj);
            for(String st : queryFields){
                if(st == 'OwnerId'){
                    userIds.add((String)sobj.get(st));
                }else{
                    UserEmails.add((String)sobj.get(st));
                }
                
            }
            } 
        }
      System.debug('@@@ >>> '+ UserEmails);
        //------------------------------------for Group-------------------------------------------
        if(groupName.size() > 0 && groupName != Null){
            for(Group grp : [SELECT Id FROM Group WHERE DeveloperName IN : groupName and Type = 'Regular']){
                groupIds.add(grp.id);
            }
            if(groupIds.size() > 0){
                system.debug('grpid== '+ groupIds);
                for(GroupMember grpMember : [SELECT GroupId, UserOrGroupId FROM GroupMember WHERE GroupId IN:groupIds]){
                    system.debug('grpmemmer=' + grpMember);
                    if(((String)grpMember.UserOrGroupId).startsWith(userType)){
                        userIds.add(grpMember.UserOrGroupId);
                    }
                    if(((String)grpMember.UserOrGroupId).startsWith(groupType)){
                        subGroupIds.add(grpMember.UserOrGroupId);
                    }
                    if(((String)grpMember.UserOrGroupId).startsWith(roleType)){
                        roleIds.add(grpMember.UserOrGroupId);
                    }
                }
                system.debug('userid= ' + userIds + ' subGroupIds==' + subGroupIds + ' roleIds== ' + roleIds);
                if(subGroupIds.size() > 0 && subGroupIds != Null){
                    for(Group grp : [SELECT Id,relatedid FROM Group WHERE Id IN : subGroupIds]){
                        system.debug('grp++++ ' + grp);
                    if(((String)grp.relatedid).startsWith(userType)){
                          userIds.add(grp.relatedid);
                        }
                        if(((String)grp.relatedid).startsWith(roleType)){
                            roleIds.add(grp.relatedid);
                        }
                }
                } 
            }
        }
        //----------------------------------------------------------------------------------------------------
        //-------------------------------------for Role & Subordinate------------------------------------------------------
        map<String,Id> roleIdtoName = New Map<String,Id>();
        if(userRolewithSubordinat.size() > 0 && userRolewithSubordinat != Null){
            for(UserRole roleData : [Select Id,DeveloperName from UserRole where DeveloperName IN:userRolewithSubordinat]){
                roleIds.add(roleData.id);
                roleIdtoName.put(roleData.DeveloperName, roleData.id);
            }
            system.debug('roliods=== ' + roleIds + ' map== ' + roleIdtoName);
            if(roleandsubordinatesName.size() > 0 && roleandsubordinatesName != Null){
                set<Id> subroleid = New Set<Id>();
                for(String rolename1 :roleandsubordinatesName){
                    if(roleIdtoName.get(rolename1) != Null){
                        subroleid.add(roleIdtoName.get(rolename1));
                    }
                    
                }
                roleIds.addAll(getAllSubRoleIds(subroleid));
            }
            
            userIds.addAll(getRoleSubordinateUsers(roleIds));
        }
        
        //-----------------------------------------------------------------------------------------------------
        if((userIds.size() > 0 && userIds != Null) || (userNameIds.size()>0 && userNameIds != Null)){
            
            UserEmails.addAll(getUserEmails(userIds, userNameIds));
        }
        //-------------------------------------
        return UserEmails;
    }
    
     /*
Method: getUserEmails
Purpose: Get the Email Ids of Users
*/
    public static Set<String> getUserEmails(Set<Id> userIds, Set<String> userNameIds){
        Set<String> userEmails = New Set<String>();
        for(User users : [Select Id,Email from User where Id IN:userIds OR Username IN: userNameIds]){
            userEmails.add(users.Email);
        }
        return userEmails;
    }
    
    /*
Method: getRoleSubordinateUsers
Purpose: Get the Email Ids of Roles
*/
    
     public static Set<ID> getRoleSubordinateUsers(Set<ID> roleId) {
         system.debug('roleid====='   + roleId);
       Map<Id,User> users = new Map<Id, User>([Select Id, Name From User where IsActive = True AND UserRoleId IN :roleId]);
        return users.keySet();
    }
    
    /*
Method: getAllSubRoleIds
Purpose: Get the Ids of AllSubRoleIds
*/
    public static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {
        Set<ID> currentRoleIds = new Set<ID>();
        // Get all the roles underneath the passed roles.
        for(UserRole userRole :[select Id from UserRole where ParentRoleId IN :roleIds AND ParentRoleID != null])
            currentRoleIds.add(userRole.Id);
        if(currentRoleIds.size() > 0){
            currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
        }
        return currentRoleIds;
    }
}