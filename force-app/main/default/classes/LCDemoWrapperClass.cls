public with sharing class LCDemoWrapperClass {
    public class Wrapper {
        @AuraEnabled
        public String myString {get;set;}

        @AuraEnabled
        public Integer myInteger {get;set;}
    }
}