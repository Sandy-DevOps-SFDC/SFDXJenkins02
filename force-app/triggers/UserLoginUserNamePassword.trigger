trigger UserLoginUserNamePassword on User (after Update){
List<User> usrList=new List<User>();
List<User> usrList1=new List<User>();
MAP<ID,DateTime> usrLoginTimeMap=new MAP<ID,DateTime>();
MAP<ID,User> usrLoginData=new MAP<ID,User>();
set<ID> usrIds=new Set<ID>();
    for(user usr : Trigger.New){
        usrList.add(usr);
        usrIds.add(usr.id);
        usrLoginTimeMap.put(usr.id,usr.lastmodifieddate);
        usrLoginData.put(usr.id,usr);
    }

    for(LoginHistory logUsrHist : [select LoginTime,LoginType,UserId from LoginHistory where UserId IN : usrIds])
    {
                     if(logUsrHist.LoginType=='Application' && logUsrHist.LoginTime >= usrLoginTimeMap.get(logUsrHist.UserId)){
                        usrList1.add(usrLoginData.get(logUsrHist.UserId));
                     }
    }
    
    for(User usr1 : usrList1){
       usr1.addError('UserName and Password Login Not allowed');
    }
}