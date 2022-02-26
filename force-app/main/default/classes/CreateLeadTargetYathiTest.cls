@isTest
private class CreateLeadTargetYathiTest{

 private static testmethod void method1(){
          
          lead finalLd=new lead();
                finalLd.firstname='Yathi';
                finalLd.lastName='Reddy';
                finalLd.street='HitechCity';
                finalLd.city='Hyderabad';
                finalLd.State='Telengana'; 
                finalLd.PostalCode='500081';
                finalld.phone='2222222222';
                finalld.email='aa@bb.com';
                finalld.company='ABC';
                Test.startTest();
                CreateLeadTargetYathi.createLeadInTarget(JSON.Serialize(finalLd));
                Test.stopTest();
 
   }
}