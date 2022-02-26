public class fromJSON{
    public cls_OP_UCID[] OP_UCID;
    public class cls_OP_UCID {
        public String IdentificationTypeValue;  //UCID
        public String IdentificationNum;    //3000000003053A62288
        public String AdminClientNum;   //2018-05-87987
    }
    public static fromJSON parse(String json){
        return (fromJSON) System.JSON.deserialize(json, fromJSON.class);
    }

    
}