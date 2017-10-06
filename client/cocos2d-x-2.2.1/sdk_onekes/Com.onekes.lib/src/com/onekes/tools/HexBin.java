package com.onekes.tools;

/**
 * Copyright 1999-2002,2004 The Apache Software Foundation.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */



/***
 * format validation
 *
 * This class encodes/decodes hexadecimal data
 * 
 * @xerces.internal  
 * 
 * @author Jeffrey Rodriguez
 * @version $Id: HexBin.java,v 1.2.6.1 2005/09/06 11:44:41 neerajbj Exp $
 */
public final class  HexBin {
    static private final int  BASELENGTH   = 128;
    static private final int  LOOKUPLENGTH = 16;
    static final private byte [] hexNumberTable    = new byte[BASELENGTH];
    static final private char [] lookUpHexAlphabet = new char[LOOKUPLENGTH];


    static {
        for (int i = 0; i < BASELENGTH; i++ ) {
            hexNumberTable[i] = -1;
        }
        for ( int i = '9'; i >= '0'; i--) {
            hexNumberTable[i] = (byte) (i-'0');
        }
        for ( int i = 'F'; i>= 'A'; i--) {
            hexNumberTable[i] = (byte) ( i-'A' + 10 );
        }
        for ( int i = 'f'; i>= 'a'; i--) {
           hexNumberTable[i] = (byte) ( i-'a' + 10 );
        }

        for(int i = 0; i<10; i++ ) {
            lookUpHexAlphabet[i] = (char)('0'+i);
        }
        for(int i = 10; i<=15; i++ ) {
            lookUpHexAlphabet[i] = (char)('A'+i -10);
        }
    }

    /***
     * Encode a byte array to hex string
     *
     * @param binaryData array of byte to encode
     * @return return encoded string
     */
    static public String encode(byte[] binaryData) {
        if (binaryData == null)
            return null;
        int lengthData   = binaryData.length;
        int lengthEncode = lengthData * 2;
        char[] encodedData = new char[lengthEncode];
        int temp;
        for (int i = 0; i < lengthData; i++) {
            temp = binaryData[i];
            if (temp < 0)
                temp += 256;
            encodedData[i*2] = lookUpHexAlphabet[temp >> 4];
            encodedData[i*2+1] = lookUpHexAlphabet[temp & 0xf];
        }
        return new String(encodedData);
    }

    /***
     * Decode hex string to a byte array
     *
     * @param encoded encoded string
     * @return return array of byte to encode
     */
    static public byte[] decode(String encoded) {
        if (encoded == null)
            return null;
        int lengthData = encoded.length();
        if (lengthData % 2 != 0)
            return null;

        char[] binaryData = encoded.toCharArray();
        int lengthDecode = lengthData / 2;
        byte[] decodedData = new byte[lengthDecode];
        byte temp1, temp2;
        char tempChar;
        for( int i = 0; i<lengthDecode; i++ ){
            tempChar = binaryData[i*2];
            temp1 = (tempChar < BASELENGTH) ? hexNumberTable[tempChar] : -1;
            if (temp1 == -1)
                return null;
            tempChar = binaryData[i*2+1];
            temp2 = (tempChar < BASELENGTH) ? hexNumberTable[tempChar] : -1;
            if (temp2 == -1)
                return null;
            decodedData[i] = (byte)((temp1 << 4) | temp2);
        }
        return decodedData;
    }
    
    public static String byteArrayToHex(byte[] byteArray) {     	  
    	   // 棣栧厛鍒濆鍖栦竴涓瓧绗︽暟缁勶紝鐢ㄦ潵�?樻斁姣忎�?6杩涘埗�?楃      	  
    	   char[] hexDigits = {'0','1','2','3','4','5','6','7','8','9', 'A','B','C','D','E','F' };  
    	   // new涓�釜�?楃鏁扮粍锛岃繖涓氨鏄敤鏉ョ粍鎴愮粨鏋滃瓧绗︿覆鐨勶紙瑙ｉ噴涓�笅锛氫竴涓猙yte鏄叓浣嶄簩杩涘埗锛屼篃灏辨�?浣嶅崄鍏繘鍒跺瓧绗︼紙2鐨�娆℃柟绛変簬16鐨�娆℃柟锛夛級      	  
    	   char[] resultCharArray =new char[byteArray.length * 2];     	  
    	   // 閬嶅巻�?楄妭鏁扮粍锛岄�杩囦綅杩愮畻锛堜綅杩愮畻鏁堢巼楂橈級锛岃浆鎹㈡垚瀛楃鏀惧埌瀛楃鏁扮粍涓�?    	  
    	   int index = 0;  	  
    	   for (byte b : byteArray) {	  
    	      resultCharArray[index++] = hexDigits[b>>> 4 & 0xf];  
    	      resultCharArray[index++] = hexDigits[b& 0xf];      	  
    	   }  
    	   // 瀛楃鏁扮粍缁勫悎鎴愬瓧绗︿覆杩斿洖      	  
    	   return new String(resultCharArray);  
    }
}

