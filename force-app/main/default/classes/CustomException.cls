/**
 * クラス名       : CustomException
 * クラス概要     :  A custom exception class for handling specific errors in Apex
 * @created      :  2024/10/01 Huynh Phuoc
 * @modified    :   
 */
public without sharing class CustomException extends Exception {
    /**
     * create
     * Creates a new instance of CustomException with a custom error message
     * @param message  The error message to be set for the exception
     * @return CustomException  A new instance of CustomException with the provided message
     * @created: 2024/10/01 Huynh Phuoc
     * @modified: 
     */
    public static CustomException create(String message) {
        CustomException e = new CustomException();
        e.setMessage(message);
        return e;
    }
}