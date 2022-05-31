public class TestMe{
    public TestMe(){
        List<Account> acc = [Select id from Account Limit 5];
        System.debug(acc);
    }
    
    public void methodName(){
        List<Account> acc1 = [Select id from Account Limit 5];
        System.debug(acc1);
    }
}