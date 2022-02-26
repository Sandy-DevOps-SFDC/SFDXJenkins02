public with sharing class CopyValueToTextBox {

    public String copiedValue { get; set; }

    public String textBox2 { get; set; }
    public String textBox1 { get; set; }
    
    public CopyValueToTextBox(){
         textBox1='abcd';
    }
    
    public PageReference copy(){
        textBox2=copiedValue;
        return null;
    }
    
}